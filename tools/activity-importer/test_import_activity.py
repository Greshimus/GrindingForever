"""Offline fixture for the activity import CLI."""

from contextlib import closing
import json
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile


SCRIPT = Path(__file__).with_name("import_activity.py")
HEADER = "11/16/2026 17:45:20.091-0800  COMBAT_LOG_VERSION,22,ADVANCED_LOG_ENABLED,1,BUILD_VERSION,1.60.1.70938,PROJECT_ID,40\n"
SPELL = '11/16/2026 17:45:20.291-0800  SPELL_CAST_SUCCESS,Creature-0-1-2-3-9499-ABC,"PRIVATE NPC",0x0,0x0,Player-1-ABC,"PRIVATE PLAYER",0x0,0x0,21233,"PRIVATE SPELL",0x20\n'
MISS = '11/16/2026 17:45:21.000-0800  SPELL_MISSED,Player-1-ABC,"PRIVATE PLAYER",0x0,0x0,Creature-0-1-2-3-9499-ABC,"PRIVATE NPC",0x0,0x0,39332,"PRIVATE SPELL",0x08,'
SAVE = '''
GrindingForeverLiveCharacterDB = {
 ["events"] = {
  [1] = {kind="loot", time=1794868774, sequence=2, npcID=9499, itemID=5328,
         position={mapID=111, x=11.2, y=27.9, realNPCName="PRIVATE"}, label="PRIVATE"},
  [2] = {kind="gathered-item", time=1794868774, sequence=3, itemID=765, profession="Herbalism"},
  [3] = {kind="quest-objective", time=1794868774, questID=42, slot=1, current=0, required=1, text="PRIVATE"},
  [4] = {kind="target-observed", time=1794868775, sequence=4, npcID=9499, maxHealth=100, level=55, build=70938},
  [5] = {kind="target-observed", time=1794868776, sequence=5, npcID=9499, maxHealth=100},
  [6] = {kind="unsupported", time=1794868776, text="PRIVATE"},
 },
 ["nextEvent"] = 7,
}
'''


def cli(*args, expect=0):
    cmd = [sys.executable, str(SCRIPT), *map(str, args)]
    process = subprocess.run(cmd, capture_output=True, text=True, check=False)
    assert process.returncode == expect, (process.returncode, process.stderr, process.stdout)
    return json.loads(process.stdout) if expect == 0 else process.stderr


def test():
    with tempfile.TemporaryDirectory(dir=SCRIPT.parent) as name:
        directory = Path(name)
        db = directory / "catalog.sqlite3"
        saved = directory / "GrindingForever.lua"
        log = directory / "WoWCombatLog.txt"
        saved.write_text(SAVE, encoding="utf-8")
        log.write_text(HEADER + SPELL + MISS + "IMMUNE\n" + MISS + "DODGE\n" + SPELL.replace("-9499-", "-9543-"),
                       encoding="utf-8")
        with closing(sqlite3.connect(db)) as conn, conn:
            conn.execute("CREATE TABLE fixture (value)")
            conn.execute("INSERT INTO fixture VALUES (2)")
        before = db.read_bytes()
        args = ["--database", db, "--save", saved, "--combat-log", log, "--npc-id", 9499]
        assert cli(*args)["new_observations"] == 6
        assert db.read_bytes() == before and not list(directory.glob("*before-activity*"))
        result = cli(*args, "--apply")
        assert result["new_observations"] == 6
        with closing(sqlite3.connect(result["backup"])) as conn:
            assert conn.execute("SELECT * FROM fixture").fetchall() == [(2,)]
            assert not conn.execute("SELECT 1 FROM sqlite_schema WHERE name LIKE 'gf_activity%'").fetchone()
        with closing(sqlite3.connect(db)) as conn:
            rows = conn.execute("SELECT kind,evidence,payload FROM gf_activity_observation").fetchall()
            assert len(rows) == 6 and not conn.execute("PRAGMA foreign_key_check").fetchone()
            assert all("PRIVATE" not in p and "GUID" not in p for _, _, p in rows)
            assert [json.loads(p)["outcome"] for k, _, p in rows if k == "combat-hit-outcome"] == ["IMMUNE"]
            assert all("position" not in json.loads(p) for k, _, p in rows if k.startswith("combat-"))
            position = next(json.loads(p)["position"] for k, _, p in rows if k == "loot")
            assert position["evidence"] == "player-approach"
            target = next(json.loads(p) for k, _, p in rows if k == "target-observed")
            assert "maxHealth" not in target and target["level"] == 55
        assert cli(*args, "--apply")["new_observations"] == 0
        assert len(list(directory.glob("*before-activity*"))) == 1
        all_npcs = ["--database", db, "--no-saves", "--combat-log", log, "--all-npcs"]
        assert cli(*all_npcs)["new_observations"] == 1
        with log.open("a", encoding="utf-8") as f:
            f.write(MISS.replace("17:45:21.", "17:46:20.") + "RESIST\n")
        assert cli(*args)["new_observations"] == 1
        log.write_text(HEADER.replace("1.60.1.70938", "11.0.1.51505") + SPELL, encoding="utf-8")
        assert "non-Forever" in cli(*args, "--apply", expect=1)
        saved.write_text('GrindingForeverLiveCharacterDB = { injected = os.execute("something") }', encoding="utf-8")
        assert "SavedVariables" in cli("--database", db, "--save", saved, "--apply", expect=1)


if __name__ == "__main__":
    test()
    print("Activity import fixture passed: dry-run, backup, transaction, idempotence, appended logs, scope, provenance, and parser guards.")
