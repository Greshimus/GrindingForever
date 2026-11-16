# Grinding Forever for WoW Forever

Forever-39 is available in the installable `GrindingForever` folder on `main`. [Download the current source build](https://github.com/Greshimus/GrindingForever/archive/refs/heads/main.zip). Previously packaged tester ZIPs are on the [Releases page](https://github.com/Greshimus/GrindingForever/releases).

Extract the `GrindingForever` folder into the Forever client's `Interface/AddOns` directory. Keep the folder name exactly `GrindingForever`. Fully restart the client when updating to Forever-39 so it loads the new data modules. Open the addon with `/gf`.

Forever-39 updates Dungeon Journal maps, quest chains, and reward choices. Boss cards match the quest detail parchment and show catalog levels, documented mechanics where available, and exact health when the client exposes it for the targeted boss. Selected portraits stay anchored to their map positions. Sunken Temple's revised maps are previews; some stairs still need review.

Steps adds the Moon-Kissed Blade materials card, retains existing detailed walkthroughs, and hides inactive seasonal quests. The compass remembers its placement, and recipe tooltips narrow vendor listings to nearby sellers. Open your profession book to refresh observed recipes. The Lua startup and planner checks use a mock client.

The package excludes the owner-only activity and performance trackers. Gathering map memory and observed recipe and vendor data are used locally by addon features.

The source checkout contains the installable `GrindingForever` folder. Source and map credits are included in that folder. See `GrindingForever/PACKAGE-MANIFEST.json` for the packaged file hashes.
