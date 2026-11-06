# Compliance

Not legal advice. Have counsel review before monetizing. Confidence tags: **[secondary]**, **[TO CONFIRM]**.

## 1. Originality (the main platform risk)
- Instagram: accounts mostly posting unoriginal content are reportedly not recommended to non-followers. **[secondary]**
- TikTok: stricter enforcement on unoriginal content since 15 Sep 2025; a logo or watermark doesn't make copied content yours. **[secondary]**
- YouTube: "inauthentic content" (mass-produced, repetitive, templated) is judged at channel level. **[secondary]**
- **Engine policy:** every video has an original script, persona, shots and audio. Only the *format idea* is borrowed. The `compliance-check` skill fails closed on this.

## 2. Copyright and likeness
- Do not reuse third-party footage, dialogue, performers or distinctive creative expression without a license or permission.
- Character-swapping someone else's performance onto your persona still copies their performance; treat third-party footage as a *reference for structure only* unless licensed.
- No real person's face, voice, name or mannerism. No copyrighted characters. Persona is original.
- Music: original audio by default; trending/licensed sounds only when the platform and rights allow, and as a human-added step.

## 3. AI disclosure
- Set platform AI-generated labels where available; state "AI character" in bios and caption templates.
- Platforms auto-label AI media from metadata (C2PA/IPTC); don't strip it. Embed C2PA in exports when possible. **[secondary]**

## 4. Messaging and privacy
- DMs are user-initiated only; respect windows, caps and STOP requests (`dm-funnel`).
- Collect minimum lead data; record opt-in; support deletion (GDPR/CCPA). No payment or health data in the store.

## 5. Advertising and claims
- No medical, financial, legal or income claims; no fake testimonials, reviews or fabricated results.
- Sponsored content and affiliate links must be disclosed using platform tools and applicable law (e.g., FTC endorsement guidance in the US).

## 6. Brand safety
Skip trends tied to tragedy, politics, hate, harassment, NSFW, minors, dangerous acts. Sensitive items go to `review`, never auto-post.

## 7. Account safety
Business accounts per platform; no multi-account farming; no purchased engagement; capped posting frequency; kill switch (`docs/RUNBOOK.md`).

## 8. Model and asset licenses
See `knowledge/licenses.md`. Nothing ships to a monetized account with an unresolved license.

## 9. Data collection
Official APIs first; vendor scrapers for public metadata only; no logins; keep a source registry with ToS-risk ratings; store metadata and URLs, not third-party video.

## 10. If a product accepts user faces (future, separate project)
Different regime from the engine's original persona: consent, prohibited-content screening, provenance marking, takedown and abuse handling are required before launch. Orientation and open points are in `docs/PRODUCT-VISION.md`. Nothing in this repo should process third-party user faces.
