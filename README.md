# Grinding Forever for WoW: Forever

Grinding Forever combines quest guidance, a Dungeon Journal, Recipe Sources and Farming Routes for WoW: Forever 1.60, Interface 16001. This is the **Forever-54 public build**, updated November 21, 2026.

[Download the current source build](https://github.com/Greshimus/GrindingForever/archive/refs/heads/main.zip). Extract its `GrindingForever` folder into the client's `Interface/AddOns` directory, preserving that folder name. Fully restart WoW after upgrading from an older release so the client loads the current file list. Open the addon with `/gfg`, `/grindingforever` or `/gfp`.

## Recipe Sources

- Browse uses collapsible wooden headers and cream cards, with professions ordered as primary crafting, secondary crafting, primary gathering and secondary gathering.
- Recipe Sources keeps its cream filter card visible without a separate Browse catalogue toggle. Shift-click an inventory item or chat item link into a focused GF search field; GF tooltips stay above its controls.
- Holy Salts and directly associated recipes are temporarily hidden while current availability is unconfirmed. Source records are retained.
- Browsing opens with My Professions, the player's location, and Vendors, Quests & Drops. Trained Recipes and Merchant's Favor remain separate source choices. Merchant's Favor temporarily uses All Locations and restores the prior location when leaving that source.
- Searching for a recipe, item or ingredient searches the whole library. Clearing the search restores the browsing filters. The location menu groups World and Instances, including dungeon and raid locations.
- Recipe cards show the crafted item, materials, unique requirements, compact acquisition details and supported costs. Broad drops use a compact World Drop summary with the recorded source and level information. Specific sources and requirements retain their distinctions.
- Bounded loading, cached results, unchanged-query checks and stable background refresh preserve the current browsing layout and open cards.

## Farming Routes

- Gathering first opens with Ore Veins, Herbs, Leather and Fish in collapsible wooden headers and cream cards. More materials contains Cloth, Raw Ingredients, Curatives, Elemental Drops and Specialty Reagents. The chooser offers 216 selectable material targets, presented as 185 main-card icons and selectable family flyouts.
- Ore and leather byproduct flyouts provide reference information without adding route targets. Existing exact-target routes remain valid. Fish, Cloth, Raw Ingredients, Elemental Drops and the remaining Specialty Reagents each use one card. Regular browsing omits the requested vendor or dungeon targets and seasonal Snowballs; all 270 underlying material records are retained.
- Materials follow documented acquisition or encountered-level progression within their groups. Unknown progression follows known entries. Recorded sources and known gathering requirements support route choices; unknown requirements are not invented.
- The chooser opens before full route-source preparation. Source work runs in short batches with a preparing status; Find routes becomes available when ready. Valid caches are reused, while relevant new gathering observations refresh affected locations. Route calculations begin when explicitly requested.
- Fish and pools share one flow. Recorded pool associations can support fishing guidance; a nearby pool does not prove the source of a catch.
- Find routes opens a separate popup with up to four distinct, supported recommendations. Each can expand to inspect its route and selected-resource locations. Starting a route rechecks the current selection, skills and known tool requirements.
- Hybrid routes retain suitable saved circuits and add short contributing side trips. Existing generated routes remain available where a saved route cannot support the selection.
- The resource index contains 51,999 qualified typed location records across 47 maps. Co-located alternatives remain available, including shared Copper/Tin/Silver sites. Possible spawn records and player approach observations retain separate meanings.
- World-map and expanded FR markers use cached spatial display groups and pooled drawing batches. Hovering a group reveals its recorded resource alternatives. Recorded locations do not establish current spawn presence, measured yield per hour, terrain safety or respawn timing.

A further zone-circuit redesign remains under review. This release preserves the existing hybrid route geometry and ranking.

## Dungeon Journal and quest guidance

- The Journal supports wide and narrow layouts, dungeon wings, collapsible quest chains, rewards, native item tooltips and Shift-click links.
- Prepare Quests starts or resumes the selected dungeon's prerequisite journey, including before-run, dungeon and follow-up work. Character eligibility, prerequisites, saved pause/resume and completed-chain accounting guide the handoff into quest Steps.
- Quest-source corrections and supported facts remain available across Steps and Journal preparation. Missing information is distinguished from a known negative requirement.
- Recorded vendor prices in Steps use normal coin denominations, such as 45 silver for a recorded 4,500-copper price. Stored costs and affordability checks are unchanged.
- Nearby vendor checks and guide refreshes reuse unchanged catalogue lookups, coordinates and window geometry. Current quest, skill, stock, affordability and learned-recipe checks remain active.
- Clicking Farming again closes the material chooser or route-options window while retaining selected materials and the active route.
- Approved Ragefire Chasm and Temple artwork, map controls, floor selection and source credits are included. Indoor player projection remains limited to usable client APIs and verified projection metadata.

Existing profession guidance, trainer controls, quest routing and ordinary named gathering-node memory are retained. Activity capture, performance diagnostics and the manual activity importer are maintained privately and are excluded from this public build.

## Sources and credits

The installable folder includes `ForeverQuest-NOTICE.txt`, `FishingPool-NOTICE.txt` and `Media/DungeonMapCredits.txt`. These retain the original source, artwork, license and contributor qualifications, including Santiago Reyes's credited map artwork. Source-specific metadata and pinned license notices are in `tools/fishing-pools`.

Gathering records combine qualified Forever source facts, separately attributed inherited references and normalized observations. Gameobject IDs and gathering node-type IDs remain distinct. Unknown requirements, pool relationships and coordinates are not guessed. Existing positive facts are retained when a later source omits a field.

No character save files, SQLite databases, private activity importer, private collector implementation or development captures are included in this public snapshot.

## Verification

The public package is checked against its Git-blob manifest and compiled with Lua 5.1. Mocked-client checks cover Recipe Sources, the Journal, Farming Routes, map coverage, source qualifications, caching and guarded route starts. These checks supplement normal in-game verification of rendering, travel, quest credit and performance.

`GrindingForever/PACKAGE-MANIFEST.json` records the exact hashes of the public package files. Public source files use LF line endings; their hashes can differ from a local installation that used CRLF.
