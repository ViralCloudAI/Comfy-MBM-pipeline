---
paths:
  - "workflows/**"
---

# ComfyUI workflow rules

- Store **API-format** exports only (`*.api.json`), never UI-format graphs.
- **Node titles are the interface.** Scripts inject parameters by title (prompt, ref_image, seed, width, height, length, fps, lora_strength). Never rename a titled node without updating its contract in `workflows/contracts/`.
- Every workflow has a contract (`<name>.contract.yaml`): title → type, default, range, and the output node title.
- A workflow change is deployed as a new Build release. Record the release ID in the contract and re-run the golden clips before promoting.
- No third-party-licensed model without an entry in `knowledge/licenses.md`.
- Keep workflows idempotent and restartable: a fresh worker must be able to run any job from scratch.
