---
name: metrics-loop
description: "Measure posts at 1h/6h/24h/72h/7d, compare to baselines, call winners and losers, write learnings, curate winning-patterns.md, propose autonomy graduation and prune memory. Use for measurement and weekly review."
---

# Metrics loop

## Windows and metrics
Pull at **1h, 6h, 24h, 72h, 7d** (`scripts/metrics_pull` → `post_metrics`): views, avg watch %, completion %, 3-s hold if available, likes, comments, shares, saves, follows. Funnel: comments with keyword, DMs started, leads, customers, revenue.

## Baselines
Rolling median per (brand, platform, age window) over the last 30 posts. Until 30 posts exist, compare only against the brand's first-week median and label results `hypothesis`.

## Calls
- **Winner:** ≥ 2× baseline on views **and** share-rate or follows/1k views above baseline at the 24 h window.
- **Loser:** < 0.5× baseline on views at 24 h.
- Everything else: no call. Do not over-interpret one post.
- Minimum evidence for `confirmed`: ≥ 5 posts sharing the pattern, ≥ 2 winners and the pattern absent from losers. Otherwise `hypothesis`.

## Learnings (`learnings` rows)
Scope: hook | format | voice | timing | funnel | platform | trend. Fields: pattern, evidence post IDs, confidence, status (`hypothesis|confirmed|retired`). Retire contradicted learnings; never delete evidence.

## Experiment policy (simple bandit)
~80% of the batch uses confirmed winners, ~20% tests hypotheses (new hook types, lengths, voices, posting times). Tell `scriptwriter` via `winning-patterns.md`.

## `knowledge/winning-patterns.md`
≤ 100 lines, sections: Hooks · Formats · Voice · Timing · Funnel · Avoid. Each line: pattern → evidence count → status. Only `analyst` edits it, weekly.

## Cost view
Per approved video and per posted video: LLM + GPU + storage from `ledger`; revenue per 1k views from the funnel. Flag videos whose cost exceeds `MBM_VIDEO_BUDGET_USD`.

## Autonomy graduation (propose only; the human changes `autonomy`)
| Gate | Propose automation when |
|---|---|
| G1 concept | ≥ 90% of the last 50 concepts approved unedited |
| G2 final cut | auto-QA verdict matches human verdict ≥ 95% over the last 100 videos, zero policy flags |
| G3 publish | G1 and G2 automated for 30 days and reach/strike metrics stable |
Circuit breaker: recommend reverting a gate if reach drops > 50% vs baseline for 3 days, any platform warning appears, or QA disagreement exceeds 10%.

## Memory hygiene (weekly)
Every agent's `.claude/agent-memory/<agent>/MEMORY.md` > 150 lines → summarize into a short index plus topic files. Keep evidence in the store.
