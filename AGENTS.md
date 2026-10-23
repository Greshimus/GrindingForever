# Grinding Forever — standing collaboration instructions

## Scope and authority

- This is a private WoW: Forever Classic beta addon. Keep work local/private unless the current task explicitly authorizes a remote operation.
- Repository visibility must always be PRIVATE. Verify remote ownership and `private=true` before linking or uploading. Never publish or create a public mirror.
- STOP before the first push. The user must approve the exact audited file set. Never force-add ignored material, push secrets, or treat private visibility as permission to redistribute third-party content.
- Read `PROJECT_STATUS.md`, `Collaboration/DECISIONS.md` and the applicable implementation report before editing. Preserve unfinished work and checkpoints; never blindly reset, clean, revert or overwrite it.
- Use task-specific scope. Do not start a new phase, native playback, route optimization, Retail work or unrelated refactoring without authorization.

## Functional baseline

- Preserve live guide selection/eligibility, Skyborne handling, displayed/source step identity, progression, quest completion, minimap launcher and original-guide fallback.
- Preserve the live-installed Phase 7E GPS merge: compass ownership, rotation, pivot, waypoint precedence, coordinates, distance/arrival calculations, dragging and placement. Do not deploy the divergent workspace MapArrow blindly.
- Cirrusfly's approved destination remains map 2521,45.17,27.83. Do not change guide content as part of presentation work.
- Native systems remain isolated; native gameplay stays disabled by default. Recorder, drafts and knowledge layers must not take over legacy gameplay or mutate observation evidence.
- No automatic quest acceptance/turn-in, gossip selection, targeting, raid marking, casting, item use or protected Blizzard frame changes. No insecure hooks or global overrides to bypass restrictions.
- Keep inactive Core.lua and UI/Windows.lua inactive. One addon and one minimap launcher; companion remains an unchanged rollback resource unless explicitly retired.

## Artwork and fidelity

- Approved locked masters and the final showcase control visual work, not the current production UI. Preserve independent left/right sculptures, colors, anatomy, aspect ratio and approved faction-arrow designs.
- No regeneration, mirroring, recoloring or speculative alpha reconstruction. Never promote composite screenshot fragments into production art without explicit review.
- Red close controls require gold X symbols. Keep bronze/leather/parchment composition and readable text.
- Do not invent quest, NPC, map, portrait, location or status data. Use copied validated display data; missing information stays unavailable.
- Do not claim visual parity from static/mock assertions. Distinguish supplied old screenshots, offline studies and actual new client rendering.
- Asset visual approval is not a rights grant. Preserve held assets and reference files locally until provenance/redistribution permission is resolved.

## Privacy and repository boundaries

- Never commit credentials, tokens, keys, account/character identifiers, player GUIDs, raw recordings, SavedVariables/WTF, machine logs, personal screenshots or backup/stage trees.
- Do not print authentication secrets. Inspect only credential-presence metadata unless a specific operation needs authenticated access.
- Imported legacy guides, mixed-origin catalogs, uncertain artwork and unreviewed vendored libraries are upload holds. Do not remove attribution or invent a license/provenance record.
- `.gitignore` is conservative and does not audit file contents. Run the upload audit, inspect findings, verify the exact staged set and obtain first-push approval.
- Do not add automated deployment, telemetry, uploads or GitHub workflows during setup. Remote access does not grant another client access automatically.

## Validation

- Use the existing Lua 5.1.5 interpreter for deterministic tests; do not install/download tools without permission.
- Run focused tests plus relevant established Lua/PowerShell checks. Do not weaken unrelated assertions or suppress failures.
- Separate historical failures, authorized layout-contract changes and real regressions. Report counts, exact limitations and required client tests.
- Preserve manifests and expected hashes. Create a new narrowly scoped preservation check rather than rewriting old evidence to make tests green.

## Deployment safeguards

- Never deploy automatically unless the current task explicitly authorizes deployment. Repository setup authorizes no WoW installation changes.
- Treat the installed addon as the preservation baseline; workspace and installed MapArrow.lua, Settings.lua and UI/FantasyPreview.lua intentionally differ.
- Audit every installed/workspace difference, verify source/candidate hashes and dependencies, back up with verified hashes, stage only approved paths, verify the exact post-change file set, and roll back unexpected changes.
- Do not use broad Deploy-Local.ps1 updates when they would overwrite unrelated installed differences. Do not change deployment safeguards to make a candidate eligible.
- New modules/TOC/artwork require the documented normal procedure with WoW closed unless independently established otherwise. Hot updates must meet the existing narrow transaction and rollback conditions.
- Never modify WTF or actual SavedVariables files directly. Never launch, close or reload WoW automatically. The user performs reload/live testing.

## Handoff

- Record decisions and report links in Collaboration; update PROJECT_STATUS when implementation or deployment state changes.
- Clearly state workspace candidate versus installed/live-verified behavior. A local Git commit is not deployment, and a push is not visual acceptance.
- Stop at the requested approval gate with concrete reviewable artifacts and blockers.
