"""Assemble the exact E-drive folder layout without touching E or live data."""

import hashlib
import json
from pathlib import Path
import shutil


ROOT = Path(__file__).resolve().parent


def build():
    release = ROOT / "manual-release"
    files = {
        "Import Saved Activity.cmd": "Import Saved Activity.cmd",
        "Import-ForeverActivity.ps1": "activity-importer/Import-ForeverActivity.ps1",
        "import_activity.py": "activity-importer/import_activity.py",
        "MANUAL-IMPORT-README.txt": "MANUAL-IMPORT-README.txt",
    }
    manifest = {}
    for source, target in files.items():
        destination = release / target
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(ROOT / source, destination)
        manifest[target] = hashlib.sha256(destination.read_bytes()).hexdigest()
    (release / "release-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    return release


if __name__ == "__main__":
    print(build())
