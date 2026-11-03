Grinding Forever - TBC Anniversary tester build72

INSTALL: Close WoW. Extract this ZIP into World of Warcraft/_anniversary_/Interface/AddOns/.
The resulting path must be AddOns/GrindingForever/GrindingForever_TBC.toc.
Avoid GrindingForever/GrindingForever nesting. Enable Grinding Forever on the character screen.
No Questie, GatherMate, EveryQuest, MapUtils or other companion addon is required.
The folder named Retail contains shared compatibility code; keep it.

TEST: Log in. GF opens automatically. /gf toggles the window; /gf professions opens choices.
Supported supplied race/class guides cover the supplied1-35 routes; Human Paladin has its earlier extended route.
Completionist uses supplied-route positions plus the EveryQuest catalog.6176 catalog entries are not6176 fully routed quests.
Missing prerequisites/objective positions remain gaps, not proof of zone completion.
Open each learned crafting profession once with filters cleared. Town/vendor visits offer small crafting batches.
The basic-pole/no-lure Fishing assumption remains. Missing local material sources can prevent a farming route.
Dungeon maps use native client art where available. Restricted MapUtils artwork is not included;
unavailable native maps display a notice. Boss-position and loot coverage still require validation.
AH cheapest-craft/profit optimization is not implemented. Exact yellow/green skill-up probabilities are not claimed.

RECORDING: Collect activity data is controlled in Settings. Data stays in your own WoW SavedVariables.
This ZIP contains no player's SavedVariables, account information, recordings or private test results.
Quest acceptance/turn-in/guide flight automation are optional Settings; reward choices remain manual when needed.
Send the owner your race/class/level, quest or recipe ID/name, zone and a screenshot of any error.

LICENSES: EveryQuest database is GPL-2.0-only with corresponding source in Data/EveryQuestCatalog.lua.
See LICENSE-EveryQuest.txt and NOTICE-EveryQuest.txt. The profession database retains its MIT notice.
Other source/asset notices remain in SOURCE-NOTICE.txt; this private evaluation package is not a blanket public-release rights clearance.

Build49: location-aware Leveling reassesses the supplied faction quest routes after zone changes, with historical TBC quest race/class/level/prerequisite guards. Active quests remain available; this is not exhaustive all-quest or terrain/transport optimization. /gf route forces reassessment. A full WoW exit/restart loads the new Data/TBCQuestEligibility.lua TOC module. Separate eligibility source/license: NOTICE-TBCQuestRules.txt and LICENSE-TBCQuestRules.txt.

Build50: faction, location and level are primary for Leveling. A matching race/class export is not required. Eligible class/racial quests are overlays; real active quests and tested existing anchors are preserved. Source coverage remains limited to supplied located quest facts, not every Anniversary quest. Native testing pending.

Build50: faction, location and level are primary for Leveling. A matching race/class export is not required. Eligible class/racial quests are overlays; real active quests and tested existing anchors are preserved. Source coverage remains limited to supplied located quest facts, not every Anniversary quest. Native testing pending.

Build72: integrated step list/details, center map controls, source-grouped recipe search, source-specific pins, Compact/Normal and collapse grip, conditional scroll controls, dedicated foreground recipe tooltips. Existing artwork retained. Native visual validation pending.
