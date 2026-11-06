# Runbook

## Daily
1. `/status`: pending gates, budget, stale leases, failures.
2. `/review`: clear G1 (concepts), G2 (final cuts), G3 (publish).
3. Scheduled runs handle scouting, batches, publishing and measurement (`docs/ARCHITECTURE.md`).

## Kill switch (any time)
1. Set `MBM_DRY_RUN=1` in the environment (stops posting, DMs, paid renders at the script layer).
2. Disable scheduled tasks / workflows that call `claude -p`.
3. `comfy deploy stop --deployment <id>` (retains the deployment; storage still bills) or `scale --min 0 --max 0` per current docs.
4. In ManyChat, unpublish flows if DMs must stop.
5. Record the reason in `events`.

## Budget exceeded
`store budget` exits 2 → agents stop. Review `ledger` by agent/kind for the day; raise `budgets` only on purpose.

## Stuck work
`select * from v_stale_leases;` Expired leases return rows to the pool automatically on the next claim. If a row is stuck in `rendering` with no render: check `renders`, the Comfy console, then `store fail … --to qa_failed` with a reason.

## Render problems
- 3 consecutive failures on one workflow: stop the batch, inspect `comfy deploy logs|events`, check the latest release and credits, re-run golden clips.
- 422 `idempotency_key_reuse`: the job already exists; fetch it by `job_id`.
- Deployment stopped: credits ran out; top up, then `comfy deploy start`.

## Posting problems
Quota or policy error → publisher backs off. Never retry in a tight loop. Instagram: check `content_publishing_limit`. TikTok unaudited: posts are private only.

## Policy incident (warning, reach collapse, strike)
Stop publishing on that platform. Export the last 14 days of `posts` + `post_metrics`. Review the originality and disclosure checks that passed. Revert any graduated gate (`autonomy.auto=false`). Resume only with a written change.

## Change log (append)
| Date | Change | Who |
|---|---|---|
| 2026-11-06 | Harness scaffold created (Phase 0) | |
