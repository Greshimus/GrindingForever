# Fishing-layer source and license ledger

This directory retains source URLs, immutable hashes and the exact upstream license/provenance notices for two fishing layers bundled with Grinding Forever:

- 148 native Forever possible-site records from QuestieDB Forever v1.1.2, commit `e1652ce62113c152da682baf2d6fb85f1396bcfb`.
- 401 separately attributed inherited reference records from GatherRadar 1.05, commit `a2c32eac47f4c56544809858bd69525564097d7a`.

`source-manifest.json` lists the original input URLs, hashes and original build-relative paths. Upstream input Lua and the private import/backup tools are not distributed in this public ledger. The listed source URLs identify the immutable inputs.

The QuestieDB notice distinguishes newer GPLv3 contributions from historic imported/contributor material. Its maintainer's permission and historic-contributor qualification are preserved in `UPSTREAM-LICENSE.md` and `UPSTREAM-PROVENANCE.md`; they are not a uniform licensing claim for every historic contribution.

The GatherRadar MIT notice is retained with its upstream AzerothCore GPLv2 provenance. The original AzerothCore input revision and conversion are unverified. These inherited positions remain reference facts rather than confirmed Forever spawns, exact observed pool centers or catches. GatherMate2 locale names retain their contributor credits and GPLv2 notice in the runtime fishing notice.

This ledger describes those two fishing layers, not a complete rebuild of the broader 51,999-record resource index. That index retains source roles and evidence metadata in `GrindingForever/ForeverCatalog.lua`. See `tools/resource-locations/SOURCE-NOTES.md` for the public resource-data projection.
