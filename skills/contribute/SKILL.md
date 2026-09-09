---
name: contribute
description: >-
  Run a local-first, gate-checked workflow for contributing to public upstream
  GitHub repositories the user does not own. Use when reviewing contribution
  status, onboarding an upstream repo, finding and qualifying issues, preparing
  a claim, testing a patch, drafting a Design Issue or PR, or reconciling local
  candidate state with GitHub. Trigger with "/contribute", "what is my PR
  status", "find a contribution", "claim this issue", "draft an upstream PR",
  or a public GitHub repository URL.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - Agent
  - Bash(gh:*)
  - Bash(git:*)
  - Bash(node:*)
  - Bash(pnpm:*)
  - Bash(yarn:*)
  - Bash(npm:*)
  - Bash(cargo:*)
  - Bash(pytest:*)
  - Bash(python:*)
  - Bash(python3:*)
  - Bash(bash:*)
  - Bash(jq:*)
  - Bash(base64:*)
version: 4.1.0
author: Jeremy Longshore <jeremy@intentsolutions.io>
license: MIT
compatibility: Designed for Claude Code; requires authenticated gh CLI and jq
tags:
  - oss
  - contributions
  - github
  - contributing-clanker
  - ai-slop-prevention
argument-hint: "[status, action, GitHub URL, or owner/repo]"
model: inherit
effort: high
---

# Contribute Command Center

## Overview

Operate an upstream-contribution system whose durable state is readable local
text, not a database or cloud service:

1. GitHub is authoritative for live issue and PR state.
2. Candidate files live at
   `~/.contribute-system/candidates/OWNER__REPO__issueNUMBER.md`.
3. Repo dossiers live at
   `~/.contribute-system/research/OWNER__REPO.md`.
4. An append-only event log lives at `~/.contribute-system/log.jsonl`.

This skill applies only to contributions into repositories outside the user's
own accounts and organizations. Treat `jeremylongshore/*` and
`intent-solutions-io/*` as out of scope. If a candidate points to an owned
repository, report a scout defect and stop this workflow.

## Prerequisites

- `gh` authenticated for the intended GitHub account
- `jq` available on `PATH`
- Runtime state beneath `~/.contribute-system/`
- Upstream clones beneath `~/000-projects/contributing-clanker/`
- The target repository's instructions read before any edit or command

Use `Read`, `Glob`, and `Grep` to inspect local instructions and state. Use
`Write` or `Edit` only for candidate and dossier content authorized by this
workflow. Use `AskUserQuestion` at the submission boundary. Delegate isolated
research or testing with `Agent` only where the referenced subagent owns that
job. Run external programs only through the declared scoped `Bash` entries.

## Authentication

GitHub operations use the OAuth token already held by the authenticated `gh`
CLI session. Begin network work with `gh auth status`. Never request, print,
store in candidate files, or pass a token on the command line. If authentication
is absent or lacks scope, stop and tell the user which `gh` operation failed.

## Instructions

### Step 1: Detect invocation mode

Inspect the arguments before refreshing everything.

- A GitHub URL or `owner/repo` slug enters **Repo Intake Mode**. Follow
  [repo intake](references/repo-intake.md), enforce the owned-repo scope guard,
  surface the resulting briefing, and stop.
- A status or reconciliation request enters **Operations Mode**. Follow
  [operations](references/operations.md).
- A candidate-specific request proceeds through the smallest applicable steps
  below. Do not redo completed discovery merely because the skill was invoked.

### Step 2: Refresh relevant state

For general status, run `${CLAUDE_SKILL_DIR}/scripts/dashboard.sh` and show its
ASCII output verbatim in a fenced block. Then reconcile the local snapshot with
live upstream PR state using `gh`. Report open and draft PRs, active candidates,
tracker drift, stale or missing dossiers, and material recent gate events.

For a single candidate, refresh only that candidate's issue, competing PRs,
dossier freshness, and any linked PR. GitHub state outranks candidate
frontmatter when they disagree.

### Step 3: Require a current dossier and first-touch fit

Before claim, work, or submission, require the repository dossier named by the
candidate's `research_path`. If it is missing, older than 14 days, or lacks the
required fit fields, run the bundled researcher in build or refresh mode.

Read these dossier facts before selecting an artifact:

- `collaboration_surface`: `open`, `guarded`, or `closed`
- `counterparty_design_intent`
- `positioning_risk`: `none`, `adjacent-builder`, or `direct-competitor`
- `competing_license_fence`
- `local_test_fit`: `isolated`, `partial`, or `full-stack-only`
- `merged_prs_by_user` and rejection patterns

Use [submission policy](references/submission-policy.md) for the evidence and
decision rules. Never pitch as a gap something maintainers document as an
intentional choice or excluded threat.

### Step 4: Discover

Prefer existing candidates with `status: open` or `shortlist`, sorted by
`scout_score`. When the queue is thin or the user requests new work, run the
bundled scout in `baseline`, `refresh`, or a bounded ad-hoc mode. The scout owns
GitHub search, duplicate screening, scoring, candidate writes, and event-log
entries; summarize its candidate files rather than repeating its search.

For Wasteland federation work, read
[the federation contract](references/wasteland-federation.md) before proposing
a claim. Its Dolt `wl claim` and `wl done` lifecycle replaces GitHub issue
comments but still produces a GitHub PR.

### Step 5: Qualify

Before claiming, verify live:

