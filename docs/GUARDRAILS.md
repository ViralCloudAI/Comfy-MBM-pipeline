# Guardrails

Layered, because instructions alone are not enforcement ("Claude treats CLAUDE.md as context, not enforced configuration").

| Layer | Mechanism | Phase |
|---|---|---|
| 1 Database | Gate trigger on `concepts`; lease checks; `budget_status()`; RLS on all tables | 0 (in the migration) |
| 2 Permissions | `.claude/settings.json` allow/deny rules (no `.env` reads, no force-push, no `rm -rf`) | 0 |
| 3 Dry-run default | `MBM_DRY_RUN=1` in settings; every external-effect script no-ops and says so | 0 (env), 1 (scripts) |
| 4 Hooks | Deterministic pre-tool checks (below) | 1 |
| 5 Keys | Agents use a restricted DB key; only the human reviewer key can call `approve_gate`/`reject_gate` | 1 |
| 6 Prompts | Hard rules restated in each agent file | 0 |

## Hooks to enable in Phase 1
`docs/guardrails/settings.hooks.example.json` shows the structure (events `PreToolUse`, `SessionStart`; commands receive tool input as JSON on stdin; **exit code 2 blocks the call** and returns stderr to the model). Merge it into `.claude/settings.json` when the scripts below exist.

| Hook script (to write) | Event / matcher | Behavior |
|---|---|---|
| `.claude/hooks/pre-bash-guard.sh` | PreToolUse / Bash | On `comfy_run submit` run `scripts/store budget`; exit 2 if blocked. On commands that post, DM, or scale GPU while `MBM_DRY_RUN=1` and without an explicit `--dry-run`, exit 2. Block `store approve`/`reject` unless the caller is the interactive human session (**TO CONFIRM**: whether hook input identifies the subagent) |
| `.claude/hooks/block-secrets.sh` | PreToolUse / Read\|Bash | Block reads of `.env*` and printing of env vars containing KEY/TOKEN/SECRET |
| status summary | SessionStart / startup | Print `scripts/store status --brief` so the orchestrator starts with state, no tool call |

## Pre-approved vs prompted
Allowed without prompts: `scripts/store`, `comfy_run`, `transcribe`, `remotion_render`, `metrics_pull`, `manychat`, read-only git. Everything else prompts (interactive) or is denied (`--permission-mode dontAsk` in headless runs). Headless runs are non-interactive: anything not allow-listed fails safe.

## Headless safety flags
`--permission-mode dontAsk` · `--allowedTools` limited to the scripts above · `--max-budget-usd N` · `--output-format json` (log `total_cost_usd` to `ledger`). Do not use `--bare` for pipeline runs: it skips project hooks, settings, agents and skills.

## Human-only controls
`autonomy`, `budgets`, `MBM_DRY_RUN`, ManyChat flow publishing, Comfy deployment create/delete, and gate approvals.
