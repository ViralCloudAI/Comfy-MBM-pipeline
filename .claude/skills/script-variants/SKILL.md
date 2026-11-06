---
name: script-variants
description: "Write 3 original-persona video concepts from a Trend Brief: A faithful format remix, B persona twist, C niche or contrarian angle, each with script, shots, caption, hashtags and CTA keyword. Use when a brief needs concepts."
---

# Script variants (A / B / C)

Re-stage the trend's **hook pattern, structure and pacing**. Never reuse the source's footage, dialogue, performer or distinctive creative expression.

| Variant | What changes | Purpose |
|---|---|---|
| **A faithful remix** | Same format and beats; persona, setting, wording all original | ride the trend safely |
| **B persona twist** | The persona's lore/personality bends the format | build brand memory |
| **C niche / contrarian** | Apply the format to the niche's pain point, or flip the premise | earn comments and shares |

## Each concept contains (match `schemas/concept.schema.json`)
`variant`, `title`, `hook_line` (lands ≤ 3 s), `beats[]` (timed), `shot_list[]`, `voiceover`, `on_screen_text[]`, `caption`, `hashtags[]`, `audio_plan` (default: original audio; trending sound only as a flagged option), `cta_keyword` (from `cta-library.yaml`), `comfy_recipe` (`workflow`, `params`), and `engagement_trigger` (share | comment | save + why).

## Craft rules
- One idea per video. Hook first, payoff last, and end so the loop re-watches.
- Write for sound-off: on-screen text carries the story.
- Share trigger: "send this to someone who…"; comment trigger: a low-effort question or the CTA keyword; save trigger: a list or a "come back to this".
- Test length buckets (≈7 s, ≈15 s, ≈30 s) across batches. Don't assume one is best.
- Prefer shots the render pipeline does well (see `workflows/contracts/`). No hands-on-object close-ups if the workflow struggles with them.
- Read `knowledge/winning-patterns.md` for what has worked; treat entries marked `hypothesis` as experiments.

## Originality checklist (must all be true)
Different script text · different shots · different performer (persona) · different audio · same *format idea* only. If you cannot make A original, drop A and write two stronger variants.

## Then
Run `compliance-check`. Save passing concepts as `drafted`. They wait for human gate G1.
