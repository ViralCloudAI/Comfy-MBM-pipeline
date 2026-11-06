---
paths:
  - "schemas/**"
  - "supabase/**"
---

# Schema and migration rules

- `schemas/*.json` and `supabase/migrations/*.sql` are the contracts between agents. Change them deliberately.
- Never edit an applied migration. Add `000N_*.sql`.
- Any schema change must update, in the same commit: `docs/DATA-MODEL.md`, the `store-ops` skill, and the matching JSON Schema.
- Status values are shared across `CLAUDE.md`, `docs/DATA-MODEL.md` and SQL `check` constraints. Keep all three identical.
- Agents get a restricted DB key with no INSERT/UPDATE on `gate_approvals` and `autonomy`.
