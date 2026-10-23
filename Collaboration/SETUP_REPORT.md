# Private GitHub collaboration preparation

Date: October 23, 2026.

Historical report: the tooling/repository blockers below describe the earlier setup attempt. Git installation and initialization have since been completed externally. See `FIRST_COMMIT_REPORT.md` for the current documentation-only local commit scope; the original setup findings remain preserved below.

**Status: BLOCKED before remote creation, local Git initialization and first push.** The requested repository is named GrindingForever and must be private, but no repository URL or verified visibility exists yet. No public or private repository was created, no remote configured, no files staged/committed/pushed, and no GitHub authentication request was made.

## Completed local work

- `.gitignore`: default-deny proposal with reviewed source/documentation categories; explicit privacy, backups, raw SavedVariables/WTF and provenance holds.
- `AGENTS.md`: project scope, visual authority, gameplay/GPS preservation, private-only collaboration, approval gates and narrow verified deployment safeguards.
- `PROJECT_STATUS.md`: installed versus uninstalled candidate state, live findings, test failures and next priorities.
- `Collaboration/README.md`: handoff/access workflow and first-push gate.
- `Collaboration/DECISIONS.md`: standing decisions and pending gates.
- `Collaboration/CODEX_REPORTS.md`: current implementation summary and future report template.
- `Collaboration/CHATGPT_REVIEW_REQUESTS.md`: repository and visual-candidate review requests.
- `Collaboration/ASSET_RIGHTS.md`: content/art/library holds and evidence requirements.
- `Collaboration/Audit-ProposedUpload.ps1`: local-only metadata inventory, heuristic privacy scan and proposed file/hash manifest. It never stages, authenticates, creates repositories or pushes.
- `Collaboration/LocalOnly/`: ignored audit runs and validation evidence. These local evidence files are not upload candidates.

Existing runtime Lua, tests, artwork, references, TOC and deployment scripts were not edited. No installed WoW file, companion, SavedVariables or WTF operation was performed. All held material remains in its original local location.

## Git and authentication inspection

- No existing project or ancestor `.git` was found at the inspected workspace/parent/root locations.
- Git and GitHub CLI are absent from PATH and the checked Program Files, per-user Programs, Tools, Scoop and WinGet-link locations.
- No GH_TOKEN/GITHUB_TOKEN environment value or standard GitHub CLI hosts configuration was found; only presence metadata was checked. Standard SSH key/config presence checks were also negative.
- No credential contents, token values, private keys, Windows Credential Manager entries or global configuration were dumped.
- Authentication is **not verified**, rather than certified absent everywhere. An installation or credential may exist at an unknown location. No software was installed/downloaded and no global setting was changed.

Without a usable Git executable, local initialization and Git-native ignore/staged-set validation cannot be completed safely. The audit script's file selection is a static proposal, not a claim that Git has verified it.

## Privacy audit

The original workspace inventory was approximately 5058 files/1.15 GB, dominated by references, backup/stage trees and duplicate artifacts. Those are not a reasonable first upload.

The proposed source/documentation subset is listed file-by-file with SHA-256 in the latest `LocalOnly/<run>/ProposedFiles.csv`. Initial scan found a concrete local profile path in `Docs/WOW_LUA_LANGUAGE_SERVER.md:12`; that original file was preserved and explicitly ignored. Subsequent proposed-set scanning found no heuristic matches for token/key patterns, embedded credential URLs, personal emails, concrete user-profile paths, player GUIDs or literal credential assignments.

This does not certify absence of arbitrary personal data or secrets. Binary images/reference screenshots and raw data are excluded, not declared privacy-safe. Findings never emit matching source text. Git ignore behavior and exact staged contents still require actual Git verification and human review before approval.

## Rights/provenance blockers

Existing `Docs/INDEPENDENCE_AUDIT.md` identifies imported/rebranded guide bodies and mixed-origin catalogs, semantically adapted legacy-format components, and incomplete vendored-library terms. `Assets/Showcase/NOTICE.txt` explicitly does not guarantee third-party rights. Phase4 notices give stronger generation history for one family but do not relicense older assets; its historical runtime manifest is still missing.

Therefore these remain ignored and preserved locally: Guides, Assets, DesignReferences, libs, locale, DB, Data, PreviewOnly, the specifically held legacy modules, and legacy control-directive tests/notes. Approved image identity and local SHA-256 preservation are not permission to upload.

Needed: actual source/ownership/permission records for included third-party material, exact library version/license notices, and a user-approved disposition for material that cannot be cleared. Do not invent a replacement manifest, strip attribution, infer rights from rebranding, assign a blanket open-source license, or force-add held files.

The proposed source-only set omits runtime dependencies and test evidence inputs. It is **not an installable addon package**, and not every test can run from that partial checkout alone. Holding dependencies rather than weakening tests is intentional. Nothing in this preparation replaces the working local addon or its verified backups.

## Remote and first-push gates

Once tools and rights/privacy issues are resolved:

1. Initialize locally using an existing approved Git installation; preserve all current files/uncommitted candidate work. Configure identity locally only with verified user information; never invent a commit author.
2. Re-run the audit. Use Git itself to verify ignored material stays excluded and inspect the precise proposed/staged file set. No broad or forced addition of excluded files.
3. Verify the intended authenticated owner. Check for an existing GrindingForever repository before creating anything. If the name exists, verify owner and private visibility; do not blindly repurpose it or change its visibility.
4. Create only an explicitly **private** empty repository if needed, with no source push, autogenerated conflicting history or public fallback. Verify identity, `private=true` and PRIVATE visibility through the authenticated service response before configuring origin.
5. Set a credential-free remote URL; do not put tokens in URLs. Report verified URL, owner, visibility and exact file manifest.
6. **STOP before the first push** and obtain approval of the concrete audited set. Recheck remote privacy and file hashes immediately before any later approved push.

Do not make a network request or create a repository merely to claim partial success while the user's explicit privacy/rights stop condition is unresolved. ChatGPT and Codex require separate authorized access to the private repository; neither is connected automatically by creating a URL.

## Result

Repository URL: **not available — repository not created**.

Visibility: **not verified — no repository exists from this task**. No public repository was created.

Remote: **not configured**. Local Git initialization: **blocked by missing tooling**. Push: **not attempted; approval still required**.

Next action is resolving approved tooling/authentication and the documented upload holds. Repository approval would not authorize deployment of the outstanding UI candidate.