```bash
gh pr list --repo OWNER/REPO --search "ISSUE_NUMBER" --state=all
gh api repos/OWNER/REPO/commits --jq '.[0:3] | map({date: .commit.author.date, message: .commit.message[0:60]})'
gh api repos/OWNER/REPO/contents/CONTRIBUTING.md --jq '.content' | base64 -d
```

Use the repo-analyzer for structured eligibility checks. Reject or pause when
there are competing active PRs, superseding work, stale maintainer engagement,
unresolved license constraints, a stack mismatch, or no honest way to meet the
local verification bar. Never fabricate an end-to-end test result.

### Step 6: Prepare a claim

Read `assets/claim-template.md`, adapt it to upstream tone, and run the
shortlist-to-claimed transition:

```bash
${CLAUDE_SKILL_DIR}/scripts/transition.sh shortlist→claimed CANDIDATE_FILE
```

If a gate blocks, report the gate ID, evidence, and fix. A gate override requires
the user's explicit instruction and a specific logged reason. Show the final
claim draft and wait for human approval. Never post `gh issue comment` or run
`wl claim` autonomously.

### Step 7: Work and verify

Read the upstream clone's instructions. Make only the agreed change and run its
native tests and linters. The test-runner may isolate verbose logs beneath
`~/.contribute-system/test-logs/`. Report exact commands, pass and failure
counts, duration, coverage when available, skipped checks, and the log path.

Do not push a fork until the local evidence passes. Do not force-push. Preserve
the upstream's branch, commit, DCO, AI-disclosure, generated-file, and vendoring
rules recorded in the dossier.

### Step 8: Prepare submission

Choose the first-touch artifact from `collaboration_surface`:

| Surface | First touch |
|---|---|
| `open` | Design Issue unless upstream explicitly asks for a direct small PR |
| `guarded` | Tiny mergeable PR, then a Design Issue after identity is banked |
| `closed` | Non-proposal micro-fix PR only; otherwise ship nothing |

Run the working-to-submitted gates before drafting:

```bash
${CLAUDE_SKILL_DIR}/scripts/transition.sh working→submitted CANDIDATE_FILE
```

Use `assets/pr-template.md` and the draft-writer to prepare the correct artifact.
Apply the trust ladder, positioning disclosure, attribution stripping, DCO, and
Omarchy rules in [submission policy](references/submission-policy.md).

Show the user the exact file list, test summary, title, and complete body. Wait
for explicit approval before creating any external issue, PR, review, comment,
or `wl done` update. After submission, record the returned PR number and URL in
the candidate file and append the event.

## Output

Lead with the requested result, followed by evidence and the next decision.

- **Status:** dashboard block, live GitHub differences, action-needed items
- **Discovery:** ranked candidates with score, fit, competition, and why now
- **Qualification:** `claim`, `wait`, or `skip` with decisive evidence
- **Claim:** exact draft plus gate receipt, awaiting approval
- **Work:** changed files and verification receipt
- **Submission:** exact issue or PR draft plus gate receipt, awaiting approval
- **Reconciliation:** counts of updated, unchanged, and unresolved candidates

Never describe a local candidate state as a live GitHub fact without checking
GitHub. Never describe a draft as posted.

## Error Handling

| Failure | Response |
|---|---|
| `gh` is unauthenticated or under-scoped | Stop; identify the failed operation and direct the user to `gh auth login` or scope refresh |
| GitHub rate limit or transient failure | Preserve local state; report that live reconciliation is incomplete and retry later |
| Candidate and GitHub disagree | Treat GitHub as authoritative and propose the exact local transition |
| Dossier missing, stale, or incomplete | Build or refresh with the researcher before claim or submission |
| Gate blocks | Surface gate ID, evidence, and remediation; never bypass silently |
| Test suite requires unavailable full stack | Run only an honest isolated check or reject the candidate as unverifiable |
| Runtime mirror has drifted | Run `${CLAUDE_SKILL_DIR}/scripts/doctor.sh`, then reinstall only after reviewing its findings |
| Any external action lacks approval | Stop at the draft boundary |

## Examples

- **“What is my PR status?”** Run the dashboard and live reconciliation, report
  drift and review blockers, then stop.
- **“Find a contribution.”** Refresh relevant state, invoke scout, qualify the
  strongest receivable candidates, and return ranked choices.
- **“Claim owner/repo issue 42.”** Verify dossier and competition, run gates,
  prepare the claim from the template, and wait for approval.
- **“Submit this fix.”** Run native verification and submission gates, select
  the artifact from collaboration posture, show the exact draft, and wait.

## Resources

- [Current end-to-end workflow](references/workflow-guide.md)
- [Repository intake and briefing](references/repo-intake.md)
- [Submission, trust, and approval policy](references/submission-policy.md)
- [Dashboard, reconciliation, audit, and recap operations](references/operations.md)
- [Candidate file schema](references/candidate-file-format.md)
- [Wasteland federation flow](references/wasteland-federation.md)
- [Named contribution anti-patterns](references/anti-patterns.md)
- Bundled agents: `agents/scout.md`, `agents/researcher.md`,
  `agents/draft-writer.md`, and `agents/test-runner.md`
- Templates: `assets/claim-template.md`, `assets/pr-template.md`, and
  `assets/evidence-template.md`

## Success Criteria

The workflow uses current live evidence, stays outside owned repositories,
selects work that is receivable and locally verifiable, passes deterministic
gates, preserves upstream conventions, exposes no credentials, and performs no
external submission without explicit human approval.
