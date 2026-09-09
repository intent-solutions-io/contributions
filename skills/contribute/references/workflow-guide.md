# Current Contribution Workflow

This guide expands the control flow in `SKILL.md`. The current system is
markdown-only. Do not reintroduce the deleted SQLite tracker, bounty tables,
dashboard application, cloud backend, or separate CLI.

## State model

GitHub owns live issue and PR facts. Local state adds judgment and continuity:

- Candidate frontmatter stores repo, issue number, status, score, dossier path,
  scope intent, and optional PR coordinates.
- Candidate bodies store scope notes, drafts, evidence, and decision history.
- Dossier frontmatter stores gate inputs and first-touch fit signals.
- Dossier bodies store rejection patterns, maintainer preferences, deliberate
  design choices, and a failure log.
- `log.jsonl` records scout, researcher, transition, gate, and override events.

See `candidate-file-format.md` for the canonical file contract.

## Lifecycle

### Discover

Read the existing `open` and `shortlist` candidates first. Use the scout only
when refreshing that queue or answering a bounded search request. The scout
writes results; the parent reads its files and presents the strongest choices.

Discovery is not permission to claim. It produces candidates for qualification.

### Qualify

Confirm the issue is open, unassigned or available under maintainer rules, not
already solved, and not covered by competing active PRs. Read the dossier's
collaboration posture, rejection patterns, local test fit, license fence, and
positioning risk.

Use three verdicts:

- `claim`: receivable, testable, appropriately scoped, and no live conflict
- `wait`: a specific external condition could change the answer
- `skip`: structurally poor fit, duplicated, prohibited, or unverifiable

Record decisive evidence rather than a generic score alone.

### Claim

Run the shortlist-to-claimed gates before showing a draft. Use the claim
template and match upstream tone. The user must approve before a GitHub comment
or Wasteland claim is sent.

After a successful approved claim, let `transition.sh` update candidate status
atomically. Do not hand-edit a second tracker.

### Work

Read the clone's instructions, branch from the documented base, stay inside the
agreed scope, and run the actual native checks. If the repository is
full-stack-only and the environment cannot be reproduced, choose an isolatable
fix with honest isolated evidence or do not contribute.

Do not push failing work merely to let upstream CI diagnose it. Do not rewrite
history or force-push unless the upstream explicitly requires it and the user
authorizes it.

### Submit

Artifact choice follows collaboration posture, not a universal Design Issue
rule. Run the working-to-submitted gates, apply the trust ladder, and prepare
the exact title and body. Human approval is mandatory before creating an issue,
PR, review, or comment.

After an approved PR opens, write its number and URL into the candidate and log
the event. For Wasteland, record completion with `wl done` only after the PR URL
exists and the user approved the operation.

## Dossier freshness

Build a dossier before first touch. Refresh it when older than 14 days or when
any required field is absent. A manual failure log and curated notes must
survive refresh.

The researcher, not the parent, performs verbose CONTRIBUTING and linked-policy
research. The parent consumes its concise result and current dossier.

## Gate behavior

Transitions run deterministic phase gates from `scripts/gates/`. A block stops
the transition. A warning must be surfaced. An override is allowed only after
the user names the gate and supplies a concrete reason; the event log makes
override frequency auditable.

Never alter a gate, dossier fact, or candidate field merely to manufacture a
pass. Fix the underlying condition or preserve the block.

## Reconciliation

For every candidate with a PR number, compare local state with `gh pr view`:

- merged PR: set candidate status to `merged`
- closed unmerged PR: set status to `dropped` and append the lesson to the
  dossier failure log
- open PR: retain `submitted`

Report exact changes and unresolved API failures. GitHub remains authoritative.

## Deprecated architecture

Historical versions used a SQLite database, a `contribute-system` monorepo,
bounty and payment tables, a web dashboard, and a separate CLI. Those systems
were removed because the operational path did not use them. The current skill
must not claim they exist or direct users to SQL updates.
