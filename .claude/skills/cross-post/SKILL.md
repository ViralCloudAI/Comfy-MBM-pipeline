---
name: cross-post
description: "Schedule and cross-post approved final cuts through Blotato with per-platform captions, hashtags, cover, first comment, AI disclosure, dry-run default and status confirmation. Use when publishing approved_cut concepts."
---

# Cross-posting with Blotato

Blotato exposes an MCP server (`https://mcp.blotato.com/mcp`) and a REST API (`https://backend.blotato.com/v2`). Tools named in its docs: `blotato_create_post` (required: `accountId`, `platform`, `text`; returns `postSubmissionId`), `blotato_get_post_status`, `blotato_list_templates`, `blotato_create_visual`, `blotato_get_design_status`, plus an account-listing tool (**name TO CONFIRM**). Exact auth header, media-upload and scheduling parameters are **TO CONFIRM** from `help.blotato.com/api/*` before the first live post.

## Preconditions (the store enforces; stop if not met)
Concept in `approved_cut` with gate G3 approval (or G3 graduated) · `MBM_DRY_RUN` understood · `compliance-check` publish stage passed.

## Per-platform variant
Build from the concept; never reuse identical text across platforms.

| Platform | Caption | Hashtags | Extras |
|---|---|---|---|
| Instagram Reels | hook-first, ≤ platform limit | few, specific | cover frame; first comment with CTA keyword; check `content_publishing_limit` |
| TikTok | short, hook-first | 3–5 | AI-generated label on; unaudited apps can only post private (see platforms doc) |
| YouTube Shorts | title ≤ 100 chars + description | in description | respects inauthentic-content policy: distinct titles, real variation |
| Facebook Reels / X / Threads | native phrasing | minimal | cross-post after core three succeed |
Limits and quotas: `knowledge/platforms-*.md`.

## Procedure
1. Build variants → `compliance-check` (publish).
2. Choose time inside the brand's windows with jitter. No bursts across accounts.
3. **Dry-run:** write `posts` rows (`pending`, `dry_run=true`) and print the payloads. No network call.
4. **Live:** submit via Blotato; store `postSubmissionId`; `store advance … --to scheduled`.
5. After the scheduled time, check status; on success store `post_url`, `posted_at`, advance to `posted`; on failure store the platform error and `store fail`.
6. Put the first comment (CTA keyword) right after posting if the platform/tool supports it.

## Hard limits
Only post to accounts listed in the brand's account list · no automated engagement beyond the CTA comment · never post when a quota error suggests throttling; back off and report.
