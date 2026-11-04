Current TBC100: native World Map canvas fix; grouped resource picker; compact Bosses/Class menus and explicit boss selection; aggregate instance recipe sources; automatic recipe compass selection; historical-node fading and failed-interaction sightings; blacksmith service gating; lighter count-only quest progress; click-through header space; smaller GPS range with previous minimum as default at 80 percent slider travel. Tester diagnostics remain opt-in. Offline gameplay/data and interface tests pass; native visual/performance verification pending.

Stable tester ZIP: https://github.com/Greshimus/GrindingForever/releases/download/tbc94/GrindingForever-TBC-Tester.zip . The historical tag remains fixed. No local tester ZIP retained.

# Grinding Forever — TBC96

Current standalone tester build for **TBC Classic Anniversary**. This checkout replaces the old documentation-only repository contents; the previous commits remain in Git history.

## Download and install

[Download the latest tester ZIP](https://github.com/Greshimus/GrindingForever/releases/download/tbc93/GrindingForever-TBC-Tester.zip).

Extract the `GrindingForever` folder into the game's `Interface/AddOns` folder. Keep the folder name exactly `GrindingForever`. Restart the game after a first installation; use `/reload` after replacing an existing installation. No other addon or external asset folder is required. Blizzard-provided UI files are read from the game normally.

Alternatively, copy this repository's `GrindingForever` directory into `Interface/AddOns`.

## Current changes

- Track Activity and Track Performance buttons are stacked with visible On/Off states.
- Profession choices use an anchored, two-column parchment menu with Save Choices, Ask Me Later and Don't Ask Again.
- Recipe source sections have bronze expand/collapse arrows.
- Fishing instructions show the location and skill goal. Cooking skill determines which fish remain useful for skill-ups and which to sell.
- Performance retains one bounded summary when stopped or when `/reload` saves the character. Activity retains its bounded rolling event catalog. No uploads or telemetry occur in game.

15006 offline assertions passed. Native testing is ongoing; offline checks do not guarantee every live UI or quest case.

## Development handoff

`GrindingForever/UI/Showcase.lua` contains the active interface, adaptive guide layers and recent feature patches. `TBC.lua`, `Route.lua`, `Recipes.lua`, and `Data/` contain the TBC runtime facts and guide inputs. Read `GrindingForever_TBC.toc` for load order. Preserve GPS geometry, existing artwork and independently sized Normal/Compact modes.

The latest additions are marked `GF_MENUS91`, `GF_FISHING_COPY93` and `GF_SAVED_PERFORMANCE93`. The performance snapshot lives in the existing character SavedVariables table and replaces its previous snapshot; do not add unbounded per-frame history. Do not include player SavedVariables, credentials, recordings or personal screenshots in commits.

Outstanding: the all-recipe top-three drop-rate audit is **not deployed**. Imported source lists have missing percentages and some were truncated. A partial Wowhead TBC audit found suspicious Red Dragonspawn/Red Scalebane associations. Do not represent NPC-ID order as drop-rate order or claim that absent web tables prove a mob cannot drop an item. Complete source validation before replacing those facts.

This is the TBC test distribution, not the separately maintained Forever client port. Do not apply TBC rules or data to Forever without client-specific checks. Retain only the current and immediately previous local build; avoid duplicate art/database trees.

## Notices

Existing source and asset notices are preserved in the package. No blanket open-source license is granted to all bundled content by publishing this tester repository.
