# Setup checklist

Do these in order. Items marked ⏳ have approval lead times: start them first. Never paste secrets into chat or the repo: use the cloud environment's secrets (or a local `.env`, git-ignored).

## 1. Accounts
- [ ] **Supabase** project (note project ref). Create a **private** Storage bucket `mbm-media`. Run `supabase/migrations/0001_init.sql` in the SQL editor. Insert your brand: `insert into brands(slug,name) values ('<slug>','<name>');`
- [ ] **Comfy**: account, paid plan sufficient for the deployment limits you need (Standard/Creator: 2 deployments, 2 workers), API key, credits.
- [ ] **Blotato** account; connect Instagram, TikTok, YouTube, Facebook, X, Threads accounts; API key.
- [ ] **Apify** account + token.
- [ ] **ManyChat** account (Pro plan needed for most automation: **TO CONFIRM**) connected to the Instagram professional account.
- [ ] Anthropic API/subscription usage alerts.

## 2. ⏳ Platform approvals (file in Week 0)
- [ ] **Meta**: app review for Instagram Content Publishing and messaging scopes + Business Verification (only if you publish/message through your own app rather than Blotato/ManyChat).
- [ ] **TikTok**: Content Posting API audit (unaudited apps can only post privately). Confirm whether Blotato's app is already audited.
- [ ] **YouTube**: API compliance audit / quota extension (unverified API projects upload privately).
- [ ] Confirm each platform's AI-content disclosure toggles and add them to `knowledge/platforms-*.md`.

## 3. Secrets (environment, not git)
Names are in `.env.example`: `SUPABASE_URL`, `SUPABASE_SERVICE_KEY` (use a restricted key for agents), `SUPABASE_REVIEWER_KEY` (human-only), `COMFY_API_KEY`, `COMFY_BASE_URL`, `COMFY_DEPLOYMENT_ID`, `BLOTATO_API_KEY`, `APIFY_TOKEN`, `MANYCHAT_API_KEY`. In Claude Code cloud sessions, add credentials through the environment's secrets/credential settings. Leave `MBM_DRY_RUN=1`.

## 4. Brand
- [ ] Copy `brands/_template/` to `brands/<slug>/`; fill persona bible, voice, visual identity, banned list, CTA library.
- [ ] Set `MBM_ACTIVE_BRAND=<slug>` and your real `MBM_DAILY_BUDGET_USD` / `MBM_VIDEO_BUDGET_USD` (and update the `budgets` table).
- [ ] Persona reference sheet + LoRA/reference images stored in Supabase Storage (not git).

## 5. Compute
- [ ] Follow `docs/COMFY-DEPLOY.md` (or run the `comfy-deploy` skill). Start with `--min 0`, low `--max`.
- [ ] Save your workflow as API-format JSON in `workflows/`, add its contract.

## 6. Agent plumbing
- [ ] Uncomment the `mcpServers` blocks in `scout.md` and `publisher.md` once keys exist and the auth headers are confirmed from vendor docs.
- [ ] Run `claude --agent orchestrator` in the repo; run `/agents` and confirm 8 agents; run `/status`.
- [ ] Enable hooks from `docs/guardrails/settings.hooks.example.json` when Phase 1 scripts exist.

## 7. First dry run (Phase 1+)
`MBM_DRY_RUN=1`: `/scout-sweep` → `/make-batch` → `/review` (approve one) → `/make-batch` → `/review G2` → `/publish-due`. Check the `ledger`, the `posts` dry-run rows, and the cycle reports.

## 8. Going live (human decision)
Set `MBM_DRY_RUN=0` only after: private/test-account posts verified on every platform · AI-disclosure verified · budget caps set · kill-switch drill done (`docs/RUNBOOK.md`).
