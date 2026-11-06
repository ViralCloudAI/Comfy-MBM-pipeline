---
name: brand-voice
description: "Background card for loading the active persona's voice, visual identity, banned list and CTA library from brands/<slug>/ without re-reading everything. Use when writing any persona-facing copy or script."
user-invocable: false
---

# Active brand

Active slug: `$MBM_ACTIVE_BRAND` (default `_template`). Files in `brands/<slug>/`:

| File | Load when |
|---|---|
| `persona-bible.md` | writing scripts, concepts, bios (identity, backstory, pillars, relationships, never/always) |
| `voice.md` | any copy: tone, vocabulary, sentence rhythm, catchphrases, emoji policy |
| `visual-identity.md` | briefing shots, templates, thumbnails, the AI-disclosure line |
| `banned.md` | **always** before saving a concept (authoritative) |
| `cta-library.yaml` | picking a `cta_keyword` (one keyword → one funnel) |

## Rules
- Read each file once per task, not per item. Keep a mental 10-line summary.
- The persona is an ORIGINAL AI character. Disclose it plainly in bios and captions. Never mimic a real person.
- If `brands/<slug>/` is still the template, say so and use neutral voice; do not invent persona facts.
- `banned.md` wins over any trend, hook or pattern.
