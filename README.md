# Grinding Forever for WoW Forever

Forever-52 is available in the installable `GrindingForever` folder on `main`. [Download the current source build](https://github.com/Greshimus/GrindingForever/archive/refs/heads/main.zip). Previously packaged tester ZIPs are on the [Releases page](https://github.com/Greshimus/GrindingForever/releases).

Extract the `GrindingForever` folder into the Forever client's `Interface/AddOns` directory. Keep the folder name exactly `GrindingForever`. This package targets WoW: Forever 1.60, Interface 16001, and Lua 5.1. Restart the client after updating. Open the addon with `/gfg`, `/grindingforever`, or the existing `/gfp` command.

Forever-52 includes these updates:

- Nearby ready quest hand-ins can stay together in a route card, including when a separate objective ranks above them.
- The profession card lists multiple individually affordable nearby training options. The Great Outdoors prioritizes sitting at the adventurer's camp and follows the server's ready flag before recommending its hand-in.
- Recipe and seller-name searches span browsing filters. Clearing the search restores those filters. Recipe recommendation cards in Steps include a Pin Source action.
- Steps header ornaments sit behind the lower rail. Dungeon quest-chain boot prints use a brighter gold rendering without changing their artwork, shape, or placement.

Existing grouped quest guidance, Dungeon Prep, dungeon maps, crafted-item dropdowns, native tooltips, and Shift-click links from item names and icons are retained. Dungeon live-position integration and automatic fishing-pool identification remain separate investigations.

The public addon excludes the owner-only activity and performance trackers, their Settings controls, and activity-buffer reminders. Gathering map memory and observed recipe and vendor data remain local addon features. The separate local development copy supports optional activity capture and reminders after 1,500, 1,800, and 2,000 new observations; those features are not included in this public package.

The optional manual importer source and tests in `tools/activity-importer` are maintainer tooling for private development captures, not a dependency of the public addon. The public addon does not generate those tracker captures. Its build script assembles a click-to-run launcher for the local catalog folder. It imports saved observations once, reports the result, and keeps two verified workflow-owned database backups after successful changing imports. It runs only when launched; it does not install a watcher or startup task, clear WoW saves, or import combat logs without explicit input. Neither databases nor character saves are included in this repository.

Automated checks load the complete addon under a mocked Lua 5.1 client and exercise the importer against temporary databases. They do not replace in-game checks of rendering, navigation, trainer offers, or quest credit.

The source checkout contains the installable `GrindingForever` folder. Source and map credits are included in that folder. See `GrindingForever/PACKAGE-MANIFEST.json` for the packaged file hashes.
