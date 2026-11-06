---
name: publish-due
description: "Schedule and post human-approved final cuts that are due, via the publisher agent. Respects dry-run and the G3 gate."
disable-model-invocation: true
---

1. `scripts/store status --json`; `store budget`.
2. List concepts in `approved_cut` and whether G3 is approved or graduated. Items without G3 are reported, not posted.
3. Delegate to **publisher** with the IDs. In `MBM_DRY_RUN=1` it writes `pending` post rows and payloads only.
4. Report scheduled/posted/failed counts and any quota or policy errors.
5. Do not enable live posting here. Switching `MBM_DRY_RUN` to `0` is a deliberate human decision in the environment settings.
