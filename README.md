# Comfy-MBM Pipeline

A Claude-agent-run **viral short-form content engine**: find trends before they saturate → extract hook / visual / URL / caption / audio → write 3 original-persona concepts → render in ComfyUI (Comfy API deployment, pay per GPU-second, scale to zero) → brand-finish with Remotion → cross-post with Blotato → comment-to-DM funnel → measure → learn.

**Status: Phase 0, the harness.** This repo holds the agent team, skills, rules, schemas, SQL, and docs. The CLI tools the skills call are specified in `scripts/README.md` and built in Phase 1. Nothing here spends money or posts anything: `MBM_DRY_RUN=1` is the default.

## How it works
One **orchestrator** plus seven specialists (`scout`, `scriptwriter`, `studio`, `finisher`, `publisher`, `funnel`, `analyst`) coordinate only through a Supabase store with leases and **human approval gates enforced by the database**. Agents pass IDs, not payloads; scripts do I/O; models do judgment. Details: `docs/ARCHITECTURE.md`.

```
.claude/agents/   8 agents            .claude/skills/   13 procedures + 8 slash entry points
.claude/rules/    path-scoped rules   .claude/settings.json  permissions, dry-run default
brands/           persona template    knowledge/        platforms, compliance, licenses, monetization
schemas/          handoff contracts   supabase/         migration (tested on Postgres 16)
workflows/        your ComfyUI exports + contracts       docs/   architecture, roster, data model, runbook
scripts/          CLI contracts (Phase 1)                 CLAUDE.md  lean master brief (loaded every session)
```

## Start here
1. Read `docs/SETUP-CHECKLIST.md` and file the platform approvals first (they take weeks).
2. Create the Supabase project and apply `supabase/migrations/0001_init.sql`.
3. Turn your manual workflow into an API: `docs/COMFY-DEPLOY.md` (or the `comfy-deploy` skill). Verified flow: **Workflow actions → Deploy to Comfy API**, or the `comfy build` / `comfy deploy` CLI; `--min 0` bills nothing while idle.
4. Copy `brands/_template` to `brands/<slug>`, fill it in, set `MBM_ACTIVE_BRAND`.
5. `claude --agent orchestrator`, then `/agents`, `/status`.

## Daily commands (once Phase 1 tools exist)
`/status` · `/review` (approve gates) · `/scout-sweep` · `/make-batch` · `/publish-due` · `/measure` · `/niche-sprint` · `/run-cycle`

## Safety defaults
Dry-run on · three human gates · budget caps · no cold DMs · original AI persona only · AI-disclosure on · no secrets in git. See `docs/GUARDRAILS.md` and `knowledge/compliance.md`.

## Open items (marked TO CONFIRM in the docs)
Blotato auth header and platform approvals it covers · TikTok audit path · MiniMax H3 / Wan 2.2 licenses · Remotion license for your team size · current ManyChat plan limits. Everything else about Comfy deployment, billing and limits was read from the official docs on 2026-11-06.

Roadmap: `docs/ROADMAP.md`. Future product (template app / API on the same workflows, as a separate project): `docs/PRODUCT-VISION.md`.
