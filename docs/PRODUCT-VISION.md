# Product vision: a template app on open ComfyUI workflows (working name TBD)

Status: **vision + seams only.** Nothing here is built. Evidence quality: competitor facts come from third-party reviews and vendor blogs (marked *reported*); legal points are orientation for a conversation with counsel, not advice.

## Recommendation: separate project, thin shared contract
Build the product as its **own repo, Supabase project, Comfy workspace/keys, budget and agent team**. Keep this repo as the **internal engine and template lab**. Share only the **template spec** (`docs/TEMPLATE-SPEC.md`) and learnings.

| Why separate | Detail |
|---|---|
| Data boundary | The product holds customer PII, uploaded faces and payment metadata. Engine agents run with service keys and must never see that data (and vice versa). |
| Risk profile | The engine uses one original persona. The product accepts *user* faces: consent, abuse, takedown and legal duties apply (below). |
| Blast radius | A policy incident, chargeback wave or outage on one side must not take down the other's accounts, keys, quotas or reputation. |
| Stack and cadence | Web app, auth, billing, queues and CDN vs. agent-run content ops. Different agents, different release rhythm. |
| Cost isolation | Separate Comfy workspace so product traffic can't starve the engine's worker limits (Team plan: 20 workers/deployment; more by contract). |

| Why keep them connected | Detail |
|---|---|
| **Flywheel** | Engine's scout/analyst find viral formats → best become product templates ("this week's trending templates") → engine's own accounts market the product through the CTA→DM funnel → product usage shows which templates people want → feeds the scout. One-way, aggregated, no PII. |
| Shared craft | Workflow contracts, QA rubric, cost model and Comfy deploy know-how are reusable. |

## The idea, sharpened
Higgsfield (*reported*) is a multi-model aggregator: 15+ closed video/image models under one credit-based subscription, with a library of **viral presets** that encode recurring structures (pacing, framing, 9:16 export) and a virality predictor. Its edge is curation and speed-to-trend, not model ownership.

**Our wedge:** the same *template-first* experience, but each template is a **locked open-model ComfyUI workflow** we control:
1. **Lower, predictable COGS**: pay per GPU-second on open models instead of reselling per-call closed-model fees.
2. **Trend-fresh catalog**: the engine's radar finds formats days earlier; templates ship weekly.
3. **Control**: we own the workflow, so we can fix quality, add safety checks, brand-kit it, and sell the same template as an API.
4. **Built-in distribution**: our own accounts demo every template and drive signups.
Honest limits: Comfy itself ships apps/hub features and an API product, so the moat is **catalog quality, trend speed, UX and distribution**, not "we use open models". Closed models still win some quality tiers; the catalog should pick templates where open models are good enough.

## Product shape
| Tier | Who | What |
|---|---|---|
| A. Web app | creators, small brands | gallery of templates with previews → upload → pick options → generate → export to platform presets; credits; history; brand kit |
| B. API | developers, agencies, apps | `POST /templates/{id}/runs` with the same contracts; usage-based billing |
| C. White-label / private templates | agencies, studios | their own locked workflows on our infra |
| D. Template marketplace (later) | workflow authors | revenue share; heavy review burden: only after the safety stack is proven |

## What is a "template"
A locked workflow + parameter contract + safety class + preview + price + pinned Comfy release. Users see friendly inputs (photo, clip, style, length); the graph, models, seeds ranges and node settings stay hidden. Spec: `docs/TEMPLATE-SPEC.md`.

**Starter catalog ideas (by risk, low → high):**
1. *Effects/transformations on user-supplied non-face media* (style transfers, scene effects, background swaps, upscale, relight, caption/brand-kit overlays).
2. *Image edit* (outfit/color/background/object remove) on user-owned images.
3. *Character/face swap* with the **user's own consented face** or an **original stock persona** only.
Launch order follows the list: start with 1–2, add 3 after trust-and-safety is real.

## Architecture (product repo)
```
Web app (Next.js or similar) ─► API gateway (auth, quotas, input checks, pre-moderation)
        │                              │
        │                              ▼
        │                    Job broker (Postgres queue, idempotency, credits ledger)
        │                              │ server-side only; Comfy key never reaches the browser
        │                              ▼
        │                    Runner interface ─► Comfy API deployments (draft/final)  | plan B: own GPUs
        │                              │
        ▼                              ▼
   Storage + CDN  ◄──  post-moderation, watermark / C2PA, short-lived signed URLs
   Billing (Stripe or equivalent): credits, subscriptions, refunds on failed runs
```
Reuse from the engine: the `Runner` abstraction, idempotent restartable jobs, output re-hosting, cost ledger, QA rubric, scale-to-zero compute (cold starts affect UX: use `--min 1` in peak windows).

