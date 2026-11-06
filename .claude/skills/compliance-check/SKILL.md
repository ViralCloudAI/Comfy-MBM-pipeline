---
name: compliance-check
description: "Fail-closed checklist for originality, likeness and copyright, brand safety, claims, AI disclosure, platform policy and banned topics, at concept stage and publish stage. Use before saving a concept and before scheduling a post."
---

# Compliance check (fails closed)

Return JSON: `{"stage":"concept|publish","pass":true|false,"issues":[{"code","detail","fix"}]}`. Any unresolved issue → `pass=false`. When unsure, fail and say why.

## Concept stage
| Code | Check |
|---|---|
| ORIG | Script, shots, performer, audio are original; only the *format idea* is borrowed. Source `originality_risk=high` ⇒ no 1:1 remix |
| LIKE | No real person's face, voice, name, signature mannerism or identifiable likeness; no copyrighted character |
| MUSIC | Audio is original or cleared for the platform. Trending sounds only as a flagged, human-added option |
| SAFE | Not tied to tragedy, politics, hate, harassment, NSFW, minors, or dangerous acts. Sensitive ⇒ `review` |
| CLAIM | No medical, financial, legal or income claims; no fake testimonials or fabricated results |
| BANNED | Nothing on `brands/<slug>/banned.md` |
| CTA | Keyword unique and mapped; opt-in language present in the funnel |

## Publish stage (adds)
| Code | Check |
|---|---|
| DISC | AI-generated disclosure set where the platform/API supports it; persona bio line present |
| VAR | Caption differs per platform; not byte-identical to any prior post |
| PLAT | Meets `knowledge/platforms-*.md` limits (length, hashtags, aspect ratio, duration) |
| ACCT | Target account belongs to the brand |
| GATE | Required human approvals exist (the store enforces; report if missing) |
| VOL | Posting cadence within the brand's cap (avoid templated mass-production patterns) |

## Policy background (details in `knowledge/compliance.md`)
Instagram and TikTok reduce reach for mostly-unoriginal accounts; YouTube evaluates "inauthentic content" at channel level; platforms auto-label AI media via metadata (C2PA). A watermark does not make content original.

## Escalation
`pass=false` twice for the same concept → mark it `needs_human` and stop.
