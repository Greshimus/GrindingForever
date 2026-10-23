# Codex implementation handoffs

## Current handoff: Showcase visual-parity correction

- State: Phase08 three-file candidate hot-installed for controlled testing; not accepted as parity.
- Runtime scope: UI/Showcase.lua, UI/GuideWindow.lua, UI/PresentationAdapter.lua.
- Local detailed report: DesignReferences/08_SHOWCASE_PARITY_CORRECTION/IMPLEMENTATION_REPORT.md. Evidence contains local screenshots/paths and is excluded from upload.
- Focused checks: 766 Lua assertions and 133 PowerShell assertions pass. Broader results: 13 passing/five failing Lua suites; five passing/nine failing PowerShell suites. Do not hide the intentional old-layout contract failures or historical failures.
- Preserved during install: other 127 production files, gameplay, GPS, artwork, companion and actual SavedVariables/WTF. Installation evidence: DesignReferences/08_PHASE08_TEST_INSTALL/20261023-072235/DEPLOYMENT_REPORT.md.
- Next gate: user-initiated reload and actual reference/screenshot review. No client screenshot of this candidate yet; repository/push approval is separate.

## Template for the next report

- Task/approved scope:
- Starting source and installed baseline hashes:
- Exact source files changed:
- Behavior changes and preserved systems:
- Tests run, counts, failures and classification:
- Visual evidence: old user screenshot / offline study / actual new client capture:
- Privacy/provenance issues:
- Deployment eligibility, proposed exact file set and rollback:
- Deployment actually performed:
- Questions requiring review and next authorization gate:

Do not paste raw observations, account identifiers, credentials or personal screenshots into a handoff.
