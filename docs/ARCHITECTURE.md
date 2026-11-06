# Architecture

## One picture
```
                  ┌────────────── orchestrator (claude --agent orchestrator) ───────────────┐
                  │  reads store status → decides minimum work → delegates IDs → cycle report │
                  └──────┬───────────┬──────────┬──────────┬──────────┬──────────┬───────────┘
                         ▼           ▼          ▼          ▼          ▼          ▼
   TREND SOURCES ─► scout ─► scriptwriter ─► studio ─► finisher ─► publisher ─► analyst
   (Apify, YouTube,   │          │ G1(human)    │ Comfy API   │ Remotion    │ G2,G3(human) │ metrics
    Creative Center)  │          │              │ deployment  │ + captions  │ Blotato      │ learnings
                      ▼          ▼              ▼             ▼             ▼              ▼
              ┌──────────────────────────  SUPABASE (state + media + memory)  ──────────────────────────┐
              │ trends·briefs·concepts·renders·assets·posts·metrics·leads·ledger·learnings·gate_approvals │
              └───────────────────────────────────────────────────────────────────────────────────────────┘
                                                      ▲
   comment → DM (deterministic ManyChat flows) ───────┘   funnel agent: designs specs, syncs leads, digest
```

## Principles
1. **The store is the only channel.** Agents claim → work → advance. Nothing depends on another agent being alive.
2. **IDs, not payloads.** Delegations and replies carry IDs and ≤10-line summaries.
3. **Scripts for I/O, models for judgment.** HTTP, polling, uploads and rendering run in scripts with compact JSON output.
4. **Gates are data.** Human approvals are rows enforced by a DB trigger; automation is earned per gate.
5. **Cheapest path first.** Metadata score → small-model triage → mid-model scripting → GPU only for approved concepts; draft before final; scale-to-zero compute.
6. **Real-time stays deterministic.** DM replies are ManyChat flows; agents design and measure them.

## Components
| Layer | Choice | Why |
|---|---|---|
| Agent runtime | Claude Code (`.claude/agents`, `.claude/skills`), headless via `claude -p` | native subagents, skills, memory, hooks, scheduling |
| State/memory/media | Supabase (Postgres + Storage; pgvector later) | row locks for leases, spreadsheet-like table editor for review, RLS |
| Trend data | Apify actors (MCP scoped to scout), YouTube Data API, Reddit, Google Trends | public data, no logins |
| Render | Comfy API deployment (`--min 0`), plan B RunPod, prototyping on Comfy Cloud | pay per GPU-second, scale to zero |
| Finish | Remotion + WhisperX word timestamps + FFmpeg loudness | headless on Linux, code-defined templates |
| Publish | Blotato (MCP/REST) | cross-platform scheduling |
| Funnel | ManyChat flows + Meta Messaging rules | user-initiated DMs, keyword triggers |
| Orchestration | Claude Code scheduled tasks / GitHub Actions / cron calling narrow entry skills | each run small and capped |

## Flows
**Create:** scout (trend → brief) → scriptwriter (3 concepts) → **G1** → studio (draft → QA → final) → finisher → **G2** → publisher (**G3**, schedule, post).
**Learn:** analyst pulls metrics → learnings → `winning-patterns.md` → scriptwriter reads it next batch.
**Fund:** concepts carry a `cta_keyword` → funnel agent maps keyword → offer → flow spec → human builds flow once → leads sync back → attribution per post.

## Run modes
1. Interactive: `claude --agent orchestrator`, then `/status`, `/review`, `/run-cycle`.
2. Scheduled: narrow entry skills, e.g.
```bash
claude -p "/make-batch" --agent orchestrator --permission-mode dontAsk \
  --max-budget-usd 3 --output-format json     # do not use --bare: hooks and project settings must load
```
   Cadence (start): `/scout-sweep` every 3–6 h · `/make-batch` nightly in a GPU window · `/publish-due` at posting windows · `/measure` daily, `weekly` on Sundays.
3. Later: webhooks (render finished, post status, new comment) write to the store; agents never sit in a real-time path.

## Failure handling
| Failure | Behavior |
|---|---|
| Agent crash | lease expires, row returns to the pool; `v_stale_leases` shows it |
| Render failure | ≤2 retries (new seed), then `qa_failed`; 3 consecutive failures on one workflow stops the batch |
| Budget hit | `store budget` exit 2; agents stop and report |
| Platform quota/policy error | publisher backs off, records the error, flags in the cycle report |
| Gate missing | DB refuses the transition (exit 2) |

## Decisions (ADR summary)
| # | Decision | Alternatives rejected |
|---|---|---|
| 1 | Supabase as store | Sheets (no transactions/rate limits), Airtable (cost at scale) |
| 2 | Remotion for templates | After Effects via nexrender (needs AE render node; `aerender` only renders a prepared project) |
| 3 | Comfy API deployment first | RunPod first (more ops), Comfy Cloud only (credit pool, 1–5 concurrent) |
| 4 | Flat agent topology via the store | agent-to-agent messaging (fragile, token-heavy) |
| 5 | DM replies as ManyChat flows | agent in the real-time loop (latency, cost, risk) |
| 6 | Original AI persona, format remix | cloning real creators or third-party footage |
| 7 | Customer-facing template product is a **separate project** sharing only `docs/TEMPLATE-SPEC.md` | one monorepo/DB (mixes customer PII and user faces with agent service keys; shared blast radius and worker limits) |
