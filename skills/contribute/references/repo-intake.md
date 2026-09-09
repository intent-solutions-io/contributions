# Repository Intake

Use this mode when `/contribute` receives a public GitHub URL or an
`owner/repo` slug.

## Parse and guard scope

Normalize the argument by removing the GitHub host, `.git` suffix, and trailing
slash. Accept only a two-part GitHub slug. Determine the owner, repository, and
dossier path:

```bash
SLUG="OWNER/REPO"
OWNER="${SLUG%%/*}"
REPO="${SLUG#*/}"
DOSSIER="$HOME/.contribute-system/research/${OWNER}__${REPO}.md"
```

Reject owned repositories, including `jeremylongshore/*` and
`intent-solutions-io/*`. The contribution system protects upstream
maintainers; work on owned repositories belongs in their own project workflow.

## New repository

When the dossier is absent, fetch these live facts:

```bash
gh api repos/OWNER/REPO \
  --jq '{description,stars:.stargazers_count,language,license:.license.name,open_issues:.open_issues_count,default_branch,updated:.updated_at,archived,is_fork:.fork}'
gh issue list --repo OWNER/REPO --state open --limit 20 \
  --json number,title,labels,assignees,createdAt
gh api repos/OWNER/REPO/contents/CONTRIBUTING.md --jq '.content' \
  | base64 -d
gh pr list --repo OWNER/REPO --state merged --limit 10 \
  --json number,title,author,mergedAt
```

Verify the repository is canonical and not archived. Invoke the researcher in
build mode. It must populate contribution rules, collaboration posture,
counterparty design intent, positioning risk, license fence, local test fit,
rejection patterns, trust-ladder history, and refresh date.

Create candidate stubs only for open issues that are not assigned, duplicated,
or visibly closing. Use `status: open` and `scout_score: 0`; the scout owns
actual scoring.

Append a `repo_init` event with UTC timestamp, repo, `branch: new`, and source.
Then return the briefing and stop.

## Known repository

When the dossier exists, fetch in parallel:

- its `last_refreshed` value
- live open issues
- local candidates for the repo
- the user's open PRs in that repo

Refresh the dossier when older than 14 days or missing any required fit field.
Do not rebuild a current dossier merely because the skill was invoked.

Append a `repo_init` event with `branch: known`, return the briefing, and stop.

## Briefing contract

Return:

```text
Repo: OWNER/REPO — DESCRIPTION
  Stars: N · Language: X · License: Y · Default branch: Z
  Updated: DATE · Archived: BOOL · Fork: BOOL

Contribution contract:
  Build: COMMAND
  Lint: COMMAND OR NONE FOUND
  CLA: BOOL · DCO: BOOL · AI disclosure: BOOL
  Collaboration: open | guarded | closed
  Local test fit: isolated | partial | full-stack-only

Open issues and in-flight PRs:
  NUMBER: TITLE — AVAILABILITY

Dossier: built | refreshed | current
  Path: PATH

Suggested next action:
  ONE BOUNDED NEXT STEP
```

Never describe a missing document as permission. Use `unknown` and keep the
claim or submission boundary closed until the relevant rule is resolved.
