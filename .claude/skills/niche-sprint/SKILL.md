---
name: niche-sprint
description: "Pick the engine's niche from data: run discovery over 5-6 candidate niches for 7 days and rank them on trend supply, remixability, saturation, monetization fit and policy risk."
disable-model-invocation: true
argument-hint: "[niche1,niche2,...]"
---

Goal: choose 1 primary + 1 test niche with evidence, not taste. Output goes to `knowledge/niche-selection.md`.

## Setup
Candidates (default if none given): AI creators/tech · entertainment/memes/pop culture · lifestyle/fashion/fitness/beauty · plus up to 3 the user names.

## Run (daily for 7 days, discovery only: no briefs, no scripts, no renders)
1. Delegate **scout** per niche with `--discovery-only`: collect candidates, snapshots and scores; skip briefing.
2. Log per niche per day: candidates above threshold, median score, median saturation, share of `originality_risk=high`, share of `brand_safety!=ok`.

## Score each niche (0–5, weights adjustable)
| Criterion | Weight | Evidence |
|---|---|---|
| Trend supply | 25% | rising, under-saturated candidates per day |
| Remixability with an original persona | 20% | share with `originality_risk=low` |
| Saturation headroom | 15% | median `sat` |
| Monetization fit | 20% | see `knowledge/monetization.md` (products, agency, brand deals, affiliate) |
| Policy and brand-safety risk (inverse) | 10% | share `brand_safety=ok` |
| Audience AI-tolerance | 10% | comment sentiment about AI content in the niche (sample) |

## Deliverable
Ranked table with scores and evidence, a recommended primary + test niche, the monetization emphasis that follows, and 3 persona angles per niche. The **human decides**; then update `brands/<slug>/persona-bible.md` and `MBM_ACTIVE_BRAND`.
