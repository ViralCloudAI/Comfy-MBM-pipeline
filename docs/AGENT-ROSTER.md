# Agent roster and contracts

Agents live in `.claude/agents/*.md`. Run the main agent with `claude --agent orchestrator` (also the project default in `.claude/settings.json`). Subagent models are aliases; tune after real cost data.

| Agent | Model | Reads (status) | Writes / advances | Skills preloaded | Tools | MCP (scoped, optional) | Memory | Turn cap |
|---|---|---|---|---|---|---|---|---|
| orchestrator | sonnet, low effort | counts via `store status` | nothing but delegations and the cycle report | store-ops, cost-guard | Agent(7 specialists), Read, Glob, Grep, Bash | none | none | 30 |
| scout | haiku | creates `trends new` | `briefs`, `trend_snapshots`; trend → `briefed`/`rejected` | viral-radar, hook-teardown, store-ops | Bash, Read, Write | Apify | project | 40 |
| scriptwriter | sonnet | briefs `new` | `concepts drafted` (A/B/C); brief → `scripted` | script-variants, brand-voice, compliance-check, store-ops | Bash, Read, Write | none | project | 30 |
| studio | sonnet | concepts `approved` | `renders`; concept → `rendering → rendered → qa_passed` / `qa_failed` | comfy-run, cost-guard, store-ops | Bash, Read | none | project | 40 |
| finisher | haiku | concepts `qa_passed` | `finished_assets`; concept → `finishing → finished` | post-production, store-ops | Bash, Read, Write | none | none | 30 |
| publisher | haiku | concepts `approved_cut` (+G3) | `posts`; concept → `scheduled → posted` | cross-post, compliance-check, store-ops | Bash, Read | Blotato | none | 25 |
| funnel | sonnet | concepts with `cta_keyword`, `posts` | `funnels`, `leads`, build sheets, digest | dm-funnel, brand-voice, store-ops | Bash, Read, Write | none | project | 30 |
| analyst | sonnet | posts with due windows | `post_metrics`, `learnings`, `winning-patterns.md`; concept → `measured` | metrics-loop, cost-guard, store-ops | Bash, Read, Write, Edit | Supabase (read-only, optional) | project | 40 |

`omitClaudeMd: true` is set on the three haiku workers (scout, finisher, publisher) so they start without `CLAUDE.md`; their bodies restate the hard rules. Requires a recent Claude Code (v2.1.271+); older versions ignore the field and simply load `CLAUDE.md`.

## Delegation contract (orchestrator → agent)
Include: exact IDs or a count cap · budget cap · current `MBM_DRY_RUN` · brand slug. Exclude: content, transcripts, scripts, files.

## Reply contract (agent → orchestrator)
At most 10 lines: `DONE n | advanced <ids> | failed n | $cost | notes`. Details live in the store.

## Human-only actions
Approve G1/G2/G3 (`/review`), change `autonomy`, change `budgets`, set `MBM_DRY_RUN=0`, build ManyChat flows, create/delete Comfy deployments, pick the niche.

## Adding an agent
1. Define the input status it claims and the status it produces (extend `docs/DATA-MODEL.md` and the SQL `check` constraints in a new migration).
2. Write the agent file with a short description, restated hard rules, a ≤10-line reply contract, and `maxTurns`.
3. Put procedures in a skill, not the agent body.
4. Add it to the orchestrator's `Agent(...)` allowlist and routing table.
