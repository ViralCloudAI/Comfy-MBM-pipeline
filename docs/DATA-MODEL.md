# Data model (Supabase / Postgres)

Source of truth: `supabase/migrations/0001_init.sql` (applied and behavior-tested on Postgres 16: gates, leases, failure handling, budget caps, dedupe). This page explains it; if they disagree, the SQL wins. Change both together (`.claude/rules/schemas.md`).

## Tables
| Table | Purpose | Key columns |
|---|---|---|
| `brands` | personas/accounts | `slug`, `accounts{platform:[{account_id,handle}]}` |
| `autonomy` | which gates are graduated (human-controlled) | `gate`, `auto` |
| `budgets` | caps | `scope` day/video, `cap_usd` |
| `trends` | discovered videos | `url_hash` (unique per brand), `score`, `lifecycle`, `status` new/briefed/rejected |
| `trend_snapshots` | metric time series | `views…saves`, `usage_count`, `captured_at` |
| `briefs` | Trend Brief (hook, visual, audio, caption, hashtags…) | schema: `schemas/trend_brief.schema.json`; status new/scripted/needs_human |
| `funnels` | keyword → offer → flow spec | `keyword` unique per brand, `copy` (flow spec), `manychat_flow_id` |
| `concepts` | A/B/C video concepts | schema: `schemas/concept.schema.json`; `cta_keyword`, `comfy_recipe`, `status` |
| `gate_approvals` | human decisions per concept per gate | `gate`, `decision`, `approved_by` |
| `renders` | each Comfy attempt | `pass_type` draft/final, `idempotency_key`, `gpu_seconds`, `cost_usd`, `output_path`, `qa` |
| `finished_assets` | branded outputs | `storage_path`, `platform_variants` |
| `posts` | per-platform post | `blotato_submission_id`, `dry_run`, `ai_label`, `status` |
| `post_metrics` | per window | `metric_window` 1h/6h/24h/72h/7d |
| `leads` | DM funnel contacts | `stage`, `tags`, `source_post_id` |
| `ledger` | every paid action | `agent`, `kind` llm/gpu/api/storage, `usd`, `ref_table/ref_id` |
| `learnings` | engine memory | `scope`, `pattern`, `evidence_ids`, `status` hypothesis/confirmed/retired |
| `events` | audit log | `actor`, `event`, `payload` |

## Status machines (must match `CLAUDE.md`)
- trend: `new → briefed | rejected`
- brief: `new → scripted | needs_human`
- concept: `drafted →[G1]→ approved → rendering → rendered → qa_passed | qa_failed → finishing → finished →[G2]→ approved_cut →[G3]→ scheduled → posted → measured`; side states `killed`, `needs_human`
- render: `queued → running → succeeded | failed | cancelled`
- post: `pending → scheduled → posted | failed`

## Human gates are enforced by the database
A trigger refuses to move a concept into `approved` (G1), `approved_cut` (G2) or `scheduled` (G3) unless a matching `gate_approvals` row exists or that gate is graduated in `autonomy`. New concepts must be inserted as `drafted`. Violations raise SQLSTATE `P0001`.
- `approve_gate(gate, ids[], by)`: records approvals; for G1 and G2 also moves the status; for G3 only records the approval (the publisher does its own `approved_cut → scheduled`).
- `reject_gate(gate, id, by, reason)`: records the rejection and sets `killed`.
- Only the human reviewer key may call these. Agents get a restricted key (see hardening block at the end of the migration).

## Claim / advance / fail (leases)
`claim_rows(table, status, agent, limit, lease_min)` uses `FOR UPDATE SKIP LOCKED`; an expired lease frees the row. `advance_row` and `fail_row` require the caller to hold the lease (else SQLSTATE `P0002`). Claimable: `trends`, `briefs`, `concepts`, `posts`, `finished_assets`.

## `store` CLI exit-code mapping
`0` ok · `1` unexpected error · `2` blocked (SQLSTATE `P0001`: gate/whitelist, or `budget_status().blocked`) · `3` lease lost (SQLSTATE `P0002`).

## Budget and status
`budget_status(concept_id?)` returns day and (with a concept) video scopes with `blocked`. Views: `v_status`, `v_pending_gates`, `v_stale_leases`.

## Security
RLS is enabled on every table with **no policies**: anon/authenticated roles get nothing; the service role bypasses RLS. Never put the service key in the repo. Use the restricted agent key for agents and the reviewer key only in the human's interactive environment.

## Storage (create a private bucket `mbm-media`)
`{brand}/{concept_id}/{render_id}/{draft|final}.mp4` · `{brand}/{concept_id}/finished/{platform}.mp4` · `{brand}/transcripts/{url_hash}.json`. Store paths in tables, never signed URLs.

## Semantic memory (later)
Enable pgvector, add `embedding vector(…)` to `briefs` and `learnings`, and index with HNSW for "nearest past hooks/formats". Do this only when `store query` keyword search stops being enough.
