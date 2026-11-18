Grinding Forever - manual activity import

After /reload or logging out, double-click:
E:\GrindingForeverCatalog\Import Saved Activity.cmd

The window reports imported observations, already-imported observations, skipped
validation rows, or an error. Press any key to close it when you finish reading.
There is no watcher, startup task, scheduled job, download, or background service.
WoW saves and its activity buffer are read only; they are never cleared or reset.
The importer checks every character save under the existing Forever WTF folder.

The catalog must already exist at:
E:\GrindingForeverCatalog\forever.sqlite3

Each import that adds observations first makes a recovery backup in:
E:\GrindingForeverCatalog\activity-backups

After a verified successful changing import, only the two newest backups owned
by this workflow are retained. Ownership is recorded in adjacent .owned.json
files. Unrelated backups and files are preserved. Failed imports retain recovery
backups; already-imported/no-op runs do not create backups or perform cleanup.
One current full backup is about 557 MB; two use about 1.1 GB. Cleanup failures
are reported separately after a successful import and may leave extra backups.
Do not remove ownership records if you want automatic retention to work.

Some saved rows can fail validation. The launcher always shows the skipped count;
these rows remain in the game save and do not prevent valid rows from importing.
The known older login-row contract mismatch is not changed by this workflow.

Installed support files:
E:\GrindingForeverCatalog\activity-importer\Import-ForeverActivity.ps1
E:\GrindingForeverCatalog\activity-importer\import_activity.py

The launcher uses the existing Codex cached Python runtime, an existing Python on
PATH, or an installed Codex runtime. It does not install anything. The normal
activity import never reads combat logs; those still require explicit CLI input.
The CMD permits its local PowerShell script for that process only; computer and
user execution-policy settings are not changed.

Recovery backups are full SQLite copies from immediately before a changing import.
Never replace the live catalog while an importer or another catalog writer runs.
