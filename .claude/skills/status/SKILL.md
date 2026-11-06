---
name: status
description: "Show pipeline status: counts per status, pending human gates, budget left, stale leases."
disable-model-invocation: true
---

Run `scripts/store status --json` and print a compact summary (≤ 20 lines):

1. Counts per status for `trends`, `briefs`, `concepts`, `posts`.
2. **Pending gates:** G1 (drafted), G2 (finished), G3 (approved_cut awaiting schedule), with counts and the oldest age.
3. Budget: spent vs `MBM_DAILY_BUDGET_USD` today; `MBM_DRY_RUN` state.
4. Stale leases and failed items from the last 24 h.
5. One recommended next action (e.g., "12 concepts await G1: run /review").

Do not delegate, do not change anything. If `scripts/store` does not exist yet, say the tools are not built (Phase 1) and show the roadmap phase from `docs/ROADMAP.md`.
