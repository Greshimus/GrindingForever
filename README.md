# Grinding Forever for WoW Forever

[Download the latest Forever tester build](https://github.com/Greshimus/GrindingForever/releases/latest/download/GrindingForever-Forever-Tester.zip).

Extract the `GrindingForever` folder into the Forever client's `Interface/AddOns` directory. Keep the folder name exactly `GrindingForever`. Restart the client after a first installation or use `/reload` after updating an existing installation. Open the addon with `/gf`.

The current tester build includes the crafting recommendation fixes, seasonal and faction quest filters, raised crafting tooltips, and the updated Dungeons & Raids skin. Open your profession book to refresh observed recipes. The recipe-book reader requires the client's legacy trade skill globals. The Lua startup and planner checks use a mock client. In-game verification is pending.

The package excludes the owner-only activity and performance trackers. Gathering map memory and observed recipe and vendor data are used locally by addon features.

The source checkout contains the installable `GrindingForever` folder. Source and map credits are included in that folder. See `GrindingForever/PACKAGE-MANIFEST.json` for the packaged file hashes.
