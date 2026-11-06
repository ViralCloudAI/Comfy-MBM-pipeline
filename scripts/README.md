# Scripts: CLI contracts (v0)

**Status: contracts only.** Skills and agents are written against these interfaces. Phase 1 implements them (Python 3.11+, one executable per file without extension, tests in `tests/`). Until then `/status` reports "tools not built".

## Conventions (all scripts)
- JSON to **stdout** only, compact; logs and progress to **stderr**. Never print secrets.
- Exit codes: `0` ok · `1` unexpected error · `2` blocked (budget cap, missing gate, whitelist) · `3` lease lost / conflict.
- Honor `MBM_DRY_RUN=1`: any external-effect command must do nothing, print `{"dry_run":true,...}`, and exit 0.
- Idempotent where possible; safe to re-run after a crash.
- Config from env (`.env.example`); never from arguments that could leak into logs.
- Every paid action writes a `ledger` row.

## `scripts/store` (Supabase)
```
store status [--json|--brief]
store claim <table> --status S --agent A [--limit 10] [--lease-min 30]   -> {"ids":[...]}
store get <table> <id>
store put <table> --json <file|->                                        -> {"id":"..."}
store advance <table> <id> --agent A --to STATUS
store fail <table> <id> --agent A --reason "..." [--to STATUS]
store query "<SELECT ...>" [--limit 200]                                  # read-only, row-capped
store budget [--concept <id>] [--json]                                    # exit 2 when blocked
store ledger add --agent A --kind llm|gpu|api|storage --usd X [--units N --unit-label L --ref table:id --note ...]
store approve <G1|G2|G3> <id...> --by <name>                             # reviewer key only
store reject  <G1|G2|G3> <id> --by <name> --reason "..."                 # reviewer key only
```
Maps to SQL functions `claim_rows`, `advance_row`, `fail_row`, `budget_status`, `approve_gate`, `reject_gate`. SQLSTATE `P0001` → exit 2; `P0002` → exit 3.

## `scripts/comfy_run` (Comfy SDK; backend by `MBM_COMFY_BACKEND`)
```
comfy_run submit --concept <id> --pass draft|final [--workflow NAME] [--seed N] [--param title=value ...]
    -> validates against the workflow contract; creates a `renders` row with an idempotency key;
       submits with job metadata {concept_id, render_id}; {"render_id","job_id","dry_run"}
comfy_run wait   <render_id> [--timeout-min 30]     # blocks (poll-first); on success re-hosts output to Storage;
                                                    # writes gpu_seconds/cost/output_path; {"status","output_path","gpu_seconds","cost_usd"}
comfy_run status <render_id>
comfy_run qa     <render_id>                        # deterministic checks (duration/res/fps/audio/readable) + sampled frame paths for the model's judgment
```

## `scripts/transcribe`
`transcribe <video|audio path> --out <path> [--cache-key url_hash]` → word-level timestamps JSON (WhisperX or equivalent); skips if cached.

## `scripts/remotion_render`
`remotion_render --asset <render_id> --template NAME --props <json|file> --platform instagram|tiktok|youtube|facebook|x|threads` → writes platform variant, loudness-normalized (−14 LUFS), returns `{"storage_path","duration_s","checks":{...}}`.

## `scripts/metrics_pull`
`metrics_pull --post <id> --window 1h|6h|24h|72h|7d` → writes `post_metrics`; `{"views",...}`. Source: Blotato/platform APIs.

## `scripts/manychat`
```
manychat sync-leads [--since ISO]      # subscribers/tags/custom fields -> `leads`
manychat set-field --handle H --field F --value V      # dry-run by default
manychat trigger-flow --handle H --flow ID             # dry-run by default; only inside Meta's window
manychat digest                        # conversations needing a human
```
Flow creation/editing is not supported by the public API (TO CONFIRM): humans build flows from `data/funnel-build-sheets/`.

## Tests (Phase 1)
Contract tests per script against mocked services · SQL behavior tests (the Phase 0 harness in this repo's history is the template) · golden-clip regression for workflows · dry-run assertions (no network on `MBM_DRY_RUN=1`).
