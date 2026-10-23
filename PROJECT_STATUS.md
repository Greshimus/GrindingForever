# Grinding Forever — collaboration status

Updated: October 23, 2026. Local repository initialized on `main`; a documentation-only first commit is authorized. No push is authorized or performed.

## Installed baseline

- WoW: Forever Classic beta, observed client 1.60.1/build 70450/interface 16001.
- Legacy `legacy-1-30` profile remains active. Skyborne selection, progression, original-guide close fix, Cirrusfly waypoint and live Phase 7E GPS are preserved.
- Phase 7D consolidated UI, Phase 7E live navigation and subsequent resizing were installed and tested. The last overnight Showcase correction was installed, but **was not accepted as production visual parity**.
- Phase 08 correction was subsequently installed by authorized three-file hot test deployment. It is **awaiting live testing**, not accepted as visual parity.
- Installed Showcase SHA-256: `C3D52A80D7ABEBD73906C8E60C7C5D41BE1B1DC6B8DFB40FA16324C141F01B53`.
- Installed MapArrow SHA-256: `43D236AF211F5980277C2DC30BC3EE447F9C4B87BBF7A4CD20542D9BF0433D2E`. Keep this installed-based GPS merge; do not substitute divergent workspace code.
- Companion remains installed as an unchanged rollback resource. Native gameplay remains disabled; native observation/draft/knowledge systems are separate from legacy gameplay.

## Phase 08 candidate — installed for testing, NOT visually accepted

The Showcase visual-parity correction modifies exactly three runtime paths:

- `UI/Showcase.lua`: corrected leather/rail texture sampling, reference-driven layout, current/upcoming row display, Zone header, startup/visibility behavior.
- `UI/GuideWindow.lua`: one-line login delegation to Showcase, preserving the existing close fix and other behavior.
- `UI/PresentationAdapter.lua`: bounded value-only rows from the existing displayed guide sequence; original objective/navigation behavior retained.

Local implementation evidence: `DesignReferences/08_SHOWCASE_PARITY_CORRECTION/IMPLEMENTATION_REPORT.md` (historical pre-install report, held locally). Installation evidence: `DesignReferences/08_PHASE08_TEST_INSTALL/20261023-072235/DEPLOYMENT_REPORT.md`. Exactly three installed paths changed; other 127 production and six companion files are unchanged. Full rollback backup is under that installation directory's `Backup/GrindingForever`.

Latest candidate validation: 13 Lua suites pass/2415 assertions; five fail. Five PowerShell suites pass/570 assertions; nine fail. Focused candidate suite: 766 assertions, plus 133 scoped preservation assertions. Failures include both old layout-contract pins invalidated by the new authorized composition and previously documented historical failures. The entire suite is not green; no tests were weakened.

## Live findings and remaining visual gate

- Previous live login selected original rather than Showcase; explicit Showcase open worked. Newly installed candidate routes startup to Showcase while respecting deliberate hidden preferences; client confirmation is pending.
- Resizing/positioning work. Approved sculpture appearance and palette are satisfactory.
- Persistent band comes from a baked gold frame inside the leather texture plus whole broad rail slices; candidate crops the unbordered interior and samples thin rails without changing assets.
- Candidate adds copied numbered steps, prioritizes parchment and gives Zone matching endcaps. No new client rendering has been observed; offline studies are not proof of parity.
- Exact layered frame/control artwork, embossed reference materials, ribbon/portrait/map composition and final-master faction-arrow integration remain unresolved. No invented data or substitute artwork is authorized.

## Next priorities

1. Finish the documentation-only local commit review. Stop before first push; verify remote ownership/private visibility and obtain exact-file approval before uploading.
2. Manually reload the newly installed three-file test candidate. Installation authorization does not approve any GitHub push or visual acceptance.
3. Capture equivalent-size client screenshots and test login/hidden state across characters, reload/relog, corners, compact layout, selected steps, independent Zone visibility and unchanged GPS.
4. Resolve exact production artwork/rights gaps without regeneration or speculative extraction. Do not claim final parity prematurely.

## Collaboration setup blockers

Git for Windows is now available and the local repository is initialized on `main`. The user reports the intended GitHub repository is private; origin names the intended owner/repository. Remote ownership, visibility and authentication have not been independently verified in this local-only task. Nothing was downloaded or installed by this task.

Imported guides, mixed catalogs, vendored libraries and artwork have unresolved provenance/redistribution questions. `.gitignore` holds them locally. The first commit is limited to reviewed collaboration Markdown documents; source files, the audit script, local audit evidence and `.gitignore` are excluded. See `Collaboration/FIRST_COMMIT_REPORT.md`. A local commit is not upload approval or deployment.
