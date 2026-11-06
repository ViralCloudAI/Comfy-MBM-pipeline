# Cost model

Everything here is a formula plus **verified rates** and clearly labeled **assumptions**. Replace assumptions with measured values from `ledger` during Phase 2 and keep this page current.

## Verified Comfy API rates (Comfy API page, read 2026-11-06; re-check with `comfy deploy refs compute`)
| GPU | VRAM | $/hour | $/minute | $/second |
|---|---|---|---|---|
| RTX PRO 6000 MIG | 48 GB (≈ half the speed of the 96 GB) | 1.75 | 0.0292 | 0.000486 |
| RTX PRO 6000 | 96 GB | 3.49 | 0.0582 | 0.000969 |
| H100 SXM | 80 GB | 6.23 | 0.1038 | 0.001731 |
| H200 SXM | 141 GB | 7.71 | 0.1285 | 0.002142 |
| B200 | 180 GB | 11.23 | 0.1872 | 0.003119 |
Network storage **$0.20 per GB-month** (e.g. 100 GB of models = $20/month, billed while any deployment of the Build exists, even paused). Billing is per GPU-second; flex workers also bill startup/model-load time and a ~30 s idle window. `--min 0` bills no compute while idle.

## Per-video formula
```
gpu_usd   = rate_per_min × (draft_min + final_min) × attempt_factor     # attempt_factor ≈ 1 + retry_rate (assume 1.5)
llm_usd   = Σ tokens × price (scout + scriptwriter + studio QA + funnel + analyst share)
storage   = (model_GB × 0.20 / 30 / videos_per_day) + media storage
video_usd = gpu_usd + llm_usd + storage        # compare with MBM_VIDEO_BUDGET_USD
```

## Sensitivity: GPU cost per approved video (GPU-minutes include draft + final + retries)
| GPU-min per approved video | RTX PRO 6000 MIG 48 GB | RTX PRO 6000 96 GB | H100 |
|---|---|---|---|
| 3 | $0.09 | $0.17 | $0.31 |
| 6 | $0.18 | $0.35 | $0.62 |
| 12 | $0.35 | $0.70 | $1.25 |
| 24 | $0.70 | $1.40 | $2.49 |
Reading it: the MIG tier costs half per minute but runs about half as fast, so cost per clip is similar; pick on latency and on how much of the workflow is off-GPU. **The GPU-minute counts are assumptions.** For reference, the openjutsu author reports 6–13 minutes for a 6 s 480p swap on an RTX 4060 Ti 16 GB (a much weaker GPU), and about 28 minutes for face-fix on a 17 s clip at 768p. Measure the real number in Phase 2.

## Monthly picture (example with assumptions)
`3 videos/day × 30 days × (≈$0.50 GPU + ≈$0.30 LLM) ≈ $72/month`, plus network storage ($10–20 for 50–100 GB models), plus tooling subscriptions (Supabase, Blotato, Apify, ManyChat: **TO CONFIRM** current plans). Treat as a template, not a forecast.

## Limits that cap throughput
Standard/Creator: 2 concurrent workers per deployment, 2 deployments, 5 Builds. Pro: 10 / 5 / 10. Team: 20 / 20 / 40. At 2 workers and ~10 GPU-min per final clip you can finish roughly 12 clips/hour at best; real throughput depends on QA retries and cold starts.

## Levers (in order of impact)
1. Don't render un-approved concepts (G1 before GPU).
2. Draft at low-res first; final only after QA.
3. `--min 0`; batch jobs in a window so one cold start serves many clips.
4. Right-size GPU per pass (two deployments of one Build).
5. Cheapest model per agent (haiku for extraction/formatting/publishing).
6. Cache analysis by URL hash; never re-transcribe.
7. Keep `CLAUDE.md`/skills lean and stable (prompt-cache friendly); pass IDs, not payloads.

## Tracking
`ledger` is the record. GPU rows come from provider job responses; LLM rows from headless `total_cost_usd` (client-side estimate, can differ from the bill). Reconcile weekly with the Comfy console and the Anthropic usage page.
