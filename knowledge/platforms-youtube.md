# YouTube Shorts

Confidence tags as in `platforms-instagram.md`.

## Policy
- "Repetitious content" was renamed **"inauthentic content"** on 15 Jul 2025 (framed as a clarification): mass-produced or repetitive, templated content with little variation can be demonetized. Reporting in July 2026 describes further clarifications about AI "slop". **[secondary; TO CONFIRM against YouTube's help page]**
- Evaluation is reported to be **channel-level** (upload frequency, format similarity). AI tools are allowed; meaningful human creativity (scripting, editing, narration, commentary) keeps content eligible. **[secondary]**
- A separate altered/synthetic-content disclosure is a viewer-facing label, independent of the monetization review. Use it for realistic synthetic content. **[secondary / TO CONFIRM for Shorts specifics]**

## Implications for this engine
Vary titles, hooks, formats and lengths; never post templated variations of one video; keep the persona's voice and commentary distinct; keep a human in the loop on what gets uploaded until the autonomy criteria are met.

## Data API
- `videos.insert` is quota-expensive. Commonly cited: default 10,000 units/day with 1,600 units per upload, so about 6 uploads/day before a quota extension. **[secondary / TO CONFIRM]**
- Uploads from unverified API projects are restricted to private until the project passes a compliance audit. **[secondary / TO CONFIRM]**
- Blotato may handle upload; confirm which approvals it covers. **[TO CONFIRM]**

## Trend data
YouTube Data API: search recent Shorts by query and `mostPopular`; official and quota-limited, useful as cross-platform confirmation of an emerging format.

## Specs
Shorts: vertical, ≤ 3 minutes (verify current limit), title ≤ 100 chars, hashtags in the description. **[TO CONFIRM]**
