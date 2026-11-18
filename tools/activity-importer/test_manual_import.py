"""Manual workflow safety checks. All writes use small temporary fixture databases."""

from contextlib import closing
import json
from pathlib import Path
import shutil
import sqlite3
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

import import_activity as importer
from build_manual_release import build


ROOT = Path(__file__).resolve().parent


class ManualImportTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(dir=ROOT)
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.database = self.directory / "catalog.sqlite3"
        self.backups = self.directory / "activity-backups"
        self.wtf = self.directory / "WTF"
        self.save = self.wtf / "Account" / "fixture" / "realm" / "character" / "SavedVariables" / "GrindingForever.lua"
        self.save.parent.mkdir(parents=True)
        with closing(sqlite3.connect(self.database)) as db, db:
            db.execute("CREATE TABLE unrelated (value TEXT)")
            db.execute("INSERT INTO unrelated VALUES ('preserve me')")
        self.write_save(1)

    def write_save(self, sequence, invalid=False):
        rejected = ',[2]={kind="login",time=1794868774,sequence=200}' if invalid else ""
        self.save.write_text('GrindingForeverLiveCharacterDB = {events = {'
                             f'[1]={{kind="loot",time=1794868774,sequence={sequence},npcID=9499,itemID=5328}}'
                             + rejected + '},nextEvent=2}', encoding="utf-8")

    def cli(self, *extra, success=True):
        result = subprocess.run([sys.executable, str(ROOT / "import_activity.py"),
                                 "--database", str(self.database), "--wtf", str(self.wtf),
                                 "--backup-dir", str(self.backups), "--managed-backup-retention", "2",
                                 "--require-existing-database", *extra],
                                capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return json.loads(result.stdout) if success else result.stderr

    def managed(self):
        return sorted(self.backups.glob(importer.MANAGED_BACKUP_PREFIX + "*.sqlite3"))

    def bytes_in_backups(self):
        return {p.name: p.read_bytes() for p in self.backups.iterdir()} if self.backups.exists() else {}

    def count(self):
        with closing(sqlite3.connect(self.database)) as db:
            return db.execute("SELECT count(*) FROM gf_activity_observation").fetchone()[0]

    def test_success_retains_two_only_and_repeat_is_unchanged(self):
        self.backups.mkdir()
        unrelated = self.backups / "unrelated.sqlite3"
        unrelated.write_bytes(b"not owned")
        mimic = self.backups / (importer.MANAGED_BACKUP_PREFIX + "20000101T000000-000000Z-" + "a" * 32 + ".sqlite3")
        mimic.write_bytes(b"same name pattern but no ownership record")
        for sequence in range(1, 4):
            self.write_save(sequence, invalid=True)
            report = self.cli("--apply")
            self.assertEqual(report["new_observations"], 1)
            self.assertEqual(report["skipped_save_rows"], 1)
            self.assertFalse(report["backup_retention"]["warnings"])
        # managed() includes the deliberately unowned lookalike.
        self.assertEqual(len(list(self.backups.glob("*.owned.json"))), 2)
        self.assertEqual(len(self.managed()), 3)
        self.assertEqual(unrelated.read_bytes(), b"not owned")
        self.assertEqual(mimic.read_bytes(), b"same name pattern but no ownership record")
        self.assertEqual(self.count(), 3)
        before = self.bytes_in_backups()
        report = self.cli("--apply")
        self.assertEqual(report["new_observations"], 0)
        self.assertNotIn("backup_retention", report)
        self.assertEqual(self.bytes_in_backups(), before)

    def test_preview_never_creates_backup(self):
        before = self.database.read_bytes()
        report = self.cli()
        self.assertEqual(report["mode"], "dry-run")
        self.assertEqual(self.database.read_bytes(), before)
        self.assertFalse(self.backups.exists())

    def test_failed_insert_rolls_back_and_never_prunes(self):
        self.cli("--apply")
        self.write_save(2)
        self.cli("--apply")
        old_backups = self.bytes_in_backups()
        with closing(sqlite3.connect(self.database)) as db, db:
            db.execute("CREATE TRIGGER reject_fixture BEFORE INSERT ON gf_activity_observation "
                       "BEGIN SELECT RAISE(ABORT, 'fixture rejection'); END")
        self.write_save(3)
        self.assertIn("fixture rejection", self.cli("--apply", success=False))
        self.assertEqual(self.count(), 2)
        after = self.bytes_in_backups()
        for name, contents in old_backups.items():
            self.assertEqual(after[name], contents)
        self.assertEqual(len(self.managed()), 3)
        with closing(sqlite3.connect(self.database)) as db:
            self.assertEqual(db.execute("SELECT count(*) FROM gf_activity_import").fetchone()[0], 2)

    def test_commit_failure_prevents_retention(self):
        snapshot = importer.saved_snapshot(self.save, self.wtf)
        connect = sqlite3.connect

        class CommitFailure(sqlite3.Connection):
            def __exit__(self, kind, value, traceback):
                if kind is None:
                    self.rollback()
                    raise sqlite3.OperationalError("injected commit failure")
                return super().__exit__(kind, value, traceback)

        def connection(*args, **kwargs):
            return connect(*args, **kwargs, factory=CommitFailure)

        args = ["import_activity.py", "--database", str(self.database), "--wtf", str(self.wtf),
                "--apply", "--backup-dir", str(self.backups), "--managed-backup-retention", "2"]
        with patch.object(sys, "argv", args), patch.object(importer.sqlite3, "connect", connection), \
                patch.object(importer, "prune_managed_backups") as cleanup:
            self.assertEqual(importer.main(), 1)
            cleanup.assert_not_called()
        with closing(connect(self.database)) as db:
            self.assertFalse(db.execute("SELECT 1 FROM sqlite_schema WHERE name='gf_activity_observation'").fetchone())

    def test_bad_save_does_not_touch_database_or_backups(self):
        self.cli("--apply")
        before_db, before_backups = self.database.read_bytes(), self.bytes_in_backups()
        self.save.write_text("GrindingForeverLiveCharacterDB = { incomplete", encoding="utf-8")
        self.cli("--apply", success=False)
        self.assertEqual(self.database.read_bytes(), before_db)
        self.assertEqual(self.bytes_in_backups(), before_backups)

    def test_modified_backup_and_forged_marker_are_preserved(self):
        for sequence in range(1, 3):
            self.write_save(sequence)
            self.cli("--apply")
        changed = self.managed()[0]
        with changed.open("ab") as output:
            output.write(b"changed after backup")
        outside = self.directory / "outside.sqlite3"
        outside.write_bytes(b"keep outside file")
        forged = self.backups / (importer.MANAGED_BACKUP_PREFIX + "forged.sqlite3.owned.json")
        forged.write_text(json.dumps({"owner": importer.MANAGED_BACKUP_OWNER,
                                      "database": str(self.database.resolve()), "backup": "../outside.sqlite3"}), encoding="utf-8")
        self.write_save(3)
        report = self.cli("--apply")
        self.assertGreaterEqual(len(report["backup_retention"]["warnings"]), 2)
        self.assertTrue(changed.exists())
        self.assertTrue(forged.exists())
        self.assertEqual(outside.read_bytes(), b"keep outside file")
        self.assertEqual(self.count(), 3)

    def test_changed_file_during_read_is_rejected(self):
        before = self.save.stat()
        self.save.write_text(self.save.read_text() + "\n", encoding="utf-8")
        with self.assertRaisesRegex(ValueError, "changed during reading"):
            importer.check_read(self.save, before)

    def test_missing_catalog_and_missing_saves_fail(self):
        self.database.unlink()
        self.assertIn("Catalog not found", self.cli("--apply", success=False))
        self.assertFalse(self.database.exists())
        with closing(sqlite3.connect(self.database)):
            pass
        self.save.unlink()
        self.assertIn("No Grinding Forever character saves", self.cli("--apply", success=False))

    def test_locked_catalog_fails_without_pruning(self):
        self.cli("--apply")
        before = self.bytes_in_backups()
        self.write_save(2)
        with closing(sqlite3.connect(self.database)) as locked:
            locked.execute("BEGIN EXCLUSIVE")
            self.assertIn("locked", self.cli("--apply", success=False).lower())
            locked.rollback()
        self.assertEqual(self.count(), 1)
        self.assertEqual(self.bytes_in_backups(), before)

    def test_launcher_applies_and_shows_skips_and_repeat_status(self):
        shell = shutil.which("powershell.exe") or shutil.which("pwsh")
        if not shell:
            self.skipTest("PowerShell unavailable")
        self.write_save(1, invalid=True)
        build()
        launcher = ROOT / "manual-release" / "activity-importer" / "Import-ForeverActivity.ps1"
        command = [shell, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(launcher), "-Database", str(self.database),
                   "-Wtf", str(self.wtf), "-PythonPath", sys.executable]
        result = subprocess.run(command, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("SUCCESS: Imported 1 new observations", result.stdout)
        self.assertIn("Skipped validation rows: 1", result.stdout)
        self.assertEqual(self.count(), 1)
        self.assertEqual(len(self.managed()), 1)
        result = subprocess.run(command, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("ALREADY IMPORTED", result.stdout)
        cmd = (ROOT / "manual-release" / "Import Saved Activity.cmd").read_text()
        self.assertIn('"%~dp0activity-importer\\Import-ForeverActivity.ps1"', cmd)
        self.assertIn("pause >nul", cmd)
        self.assertIn("exit /b %GF_IMPORT_EXIT%", cmd)
        self.save.write_text("GrindingForeverLiveCharacterDB = { broken", encoding="utf-8")
        result = subprocess.run(command, capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)
        self.assertIn("IMPORT FAILED", result.stdout)
        self.assertEqual(self.count(), 1)

    def test_launcher_reports_cleanup_warning_after_committed_import(self):
        shell = shutil.which("powershell.exe") or shutil.which("pwsh")
        if not shell:
            self.skipTest("PowerShell unavailable")
        self.backups.mkdir()
        marker = self.backups / (importer.MANAGED_BACKUP_PREFIX + "bad.sqlite3.owned.json")
        marker.write_text("invalid ownership record", encoding="utf-8")
        build()
        result = subprocess.run([shell, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
                                 str(ROOT / "manual-release" / "activity-importer" / "Import-ForeverActivity.ps1"),
                                 "-Database", str(self.database), "-Wtf", str(self.wtf)],
                                capture_output=True, text=True, check=False)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("SUCCESS: Imported", result.stdout)
        self.assertIn("IMPORT COMMITTED; BACKUP CLEANUP WARNING", result.stdout)
        self.assertEqual(self.count(), 1)
        self.assertEqual(marker.read_text(), "invalid ownership record")


if __name__ == "__main__":
    unittest.main(verbosity=2)
