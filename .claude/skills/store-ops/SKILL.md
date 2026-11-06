---
name: store-ops
description: "How every agent reads and writes pipeline state through scripts/store (Supabase): claim, work, advance, fail, query, budget. Use before touching any pipeline row."
---

# Store operations (the only inter-agent channel)

State lives in Supabase. Agents never message each other. Full schema: `docs/DATA-MODEL.md`.

## Protocol: Claim → Work → Advance
1. **Claim** rows in your input status. A lease (default 30 min) marks them yours; an expired lease returns them to the pool.
2. **Work** only on claimed rows.
3. **Advance** to the next status with artifact refs, or **fail** with a reason. Both clear the lease.

## CLI contract (`scripts/README.md` has the full spec; compact JSON out)
| Command | Purpose |
|---|---|
| `store status [--json]` | counts per status, pending gates, budget left, stale leases |
| `store claim <table> --status S --agent A --limit N [--lease-min 30]` | returns claimed ids |
| `store get <table> <id>` | one row |
| `store put <table> --json <file\|->` | insert a row |
| `store advance <table> <id> --agent A --to STATUS [--set k=v ...]` | requires you hold the lease |
| `store fail <table> <id> --agent A --reason "..."` | records reason, releases lease |
| `store query "<read-only SQL>"` | capped rows; SELECT only |
| `store budget [--json]` | exit 2 when the day/video/endpoint cap is hit |
| `store ledger add --agent A --kind llm\|gpu\|api\|storage --usd X --units N --ref table:id` | spend record |

Exit codes: `0` ok · `1` error · `2` blocked (budget or gate) · `3` lease lost / conflict.

## Rules
- Claimable tables: `trends`, `briefs`, `concepts`, `posts`, `finished_assets`.
- You may set `approved`, `approved_cut`, or `scheduled` on a concept only if the database accepts it; those are gated by `gate_approvals`. A refusal (exit 2) is the system working. Do not look for a way around it.
- Never write to `gate_approvals` or `autonomy`.
- Pass **IDs** between agents and in delegations, never content.
- Keep your final reply to ≤10 lines.
- `MBM_DRY_RUN=1`: scripts that touch the outside world must no-op and say so in their output.
