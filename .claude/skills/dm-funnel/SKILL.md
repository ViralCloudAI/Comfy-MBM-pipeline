---
name: dm-funnel
description: "Design comment-to-DM funnels within Meta messaging rules: flow specs, keyword to offer to video mapping, lead stages, attribution, ManyChat constraints and escalation. Use when creating or syncing a funnel."
---

# DM funnel

**Architecture:** real-time replies = deterministic ManyChat flows. The agent designs specs and copy, then syncs data and metrics. The ManyChat public API manages subscribers, tags, fields and can send messages or trigger an *existing* flow, but reportedly cannot create or edit flows/keyword triggers (**TO CONFIRM** in current ManyChat docs). A human builds each flow once from the build sheet; templates are reused.

## Meta rules to encode (Instagram)
- Messaging is **user-initiated**: comment, story reply, inbound DM, or ad click. No cold outreach.
- A comment permits **one private reply** per comment, within **7 days**; it opens a **24-hour** window for follow-ups. Promotional content is allowed inside the window.
- Limits (Meta Messenger Platform docs, Mar 2026): **750 private-reply calls/hour** per Instagram professional account. Keep tools below it; expect viral posts to hit it. Human-agent follow-ups beyond 24 h are for humans only.
- Always include opt-in wording, a STOP path, and an escalation-to-human branch.
- TikTok and YouTube have no comparable general DM API: use pinned comment, bio link and a landing page keyword (**TikTok business messaging availability TO CONFIRM**).

## Funnel ladder
Hook → CTA keyword → DM → lead magnet (free prompt/workflow pack) → email/community → tripwire product → core offer → premium service. One keyword maps to exactly one funnel and one offer.

## Flow spec (see [flow-spec.example.yaml](flow-spec.example.yaml))
`keyword`, `trigger` (post/reel scope), `public_reply_variants[]` (rotate), `dm_sequence[]`, `qualify` (one question), `deliver` (link), `tags[]`, `fields` (`video_id`, `source_post`), `opt_in_text`, `stop_text`, `escalate_if[]`, `ttl_hours`.

## Attribution
`funnels.keyword` ↔ `posts.id` via `video_id` custom field → `leads.source_post_id`. Report keyword → lead → customer per post.

## Lead hygiene
Minimum data only (handle, tags, email if volunteered). No payment/health data. Honor unsubscribes immediately. GDPR/CCPA: record opt-in time, support deletion.

## Digest for humans
Conversations unanswered > 4 h, negative sentiment, refund/safety words, or high-intent ("price", "buy"). ≤ 15 lines.
