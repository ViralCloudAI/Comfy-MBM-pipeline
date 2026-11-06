---
paths:
  - "brands/**"
---

# Brand and persona rules

- Personas are ORIGINAL characters. Never base a persona on a real person's face, voice, name or identifiable likeness.
- Keep `persona-bible.md` under ~120 lines and `voice.md` under ~80. Agents load them often; every line costs tokens on every run.
- `banned.md` is authoritative: topics, phrases, claims, and trend types the persona never touches.
- `cta-library.yaml` keywords must be unique per active funnel (one keyword → one funnel).
- A persona change invalidates cached prompts and LoRA/reference sets. Note it in `docs/RUNBOOK.md` change log and re-run golden clips.
- Put a persona's disclosure line ("AI character") in `visual-identity.md` and keep it in every bio and caption template.