## Trust and safety (non-negotiable for any face input)
Design these **before** exposing face templates. All items are *to be validated with counsel*:
- **Consent:** only the user's own face or an original persona. Attestation at upload plus a liveness/selfie match for "my face" templates. Block celebrity/public-figure matching.
- **Prohibited content:** sexual/intimate content, minors, harassment, political deception, impersonation. Pre-generation prompt/input checks and post-generation image/video checks. 18+ only.
- **Provenance:** visible AI label on free tier, C2PA/machine-readable marking on all outputs. EU AI Act Article 50 transparency duties are reported to apply from 2 Aug 2026 with a contested grace period for marking (*TO CONFIRM exact dates*).
- **Takedown:** the US TAKE IT DOWN Act's platform notice-and-removal duty (48-hour removal) is reported as enforceable from 19 May 2026; keep a reporting channel, an on-call process, an audit log and DMCA agent. UK law reportedly criminalises creating sexually explicit deepfakes without consent from Feb 2026. State laws and right-of-publicity claims also apply.
- **Abuse controls:** rate limits, device/payment fingerprinting, ban lists, retained hashes of violating outputs, human review queue.
- **Payment and store policies:** card processors and app stores restrict some synthetic-media products; check before choosing rails.

## Licensing and platform dependency
- Serving customers is unambiguously commercial: every model and node in a public template must be `cleared` in `knowledge/licenses.md` (MiniMax H3 reported territory/revenue/attribution limits; InsightFace `buffalo_l` and the AGPL YOLO weights are blocked).
- Confirm in writing that Comfy API's terms allow multi-tenant resale of outputs (their product page says deployments can sit "behind customer-facing products"), and what happens at scale-limit or policy changes.
- Plan B: the same contracts run on RunPod or your own GPUs if Comfy API's economics or limits stop working.

## Unit economics (formulas; fill with measured values)
```
cogs_run   = gpu_rate_per_min × gpu_min_per_run × (1 + retry_rate) + storage + moderation + egress
price_run  = cogs_run × markup          # markup must absorb: free tier, failed-run refunds, payment fees (~3%), support, chargebacks
credits    = price_run / credit_value
```
Reported competitor reference points (conflicting sources, verify before benchmarking): Higgsfield Starter about $19/month for 270 credits, Plus about $59, Ultra about $129; credits reset monthly and are consumed per generation by model. Measure the *credits per comparable output* on competitors yourself.
Levers: scale-to-zero compute, draft previews at low cost, caching, per-template GPU right-sizing, free tier limited to low-res watermarked previews.

## Sequencing (Track B)
| Step | When | What | Gate to proceed |
|---|---|---|---|
| **B0** | now | This vision + `TEMPLATE-SPEC.md` + `template:` block in workflow contracts. No code | You agree on separation |
| **B1** Demand test | after engine Phase 2–4 | Engine posts template demos; CTA keyword → DM → **waitlist** (no product yet); count signups per template | Enough signups per template to justify building (set threshold up front) |
| **B2** MVP | | New repo; 1–3 **non-face** templates; auth, credits, Stripe, job broker, moderation v1; invite-only | Measured COGS, margin ≥ target, no safety incidents |
| **B3** Face templates | | Consent flow, liveness, provenance, takedown process, counsel review | Safety checklist signed off |
| **B4** API + catalog growth | | Public API, weekly trend templates from the engine, referral | Retention and margin hold |
| **B5** Scale | | White-label, marketplace (only with proven moderation) | |

## Proposed agent team for the product repo (when it exists)
`product-lead` (roadmap, specs, metrics) · `template-engineer` (workflow → locked template, contracts, golden clips, previews) · `backend-engineer` (API, broker, credits ledger, Runner) · `frontend-engineer` · `trust-safety` (policies, moderation rules, incident runbooks, takedown queue; **human sign-off required**) · `growth-support` (waitlist, onboarding, FAQ, tickets). Same pattern as here: store-mediated handoffs, human gates, budget guards.

## Decisions for you
1. Approve the separation (own repo + accounts), and pick a working name.
2. Which first template category: non-face effects/image edits (recommended) or swap?
3. Target customer for B2 (creators vs. agencies/API).
4. Willingness to retain counsel for the face-template review before B3.

## What I can do next
Create the product repo's `.claude/` harness the same way as this one (agents, skills, schemas, SQL, docs) once the repo exists. I can't create repositories from this session: create an empty repo, add it to the session, and I'll scaffold it.

## Sources
[Higgsfield pricing roundups](https://www.wireflow.ai/blog/higgsfield-pricing) · [Higgsfield pricing explained (Krea)](https://www.krea.ai/blog/higgsfield-pricing-explained-2026-unlimited-credits-and-real-monthly-costs) · [Comfy API product page](https://comfy.org/platform/comfy-api.md) · [Synthetic media rules overview (Article 50 + TAKE IT DOWN)](https://www.softwareseni.com/the-2026-synthetic-media-rulebook-from-article-50-to-the-take-it-down-act/) · [TAKE IT DOWN Act explained](https://www.traverselegal.com/blog/take-it-down-act-explained-ai-deepfake-removal-law/) · [openjutsu](https://github.com/D3voz/openjutsu)
