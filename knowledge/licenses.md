# License register (models, nodes, fonts, music)

Rule: nothing runs in a **monetized** workflow until its row says `cleared`. Update this file whenever a workflow, node pack or asset changes. Status: `cleared` · `blocked` · `TO CONFIRM`.

| Component | Used for | Commercial use? | Status | Notes / source |
|---|---|---|---|---|
| MiniMax H3 (open weights) | video generation / swap (openjutsu reference) | **Unclear.** Comfy says a commercial license (sold through Comfy) is needed for commercial local use; secondary reports mention territory limits (US/EU/UK/KR excluded), a revenue threshold ($20M) and attribution | TO CONFIRM | Read the model card and Comfy's license page; resolve against your jurisdiction before using. Comfy's API page states all models available on its platform are usable commercially: get that in writing for H3 |
| Wan 2.2 Animate (14B) | character replacement/motion transfer (fallback) | Believed permissive, **verify** | TO CONFIRM | Official ComfyUI native workflow exists; confirm model card license |
| SAM 3.1 / SAM2 | person tracking/masks | verify | TO CONFIRM | Needed for swap workflows |
| Qwen3-VL (8B etc.) | frame description, QA judge | verify per size | TO CONFIRM | Used by openjutsu as the describer |
| FLUX (image prep/relight) | reference/persona images | **varies by variant** | TO CONFIRM | Some variants are non-commercial |
| InsightFace `buffalo_l` | face identification (openjutsu "Fix faces") | **No** (non-commercial research only, per openjutsu) | **blocked** | Replace with a commercially licensed face-embedding model or a VLM judge |
| Bingsu/adetailer YOLO weights | face/person detection | AGPL-3.0 (per openjutsu) | **blocked** until reviewed | AGPL obligations; replace or comply |
| ComfyUI core | runtime | GPL-3.0 | note | Hosting a service; confirm obligations if you distribute |
| Whisper / WhisperX | transcripts | permissive (verify exact repo license) | TO CONFIRM | |
| Remotion | video templates | source-available; commercial license may be required above a small team size | TO CONFIRM | Check current terms |
| Fonts | templates | per font | TO CONFIRM | Use OFL/commercial-licensed fonts; list them here |
| Music / SFX | audio | per track | TO CONFIRM | Original or cleared only |
| Persona reference/LoRA | identity | you own it | cleared (if trained on your own original art) | Do not train on a real person |

## Customer-facing use raises the bar
Running models for your own accounts and serving outputs to paying third parties are different license situations. Before any component appears in a public template (`docs/TEMPLATE-SPEC.md`), re-check its license for third-party/commercial service use, territory, revenue thresholds and attribution. Also confirm Comfy API's terms for multi-tenant resale.

## Process
1. Add a row before introducing any new component.
2. A workflow's `*.contract.yaml` lists the components it uses; CI-style check (Phase 1) fails if any are not `cleared`.
3. Keep screenshots/links of license text in your own records.
