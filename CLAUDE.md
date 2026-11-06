# Comfy-MBM Pipeline — viral content engine

**Mission.** Catch short-form trends *before* they saturate → extract hook / visual / URL / caption / audio → write 3 original-persona concepts → render in ComfyUI (Comfy API deployment) → brand-finish with Remotion → cross-post with Blotato → comment→DM funnel → measure → learn. Compounding memory, minimum tokens, minimum GPU seconds.

**Persona rule.** Content stars an ORIGINAL AI persona (`brands/<slug>/`). Never clone or imitate a real person's face or voice. Remix *formats*, not footage.

## Team (`.claude/agents/`; run the main agent with `claude --agent orchestrator`)
| Agent | Moves | Notes |
|---|---|---|
| orchestrator | reads status, delegates IDs, writes cycle report | never does stage work itself |
| scout | trend `new` → `briefed` | Apify; haiku |
| scriptwriter | brief → concepts `drafted` (A/B/C) | sonnet |
| studio | concept `approved` → `qa_passed` | Comfy API deployment |
| finisher | `qa_passed` → `finished` | Remotion + subtitles |
| publisher | `approved_cut` → `posted` | Blotato |
| funnel | designs DM flows, syncs leads | ManyChat; no real-time replies |
| analyst | `posted` → `measured`, learnings, costs | weekly pruning |

## State machines
- trend: `new → briefed | rejected`; brief: `new → scripted | needs_human`
- concept: `drafted →[G1]→ approved → rendering → rendered → qa_passed | qa_failed → finishing → finished →[G2]→ approved_cut →[G3]→ scheduled → posted → measured` (side states: `killed`, `needs_human`)
- **G1 concept, G2 final cut, G3 publish are HUMAN gates** (`gate_approvals` rows) until graduated in the `autonomy` table. Never approve a gate yourself.

## Coordination protocol (every agent)
1. `scripts/store claim` rows in your input status (lease).  2. Do the work.  3. `scripts/store advance` with artifact refs, or `store fail` with a reason.
Agents never message each other; **the store (Supabase) is the only channel.** Pass IDs, not payloads. Final reply ≤ 10 lines: `DONE n | advanced <ids> | failed n | $cost | notes`.

## Golden rules
1. Scripts do I/O, you do judgment. Never poll a render or API in a loop; use the blocking script (`comfy_run wait`).
2. Before any GPU/API spend run `scripts/store budget`. Exit code 2 = blocked → stop and report.
3. `MBM_DRY_RUN=1` is the default: no posting, no DMs, no paid renders. Never unset it yourself.
4. `compliance-check` before a concept leaves `drafted` and before anything is scheduled. It fails closed.
5. Draft low-res first; final only after QA passes. Max 2 retries per render.
6. Cache by source-URL hash. Never re-analyze a known URL.
7. Never read `.env`, never write secrets to files, logs or the store.
8. Real-time DM replies are deterministic ManyChat flows, never an agent session.
9. Learnings go to the store (`learnings`) first. Only `analyst` promotes them to `knowledge/winning-patterns.md`.
10. If docs and reality disagree, say so; don't silently pick one. Unverified facts are marked `TO CONFIRM`.

## Where things live
| Need | Path |
|---|---|
| Full architecture, data model, roster, roadmap | `docs/ARCHITECTURE.md`, `DATA-MODEL.md`, `AGENT-ROSTER.md`, `ROADMAP.md` |
| Procedures | `.claude/skills/<name>/SKILL.md` (load on demand) |
| Persona, voice, CTAs | `brands/<slug>/` (active: `$MBM_ACTIVE_BRAND`) |
| Platform rules, compliance, licenses, monetization | `knowledge/` |
| Comfy deploy-to-API | `docs/COMFY-DEPLOY.md`, skill `comfy-deploy` |
| Tool CLI contracts | `scripts/README.md` |
| Runtime scratch (git-ignored) | `data/` |
| Workflow exports + parameter contracts | `workflows/` |
| Future SaaS product (separate project) | `docs/PRODUCT-VISION.md`, `docs/TEMPLATE-SPEC.md` |

## Efficiency (how we keep costs flat)
Cheapest model that works · IDs not payloads · `maxTurns` on every agent · draft-then-final renders · scale-to-zero GPU (`--min 0`) · batch windows · weekly memory pruning (every `MEMORY.md` stays under 200 lines). Details: skill `cost-guard`, `docs/COST-MODEL.md`.

## Hard prohibitions
No posting or DMs outside `publisher`/ManyChat flows · no cold DMs · no impersonation · no scraping behind logins · no storing third-party video beyond transient analysis · no fabricated metrics or testimonials · no secret in git.
