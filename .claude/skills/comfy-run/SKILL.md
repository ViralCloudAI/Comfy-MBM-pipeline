---
name: comfy-run
description: "Render a concept through the deployed ComfyUI workflow with scripts/comfy_run: parameter contracts, draft then final, blocking wait, QA rubric, retries, idempotency, output re-hosting and cost logging. Use when a concept is approved for rendering."
---

# Running renders (Comfy API deployment)

Never call the HTTP API by hand and never poll. `scripts/comfy_run` wraps the Comfy SDK (`pip install comfy-sdk`; `COMFY_BASE_URL=https://<deployment>.run.comfy.app`, `COMFY_API_KEY`, `Authorization: Bearer`).

## Flow per concept
```
comfy_run submit --concept ID --pass draft      # builds params from contract + concept.comfy_recipe; idempotency key; job metadata {concept_id, render_id}
comfy_run wait   RENDER_ID                      # blocks inside the script (poll-first, SSE optional); downloads and RE-HOSTS output to Storage
comfy_run qa     RENDER_ID                      # deterministic checks + 6 sampled frames for your judgment
(judge with qa-rubric.md → write renders.qa)
comfy_run submit --concept ID --pass final      # only after draft passes
comfy_run wait   RENDER_ID
```
`MBM_DRY_RUN=1`: `submit` validates parameters against the contract and prints the plan; no paid job.

## Facts that shape the scripts (verified against Comfy docs, Nov 2026)
- Jobs are durable and pollable; submission accepts an **idempotency key**. Reusing a key returns **422 `idempotency_key_reuse`** rather than replaying: treat it as "already submitted", look up the job, don't resubmit.
- Output URLs: the authenticated content URL is stable but needs the key; the **signed URL lasts ~6 h**. Always re-host bytes to Supabase Storage and store the storage path, never a signed URL.
- Job `metadata` labels work on deployments only; use them so provider-side usage can be reconciled to `ledger`.
- A deployment scaled to `--min 0` cold-starts on the first job; the `wait` timeout must cover model load.
- A fresh worker has no previous `output/`; every job must run from scratch.

## Parameters
Only inject by node title, per `workflows/contracts/<workflow>.contract.yaml`. Unknown param → fail fast. Seeds are explicit and recorded.

## Draft vs final
Draft: low resolution/steps/length cap, same seed policy. Final: contract's `final` profile. Never submit final before a draft QA pass.

## QA and retries
Judge with [qa-rubric.md](qa-rubric.md). Max **2** retries per concept, each with a new seed and the rubric's suggested fix. Then `store fail` (`qa_failed`) with the lowest-scoring criteria in the reason.

## Errors
| Symptom | Action |
|---|---|
| exit 2 from budget | stop, report |
| 422 idempotency_key_reuse | look up the existing job; continue with it |
| timeout in `wait` | `comfy_run status RENDER_ID`; if still running, wait once more; else fail with the provider event log |
| 3 consecutive failures on one workflow | stop the batch; flag the workflow (possible bad release or capacity) |
| deployment stopped (credits out) | report to the human; do not retry |
