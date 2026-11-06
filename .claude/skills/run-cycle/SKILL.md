---
name: run-cycle
description: "Run one full orchestrator cycle: read status, delegate the minimum stage runs by ID, and write a short cycle report."
disable-model-invocation: true
argument-hint: "[max_budget_usd]"
---

Run one cycle as the orchestrator:

1. `scripts/store status --json`. If the budget is exhausted or `store budget` exits 2, report and stop.
2. Apply the routing table in the orchestrator definition. Skip stages with empty input.
3. Delegate by ID, independent stages in parallel: scout → scriptwriter → studio → finisher → publisher → funnel → analyst, each only if its input status is non-empty.
4. Respect human gates: items waiting on G1/G2/G3 are listed, not advanced.
5. Cycle report (≤ 15 lines): advanced / failed / spend vs budget / pending gates / next action.

If the user passed a budget, treat it as the cap for this cycle. Honor `MBM_DRY_RUN`. Prefer the narrower entry skills (`/scout-sweep`, `/make-batch`, `/publish-due`, `/measure`) for scheduled runs; they waste fewer tokens than a full cycle.
