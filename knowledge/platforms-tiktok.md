# TikTok

Confidence tags as in `platforms-instagram.md`.

## Publishing API
- The Content Posting API requires app review for the `video.publish` scope **and** a separate Content Posting API **audit**. Until audited, all posts from the client are restricted to **private** visibility regardless of the requested setting. **[secondary, consistent]**
- Unaudited clients are reported limited to about 5 users posting in a 24-hour window, and those accounts must be private at posting time. **[secondary]**
- Posts made while unaudited stay private after the audit passes (vendor report). **[secondary / TO CONFIRM]**
- Whether Blotato's TikTok integration is already audited (and therefore public-capable) is the single most important thing to confirm before choosing the TikTok launch path. **[TO CONFIRM]**
- Draft/inbox upload lets a human finish the post in the app (add trending sound, final tweaks). Useful for the "trending sound" lane. **[general; TO CONFIRM for API]**

## Originality and labels
- TikTok stepped up enforcement against unoriginal content from **15 Sep 2025**; flagged content can lose recommendation, search ranking or organic reach. Adding a logo does not fix it. **[secondary]**
- TikTok requires labeling of realistic AI-generated content and uses C2PA Content Credentials to auto-label AI media, including content from other platforms; automatic labels can't be removed (reported). **[secondary]**

## Monetization notes
- Creator Rewards eligibility for AI-generated content is unclear: one vendor says effectively excluded, TikTok's criteria don't explicitly say so. Reported thresholds: 10,000 followers and 100,000 views in 30 days. **[secondary / TO CONFIRM]**
- TikTok Shop affiliate follower thresholds reported at 1,000 to 5,000 depending on region. **[secondary / TO CONFIRM]**

## Trend data
TikTok Creative Center (public) shows trending hashtags, sounds and videos by country/period; scrapers expose rankings and curves but not velocity, and the redesigned page reportedly dropped rank-change flags. Build your own snapshots. **[secondary]**

## DMs
No general-purpose DM automation API is assumed. Use pinned comment, bio link and landing page. **[TO CONFIRM]**
