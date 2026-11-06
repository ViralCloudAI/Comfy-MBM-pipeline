# Comfy API deployment: workflow → pay-per-use endpoint

Source: official Comfy docs and product page, read **2026-11-06** (`docs.comfy.org` → *Deploying ComfyUI*, *Comfy API Quickstart*, *Comfy API Deployment Guide*, *Running Workflows*, *Comfy API v2*, *SDKs*; `comfy.org/platform/comfy-api`). The product is evolving: re-check before relying on any number. Items still unverified are marked **TO CONFIRM**.

## What you get
**Comfy API** packages a workflow's ComfyUI version, custom nodes, models and Python deps into a reproducible **Build**, cuts a **release**, and runs it as an autoscaling managed **deployment** at `https://{deployment}.run.comfy.app`, serving the Comfy **API v2** with your API key. GPU time is billed **by the second**. Comfy states that all models available on the platform can be used commercially (**TO CONFIRM** for any model with its own license, e.g. MiniMax H3; see `knowledge/licenses.md`).

| Concept | Meaning |
|---|---|
| Workspace | team account: members, Builds, deployments, limits |
| Build | environment definition (`comfy-build.yaml`): ComfyUI version, models, custom nodes, deps. No charge to store builds/releases |
| Release | numbered Build version prepared for a target (e.g. `linux/nvidia`) |
| Deployment | running endpoint using a release; has its own GPU, region, worker bounds |

## Path A: one-shot from the ComfyUI app
**Workflow actions → Deploy to Comfy API** (local app, Comfy Cloud, Desktop). It activates the workflow and lists node packs, models and node classes; **Deploy on Platform** opens the Build Wizard at `platform.comfy.org` (import workflow JSON or a Desktop snapshot; review and fix missing models/deps; create a release). **Build with your agent** copies a brief for a coding agent that follows `comfy skills show comfy-build`: it confirms before upload and before the first cut, fixes one cause per cut, stops after three cuts, and stops at a green release; deploying is a separate decision.

## Path B: CLI
```bash
pip install -U comfy-cli
comfy skills show comfy-build ; comfy skills show comfy-deploy
comfy build init --name "mbm-studio" --models-dir ./models --custom-nodes-dir ./custom_nodes
comfy build push
comfy build refs build-targets
comfy build release create --target linux/nvidia --watch
comfy deploy refs compute [--region <region>]                       # GPU/region catalog + current rates
comfy deploy up --gpu <gpu> --region <region> --min 0 --max <N> --watch
comfy deploy run --workflow workflow_api.json --deployment <dep_id> --output-dir ./results
```
Operate: `comfy deploy status --watch` · `scale --deployment <id> --min A --max B` · `stop|start --deployment <id>` · `logs|events --deployment <id>` · `build status|update --yes|ls|show` · `build release ls|show|logs`. **Irreversible and separate:** `comfy deploy delete --yes`, `comfy build delete --id <id> --yes`.

## Cost behavior (verified)
- `--min 0`: the whole deployment **scales to zero and bills no compute while idle**; the first request cold-starts.
- `--min N ≥ 1`: **active workers**, billed per second continuously whether or not they run jobs.
- Workers above `--min` up to `--max` are **flex workers**: billed per second from start (including startup and model loading), through the job, plus a short idle window (**currently 30 s**), then they cost nothing.
- Each worker has a fixed 50 GB ephemeral container disk, included in the GPU price. Requests beyond capacity are **queued**.
- **Network storage** (models, shared read-only by workers) bills per GB-month **while any deployment of the Build exists in the region, including while paused**. Deleting the last deployment ends it.
- If workspace credits run out, **deployments stop automatically**.

Rates at time of writing (Comfy API page): RTX PRO 6000 96 GB **$3.49/h**; RTX PRO 6000 MIG 48 GB **$1.75/h** (about half the speed); H100 SXM 80 GB $6.23/h; H200 141 GB $7.71/h; B200 180 GB $11.23/h; network storage **$0.20/GB-month**. Always confirm with `comfy deploy refs compute`.

## Plan limits (per workspace)
| | Standard | Creator | Pro | Team |
|---|---|---|---|---|
| Builds | 5 | 5 | 10 | 40 |
| Deployments | 2 | 2 | 5 | 20 |
| Max worker concurrency per deployment | 2 | 2 | 10 | 20 |
Keep `--max` within the per-deployment worker limit. Each deployment has one GPU type: use two deployments of one Build for a cheap draft GPU and a stronger final GPU. One Build can serve several workflows (upload them all in the Builder; submit each API-format workflow to the endpoint).

## Calling it (what `scripts/comfy_run` wraps)
- Python SDK `pip install comfy-sdk`; `COMFY_BASE_URL=https://<deployment>.run.comfy.app`, `COMFY_API_KEY`; `Comfy(api_key=...)`; `client.run(wf)` or `client.submit(wf, idempotency_key=..., metadata={...})`.
- HTTP: `Authorization: Bearer $COMFY_API_KEY`. (The older v1 Cloud API used `X-API-Key`; do not mix them up.)
- v2 is poll-first (GET job state is the source of truth; SSE events are optional). Submission is idempotent via `idempotency_key`; **reusing a key returns 422 `idempotency_key_reuse` instead of replaying** the first job.
- Outputs: the job's output URL is authenticated and stable; the **signed URL lasts about 6 hours**. Re-host bytes to Supabase Storage. Job `metadata` labels work on deployments (not on Comfy Cloud).
- Comfy Cloud (`https://cloud.comfy.org`, paid plan) runs supported workflows without a Build; v2 works there too. Use it for prototyping.

## Pre-flight checklist for this repo
1. Workflow runs cleanly locally; exported in **API format**; input nodes titled (see `workflows/README.md`).
2. Every custom node and model has a license entry in `knowledge/licenses.md` (replace non-commercial / AGPL components such as InsightFace `buffalo_l` and Bingsu/adetailer weights, per the openjutsu reference).
3. Build contents reviewed; release green; first deployment created with `--min 0` and a low `--max`.
4. 3-second smoke test through `comfy_run`; real cost recorded in `docs/COST-MODEL.md`.
5. Credits balance alert set; `MBM_DAILY_BUDGET_USD` matches it.

## Still TO CONFIRM
GPU availability by region (`comfy deploy refs compute`) · measured cold-start with this Build's models · maximum job duration / request timeout · webhook support (docs describe polling and SSE) · whether the 30 s idle window is configurable · partner-node (API model) billing · per-job output retention (docs call the 30-day expiry a placeholder) · whether `comfy-build.yaml` can pin multiple releases per deployment for safe rollbacks.

## Plan B: RunPod Serverless
Same API-format workflow, same parameter contract; `scripts/comfy_run` selects the backend by `MBM_COMFY_BACKEND` (`comfy_api` default, `runpod`, `comfy_cloud`, `local`). Use the official `worker-comfyui` image, a network volume at `/runpod-volume`, FlashBoot, `workersMin=0`. Switch only if measured cost, custom-node compatibility, or capacity makes Comfy API unworkable. Live RunPod rates: **TO CONFIRM**.

## Reference: openjutsu notes that apply
Cloud deployment is untested there; clip-checkpoint resume needs an `output/` that a fresh worker lacks, so treat every job as restartable from zero. Its `comfy-api-proxy` (port 8189) serves the v2 API over a local ComfyUI, which is how to develop against the same client code before deploying.
