---
name: scout-sweep
description: "Delegate one discovery run to the scout agent to find rising, unsaturated trends and create briefs."
disable-model-invocation: true
argument-hint: "[niche or keywords] [max_candidates]"
---

1. `scripts/store budget`; stop on exit 2.
2. Delegate to **scout** with: niche/keywords from the arguments (or the active brand's pillars), candidate cap (default 25), the budget cap, and the `MBM_DRY_RUN` state. IDs and caps only.
3. Print scout's ≤ 10-line summary plus the count of new briefs ready for the scriptwriter.
4. Do not start scripting automatically unless the user asked for `/make-batch`.
