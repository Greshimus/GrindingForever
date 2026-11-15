# Grinding Forever for WoW Forever

Forever-38 is available in the installable `GrindingForever` folder on `main`. [Download the current source build](https://github.com/Greshimus/GrindingForever/archive/refs/heads/main.zip). Previously packaged tester ZIPs are on the [Releases page](https://github.com/Greshimus/GrindingForever/releases).

Extract the `GrindingForever` folder into the Forever client's `Interface/AddOns` directory. Keep the folder name exactly `GrindingForever`. Fully restart the client when updating to Forever-38 so it loads the new quest modules. Open the addon with `/gf`.

Forever-38 adds dungeon preparation and run prompts, improvements to farming source selection, and map-guided steps for both Trial of the Sea Lion variants, Pamela's Doll, The Stave of Equinex, and Data Rescue. Data Rescue includes room directions for the three indoor terminals. Open your profession book to refresh observed recipes. The recipe-book reader requires the client's legacy trade skill globals. The Lua startup and planner checks use a mock client.

The package excludes the owner-only activity and performance trackers. Gathering map memory and observed recipe and vendor data are used locally by addon features.

The source checkout contains the installable `GrindingForever` folder. Source and map credits are included in that folder. See `GrindingForever/PACKAGE-MANIFEST.json` for the packaged file hashes.
