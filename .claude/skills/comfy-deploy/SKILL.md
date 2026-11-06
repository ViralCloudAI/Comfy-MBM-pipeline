---
name: comfy-deploy
description: "Guided walkthrough to turn your manual ComfyUI workflow into a pay-per-use Comfy API deployment (scale to zero) and wire it into scripts/comfy_run. User-invoked when setting up or updating the render backend."
disable-model-invocation: true
---

# Deploy a workflow to Comfy API

Facts here come from the official docs (read Nov 2026): `docs.comfy.org` → *Deploying ComfyUI*, *Comfy API Quickstart*, *Comfy API Deployment Guide*. Re-read them if a command fails: the product is evolving. The full reference is `docs/COMFY-DEPLOY.md`.

## Path A: one-shot from the ComfyUI app (easiest)
1. Open the workflow → **Workflow actions → Deploy to Comfy API** (local app, Comfy Cloud and Desktop). Review the node packs, models and node classes it lists.
2. **Deploy on Platform** → the Build Wizard at `platform.comfy.org` (starts from the workflow JSON or a Desktop snapshot). Review and fix missing models/dependencies, create a release (`linux/nvidia`).
3. Or click **Build with your agent**: it copies a brief that points an agent at `comfy skills show comfy-build`. The agent confirms before uploading and before the first release cut, fixes one cause per cut, and stops after three cuts. A release is not a deployment; deploying is a separate decision.

## Path B: CLI from a local install
```bash
pip install -U comfy-cli
comfy skills show comfy-build && comfy skills show comfy-deploy      # read the current recipes
comfy build init --name "mbm-studio" --models-dir ./models --custom-nodes-dir ./custom_nodes
comfy build push
comfy build refs build-targets
comfy build release create --target linux/nvidia --watch
comfy deploy refs compute [--region <region>]                         # GPU + region catalog and current rates
comfy deploy up --gpu <gpu> --region <region> --min 0 --max <N> --watch
comfy deploy run --workflow workflow_api.json --deployment <dep_id> --output-dir ./results
```

## Settings that control cost
- `--min 0` → scales to zero; no compute billed while idle; first request cold-starts. `--min ≥ 1` bills continuously.
- `--max` ≤ your plan's per-deployment worker limit (Standard/Creator 2, Pro 10, Team 20).
- One Build can serve several workflows; each deployment has one GPU type. Use two deployments of one Build for a cheap draft GPU and a stronger final GPU.
- Network storage ($0.20/GB-month at time of writing) bills while any deployment of the Build exists, even paused.
- If credits run out, deployments stop automatically.

## After it is live
1. Put `COMFY_BASE_URL`, `COMFY_DEPLOYMENT_ID`, `COMFY_API_KEY` in the environment secrets (never in git).
2. Export the workflow in **API format**, title the input nodes, write `workflows/contracts/<name>.contract.yaml`.
3. Run a 3-second test through `scripts/comfy_run` and record real cost/clip in `docs/COST-MODEL.md`.
4. Record the release ID in the contract; promote only after the golden clips pass.
5. Monitor: `comfy deploy status --watch`, `comfy deploy logs|events --deployment <id>`.

## Ask the user before
Creating a deployment, scaling `--min` above 0, or deleting a Build/deployment (irreversible, separate commands).
