---
name: viral-radar
description: "Find short-form trends that are rising but not yet saturated: sources, snapshot cadence, scoring formula, saturation and lifecycle labels, dedupe. Use when discovering or ranking trending content."
---

# Viral radar

Goal: catch content in the **accelerating, under-saturated** window (age ≲ 48 h), not the top of the chart.

## Sources (record each in the run notes with its ToS-risk rating)
| Source | Use | Notes |
|---|---|---|
| TikTok Creative Center (via Apify-class actors) | trending hashtags, sounds, videos by country/period | rankings and curves only; no velocity, so snapshot yourself |
| Apify platform scrapers (TikTok/Instagram/YouTube public pages) | per-video metrics, creator size, sound IDs | public data only; restrict the MCP to named actors |
| YouTube Data API | recent Shorts by query, `mostPopular` | official; quota-limited |
| Reddit API, Google Trends | early meme/topic signals | cross-platform confirmation |
Instagram has no public trending API. Use vendor data plus your own tracking. No logins, no private data.

## Snapshot cadence
t0, +1 h, +3 h, +6 h, +24 h per candidate (`trend_snapshots`: views, likes, comments, shares, saves, `usage_count` of the audio/format). Velocity needs ≥ 2 snapshots.

## Score (defaults; calibrate on the first 30 days of data)
```
v   = Δviews / Δhours (latest two snapshots)
a   = v_now / max(v_prev, 1)
out = views / max(creator_followers, 1000)
ss  = (shares + saves) / max(views, 1)
sat = unique_creators_using_same_audio_or_format_last_7d / SAT_CEILING   (default 500)
score = log10(1+v) * min(a,3) * sqrt(min(out,50)) * (1 + 10*ss) * (1 - min(sat,0.95))
```
Keep candidates with `age ≤ 48 h` (accept ≤ 96 h if `a ≥ 1.5`), `sat < 0.6`, and score in the top slice you were told to keep.

## Lifecycle label
emerging (few creators, a > 1.5) · rising (a > 1, sat < 0.3) · peak (a ≈ 1, sat > 0.6) · declining (a < 1). Only `emerging` and early `rising` are briefed.

## Dedupe and cache
`url_hash = sha256(normalized canonical URL)`. Skip any hash in `trends`. Never re-analyze. Same sound/format cluster → keep the earliest strong exemplar plus the one with the best share/save ratio.

## Reject reasons (write one line)
saturated · too old · low outlier · brand-unsafe · sensitive event (tragedy, politics, hate) · duplicate format · not remixable with the persona.

## Output
`trends` rows (`status=new`) with `score`, `lifecycle`, metrics snapshots, and `meta.source`. Rejects get `status=rejected` + reason.
