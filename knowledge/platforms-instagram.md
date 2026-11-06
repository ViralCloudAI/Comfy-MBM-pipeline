# Instagram (Reels + messaging)

Confidence tags: **[official]** from Meta docs (via search snippets), **[secondary]** vendor/blog reports, **[TO CONFIRM]** must be checked before relying on it.

## Publishing
- Reels publish through the Graph API Content Publishing flow: create a media container, then publish. **[official]**
- `GET /<IG_ID>/content_publishing_limit` shows current publishing-rate usage; check it before scheduling. **[official]**
- The daily cap is reported inconsistently (about 50 Reels/24 h in some guides, 100 posts/24 h total in others); the limit is enforced at publish time (error subcode 2207042 reported). Trust the endpoint, not a number. **[secondary / TO CONFIRM]**
- Account type support (Business vs Creator) is disputed across sources. Use a professional account that the tool you choose supports. **[TO CONFIRM]**
- Through Blotato: which Instagram account types and scheduling features it supports. **[TO CONFIRM]**

## Audio
- Meta documents an **Audio API** to search audio (trending audio is returned when no query is given) and attach a track to a Reel; it applies only to the *Instagram API with Facebook Login*, not Instagram Login. **[official]**
- Scheduling tools widely report that trending/licensed music can't be attached via API; use original audio by default and a "draft + human adds sound" lane for proven winners. **[secondary / TO CONFIRM]**

## Originality and labels
- Reports say Instagram stopped recommending accounts that mostly post unoriginal content to non-followers, and that other platforms' visible watermarks or compilations may reduce reach. A logo doesn't make content original. **[secondary]**
- Instagram may add an "AI info" label from file metadata (C2PA/IPTC signals) regardless of the creator's toggle; also use the in-app AI label where available. **[secondary]**

## Comment-to-DM (see `dm-funnel` skill)
- Messaging is **user-initiated** (comment, story reply, inbound DM, ad click). **[official/secondary]**
- One **private reply** per comment, within **7 days**; it opens the **24-hour** standard window; promotional content is allowed inside the window. **[secondary, consistent]**
- Rate limits (Meta Messenger Platform docs, updated Mar 2026): **750 private-reply calls per hour per Instagram professional account**; 100 calls/s for Live-comment replies; 300 calls/s Send API ceiling. **[official]**
- "Human Agent" tag allows a 7-day window for *humans only*, not bots. **[secondary]**
- A repeat comment with the same keyword from the same user may not retrigger a ManyChat automation. **[secondary]**

## Safe zones and specs
9:16, 1080×1920; keep captions out of the top ~10% and bottom ~20%. **[general practice]** Cover frame set explicitly.
