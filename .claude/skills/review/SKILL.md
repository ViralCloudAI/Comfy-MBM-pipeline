---
name: review
description: "Human approval gates. List items waiting at G1 (concept), G2 (final cut) and G3 (publish); apply exactly the approvals or rejections the user states."
disable-model-invocation: true
argument-hint: "[G1|G2|G3]"
---

This skill is how a **human** approves work. Agents never run it and never approve on their own.

## Procedure
1. `scripts/store status --json`, then list pending items for the requested gate (all gates if none given): short numbered rows with `id`, title/hook, variant, compliance result, cost so far, and a link/path to the artifact (script text for G1, storage URL for G2/G3). ≤ 25 rows per call.
2. Ask the user which to approve/reject. **Wait for their explicit reply** in this conversation, e.g., "approve 1,2,5; reject 3 (too close to the source); edit 4".
3. Apply exactly that: `scripts/store approve <G1|G2|G3> <ids> --by <user>` and `scripts/store reject <G> <id> --reason "..."`. Never approve items the user did not name. Never infer approval from silence.
4. For edits, update the concept text via `store put`/`advance` as instructed and re-run `compliance-check`.
5. Confirm what changed (counts and ids) and what the next stage will pick up.

`store approve` uses the human reviewer key (`SUPABASE_REVIEWER_KEY`), which must not be present in scheduled or headless runs.
