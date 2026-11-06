---
name: cost-guard
description: "Spend control for the engine: ledger, per-video/day/endpoint caps, model routing, scale-to-zero GPU, and stop conditions. Use before any paid call and when reporting cost."
---

# Cost guard

## Before spending
`scripts/store budget` → exit 2 means stop and report. Never "just one more render".

## Caps (env defaults in `.claude/settings.json`; real values come from the owner)
| Cap | Env | Scope |
|---|---|---|
| Daily | `MBM_DAILY_BUDGET_USD` | all LLM + GPU + API |
| Per video | `MBM_VIDEO_BUDGET_USD` | one concept end to end |
| Endpoint | Comfy `--max` workers | hard concurrency ceiling (plan limits in `docs/COST-MODEL.md`) |
| Headless run | `--max-budget-usd` | one scheduled `claude -p` run |

## Model routing (aliases; tune after real cost data)
haiku: scouting, extraction, formatting, publishing, finishing · sonnet: scripts, QA judgment, funnel copy, analysis · opus/fable: only monthly strategy reviews on the user's request. Set `effort: low` for routers.

## Ledger
Every paid action writes `ledger(agent, kind, usd, units, ref)`: scripts write GPU and API rows from provider responses; headless runs log `total_cost_usd` from `--output-format json`. Do not estimate GPU cost yourself. Reconcile weekly against the Comfy console.

## Waste to avoid
Polling loops · re-analyzing a known URL hash · rendering before G1 · final-res before draft QA · unbounded retries (max 2) · pasting payloads into delegations · reading big files whole (use `store query` or line ranges).

## GPU specifics (Comfy API deployment; see `docs/COMFY-DEPLOY.md`)
`--min 0` scales to zero and bills no compute while idle; a flex worker bills from start (incl. model load) through the job plus ~30 s idle. `--min ≥ 1` bills continuously: use only inside a scheduled batch window, then scale back. Network storage bills while any deployment of the Build exists, even paused.

## Stop conditions
Budget exhausted · 3 consecutive render failures on one workflow (stop and flag the workflow) · ledger/provider mismatch > 10% · any policy-risk flag from `compliance-check`.
