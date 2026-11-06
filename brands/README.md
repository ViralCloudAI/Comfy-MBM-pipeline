# Brands

One folder per persona: `brands/<slug>/`. The active one is `$MBM_ACTIVE_BRAND` (see `.claude/settings.json`). Start by copying `_template/`:

```bash
cp -r brands/_template brands/<slug>
```
Then fill the five files, set `MBM_ACTIVE_BRAND=<slug>`, and insert the brand row in Supabase (`docs/SETUP-CHECKLIST.md`).

Rules (`.claude/rules/brands.md`): personas are ORIGINAL characters, never a real person; keep files short (agents load them often); `banned.md` is authoritative; one CTA keyword → one funnel.

`_template/` contains prompts, not invented facts. Agents treat an unfilled template as "neutral voice, no persona facts".
