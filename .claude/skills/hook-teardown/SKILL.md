---
name: hook-teardown
description: "Extract hook, visual, URL, caption, audio, hashtags and keywords from a trending video into a structured Trend Brief row. Use after a trend is claimed and before scripting."
---

# Hook teardown → Trend Brief

Fill every field of `schemas/trend_brief.schema.json`. Be cheap: sample, don't watch everything.

## Method
1. `scripts/transcribe` on the audio → transcript with word timestamps (cache by `url_hash`).
2. Sample 6–8 frames (first frame, ~1 s, 3 s, then evenly) and describe them in one pass (vision). Never send the full video.
3. Parse caption, hashtags, and audio metadata from the scraped record.

## Fields
| Field | How |
|---|---|
| `url` | canonical URL (already in the trend row) |
| `hook_text` | first line spoken or shown, verbatim (≤ 3 s of content) |
| `hook_type` | one of: pattern_interrupt, open_loop, bold_claim, relatable_pov, tutorial_promise, contrarian, curiosity_gap, transformation, social_proof, other |
| `hook_seconds` | when the hook lands (target ≤ 3) |
| `visual_desc` | setting, subject, camera, motion, color, text style (≤ 60 words) |
| `shot_list` | `[ {t, desc, text_on_screen} ]`, ≤ 10 entries |
| `audio_id`, `audio_title`, `audio_type` | `original`, `licensed`, or `unknown` |
| `caption`, `hashtags[]`, `keywords[]` | verbatim caption; hashtags parsed; 5–10 search keywords |
| `format_label` | short reusable name ("POV: you finally…", "split-screen reaction") |
| `why_it_works` | the share/comment/save trigger in one sentence |
| `originality_risk` | how identifiable the creator's expression is: `low|medium|high` (high = distinctive performance/character; do not remix 1:1) |
| `brand_safety` | `ok|review|block` |

## Quality bar
- `why_it_works` must name a viewer behavior (share because…, comment because…, save because…).
- If the format depends on a specific person's identity or a copyrighted character, set `originality_risk=high` and `brand_safety=review`.
- Record what you could not determine as `null`; never guess audio rights.
