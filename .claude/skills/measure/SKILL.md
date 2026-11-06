---
name: measure
description: "Run the analyst on posts with due metric windows; update learnings; on weekly runs refresh winning-patterns.md, prune memory and produce the cost report."
disable-model-invocation: true
argument-hint: "[weekly]"
---

1. `scripts/store query` for posts whose 1h/6h/24h/72h/7d windows are due. If none, say so and stop.
2. Delegate to **analyst** with the post IDs (or `weekly` for the full weekly routine).
3. Print its summary: measured posts, new/updated learnings, cost per approved video, and any autonomy-graduation *proposal* (never apply one).
