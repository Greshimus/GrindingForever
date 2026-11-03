Current TBC96: corrected foreground farming selector; standalone historical gathering data including fishing pools; searchable material route picker;57 approximate user-traced route segments; steps-only and map/recipe compact views; expanded dungeon source rows. Compass concept is not included. Native route and visual testing ongoing.

Stable tester ZIP: https://github.com/Greshimus/GrindingForever/releases/download/tbc94/GrindingForever-TBC-Tester.zip . This URL always serves the current published TBC tester package; its historical tag name remains fixed. No local tester ZIP is retained after upload. Forever launch target: November4; TBC testing expected to wind down after November3.

Current TBC96: GF bundles historical NPC source locations; Questie is not required for recipe locations. 10841 located NPC records,104636 positions,5798 quest contacts. Standalone test binds10347 recipe-zone records;434 recipes lack mapped sources. Both factions and all nine crafting professions verified. All crafting professions share known-book validation, guaranteed batch capacity (5 primary/10 secondary), full materials, common-material preference and observed buy-price comparison. Unknown prices stay unknown; vendor/AH pages provide observed quotes, not a global cheapest-price guarantee. Forever parity remains a required follow-up using beta and verified unchanged Classic data. New compact-arrow design mockups remain pending; no design change in this patch.

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
