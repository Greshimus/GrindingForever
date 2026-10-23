# Private collaboration workflow

The repository is named **GrindingForever** and must be **private**. Local initialization and origin configuration are complete; remote privacy is user-reported and must be independently verified before any upload. Pushing, deployment and live acceptance are separate gates.

1. Review AGENTS.md and PROJECT_STATUS.md. Establish whether work is a local candidate or installed/live-tested.
2. Record scope/decisions in DECISIONS.md. Review privacy and ASSET_RIGHTS.md before proposing files.
3. Use CODEX_REPORTS.md for implementation handoffs; use CHATGPT_REVIEW_REQUESTS.md for specific review questions and acceptance criteria.
4. Run `Collaboration/Audit-ProposedUpload.ps1` locally. Reports under LocalOnly are ignored. A static scan is evidence, not an automatic rights clearance.
5. Once Git is available, verify `.gitignore` using Git itself and inspect the exact staged diff. No broad add/force-add or initial push until the audit and user approval gates pass.
6. An authenticated owner must verify the intended account, repository identity and private visibility. Never put a token in a remote URL or commit.
7. Both ChatGPT and Codex need their own authorized GitHub access. A private URL alone does not connect either tool or share local workspace files.

The current proposal excludes Assets, DesignReferences, imported guides and libraries pending rights review. They remain preserved locally. A partial source repository is not an addon distribution or a replacement for verified local backups.

The authorized first local commit includes only reviewed collaboration Markdown documents. See `FIRST_COMMIT_REPORT.md`; no source or local audit artifacts are included, and no push is authorized.
