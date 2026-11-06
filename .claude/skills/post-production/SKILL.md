---
name: post-production
description: "Brand finishing with Remotion: watermark, hook text, word-level subtitles, end-card CTA, loudness, safe zones and per-platform variants. Use when finishing a QA-passed render."
---

# Post-production (Remotion)

Templates live in `post/remotion/` (built in Phase 1) and are versioned in git. The agent supplies **props**, never edits template code during a run.

## Props (JSON passed to `scripts/remotion_render`)
`video_path`, `captions` (word timestamps from `scripts/transcribe`), `hook_text`, `on_screen_text[]`, `brand` (slug → colors, fonts, watermark, lower-third), `cta_keyword`, `end_card` (text + handle), `ai_disclosure_line`, `platform` (`instagram|tiktok|youtube|facebook|x|threads`).

## Rules
- **Hook text appears in the first second**, large, high-contrast, inside the safe zone.
- **Subtitles:** word-level highlight, max 2 lines, ≥ 90% of speech covered, synced to ±100 ms. Never add words that are not spoken.
- **Safe zones:** keep key text out of the top ~10% and bottom ~20% (platform UI), and the right rail on TikTok/Reels. Exact margins in `knowledge/platforms-*.md`.
- **Watermark:** small, semi-transparent, not on the extreme edge. Do not leave another platform's watermark in any variant.
- **End card:** short CTA with the keyword ("Comment WORKFLOW"). Make the ending loop back to the hook when possible.
- **Audio:** normalize to −14 LUFS integrated, true peak ≤ −1 dBTP; duck music under voice.
- **Disclosure:** keep the AI-persona disclosure line from `brands/<slug>/visual-identity.md` in the caption template or end card.
- **Variants:** render each platform's aspect, length cap and cover frame. 9:16, 1080×1920 by default.
- Embed C2PA content credentials in the export when the toolchain supports it.

## Checks before `finished`
Duration within spec · resolution/fps · loudness · caption sync spot-check at 3 points · watermark not clipped · no text in unsafe zones · file plays.

## Licensing notes
Remotion's commercial license terms depend on team size (TO CONFIRM). Fonts and music must be cleared for commercial use; log them in `knowledge/licenses.md`.
