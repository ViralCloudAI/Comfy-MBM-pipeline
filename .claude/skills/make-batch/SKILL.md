---
name: make-batch
description: "Produce content from what is ready: script briefs, render approved concepts, finish QA-passed renders. Stops at human gates."
disable-model-invocation: true
argument-hint: "[max_videos]"
---

1. `scripts/store status --json`; `store budget` (stop on exit 2).
2. In order, each only if its input is non-empty, delegating IDs with a count cap (default 3 concepts):
   - **scriptwriter**: briefs with no concepts → concepts `drafted`.
   - **studio**: concepts `approved` (human G1 already done) → `qa_passed`.
   - **finisher**: concepts `qa_passed` → `finished`.
3. Concepts waiting on G1 or G2 are reported with their IDs and a pointer to `/review`.
4. Report: videos produced, failures with reasons, GPU seconds and cost vs `MBM_VIDEO_BUDGET_USD`.

Scheduled use: run nightly inside a GPU batch window; scale the Comfy deployment's `--min` back to 0 afterward (see `docs/COMFY-DEPLOY.md`).
