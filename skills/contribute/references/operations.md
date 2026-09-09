# Contribution Operations

## Dashboard and live reconciliation

Run the local dashboard first:

```bash
${CLAUDE_SKILL_DIR}/scripts/dashboard.sh
```

Print its output verbatim in a fenced block. It reads candidate files, dossiers,
and `log.jsonl`; it does not establish current GitHub state.

Then query open and recently closed PRs authored by the authenticated user.
Exclude repositories owned by `jeremylongshore` and `intent-solutions-io`.
Compare live results to candidate status and report:

- open and draft upstream PRs
- claimed or working candidates without a submitted PR
- top open or shortlisted candidates by score
- merged or closed PRs whose candidate status has drifted
- candidates with missing or stale dossiers
- recent blocks and overrides requiring attention

Do not silently mutate drift during a status-only request. For an explicit
reconciliation request, update candidate files atomically and summarize the
before and after states.

## Override audit

Use the bundled reporter:

```bash
${CLAUDE_SKILL_DIR}/scripts/audit-overrides.sh
${CLAUDE_SKILL_DIR}/scripts/audit-overrides.sh --since=30
${CLAUDE_SKILL_DIR}/scripts/audit-overrides.sh --scope=org:OWNER
${CLAUDE_SKILL_DIR}/scripts/audit-overrides.sh --gate=GATE_ID
${CLAUDE_SKILL_DIR}/scripts/audit-overrides.sh --json
```

Surface override count, block count, override rate, and dominant reason by
gate. Repeated overrides indicate either a miscalibrated gate or a recurring
risk; they are not evidence that the gate should be ignored.

## Daily recap

`scripts/contribute-daily-recap.sh` deterministically renders the existing
state and reporters as an HTML recap. No model belongs in its correctness path.

```bash
${CLAUDE_SKILL_DIR}/scripts/contribute-daily-recap.sh --dry-run
${CLAUDE_SKILL_DIR}/scripts/contribute-daily-recap.sh
${CLAUDE_SKILL_DIR}/scripts/contribute-daily-recap.sh --window=8 --to="RECIPIENTS"
```

The report includes action-needed items, pipeline state, in-flight work, a
bounded event window, and the seven-day override trend. A quiet heartbeat is
valid only after successful state reads; a read failure must surface as an
alert, not an empty day.

Emailing is an external action. Dry-run by default unless the user explicitly
requested delivery or an already-authorized scheduled invocation is running.

## Runtime drift

The deployed mirror under `~/.contribute-system/bin/` may lag the repository.
Run `${CLAUDE_SKILL_DIR}/scripts/doctor.sh` to compare it. Review findings before
using `bin/install.sh --force`; never overwrite a runtime merely because a
script returned an unexpected result.
