# Roadmap

Timelines are estimates. Approvals (Meta, TikTok, YouTube) run in parallel and are the long pole. Each phase ends with explicit exit criteria.

| Phase | Weeks | Build | Exit criteria |
|---|---|---|---|
| **0 Harness** (this commit) | 0 | Agents, skills, rules, schemas, SQL, docs, knowledge, brand template. No GPU spend, no posting | Frontmatter/schema/SQL validated; repo opens in Claude Code and lists 8 agents + 21 skills |
| **0b Foundations** | 0–1 | Supabase project + migration applied; env secrets; API approvals filed (Meta app review + business verification, TikTok Content Posting audit, YouTube API audit/quota); persona bible drafted; `/niche-sprint` data collection started; golden set of 10 reference clips | Approvals submitted; store reachable; niche decision data collecting |
| **1 Tools** | 1–3 | `scripts/store`, `comfy_run`, `transcribe`, `remotion_render`, `metrics_pull`, `manychat` per `scripts/README.md`; hooks from `docs/guardrails` enabled; Remotion brand template; first workflow contract | Every skill's CLI exists and passes tests; hooks block over-budget and ungated actions in a drill |
| **2 Compute** | 2–4 | Your workflow deployed via **Deploy to Comfy API** (`--min 0`); draft vs final deployments; cost ledger reconciled against the Comfy console; golden clips pass | Measured cost per approved clip and cold-start recorded in `docs/COST-MODEL.md`; backend choice confirmed (Comfy API vs plan B) |
| **3 Intelligence** | 3–6 | Live scout (Apify), analyzer, scriptwriter; `/review` loop for G1; niche chosen; trend knowledge in the store | ≥ 70% of concepts approved at G1; detect→post latency tracked |
| **4 Distribution** | 5–8 | Blotato publisher (dry-run → private/test accounts → public); per-platform variants; AI-disclosure; metrics pull | Dry-run and live posts succeed on each platform; metrics land in `post_metrics` |
| **5 Funnel** | 6–9 | CTA keywords, first ManyChat flows built from build sheets, lead sync, attribution | Keyword → lead → customer attributable per post; STOP and escalation paths tested |
| **6 Closed loop** | 8–12 | Analyst learnings, `winning-patterns.md`, experiment policy, budget guards, autonomy graduation per `metrics-loop` | G1 and G2 automated by criteria; kill-switch and circuit-breaker drills passed |
| **7 Monetize and scale** | 12+ | Product ladder, media kit, agency pilot, second persona/niche (`brands/<slug>/` copy) | First revenue from ≥ 2 streams (see `knowledge/monetization.md`) |

## Track B: product (separate project)
A template app / API on the same locked workflows is planned as its **own repo and agent team**; see `docs/PRODUCT-VISION.md`. This repo only supplies the shared `template:` contract (`docs/TEMPLATE-SPEC.md`), the template lab (trend-fresh formats), and the demand test (B1: template demos → CTA keyword → DM → waitlist). Do not build product code here. Track B starts after Phase 2 (measured compute cost) and Phase 4 (distribution) exit criteria.

## Phase 0b checklist (start immediately)
See `docs/SETUP-CHECKLIST.md`. The three platform approvals take longest; file them first. Blotato may cover some posting approvals; confirm what it does and does not cover.

## KPIs
Leading: detect→post latency, G1 approval rate, auto-QA pass rate, cost per approved video. Lagging: 3-s hold, avg watch %, share rate, saves, follows per 1k views, comment→DM conversion, DM→lead, lead→customer, revenue per 1k views. Set targets from the first 30 days of baseline data, not from blog benchmarks.

## Not in scope until proven
Multiple personas on one niche · cross-account amplification · paid ads · auto-replying with an LLM inside DMs · scraping behind logins.
