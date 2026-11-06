# Workflows

Your ComfyUI workflows live here as **API-format** JSON (`<name>.api.json`) with a **contract** (`contracts/<name>.contract.yaml`). Scripts address nodes by **title**, never by node ID.

## Add a workflow
1. Make it run cleanly in ComfyUI. In the Workflow menu export **API format** → `workflows/<name>.api.json`.
2. Give each input node a stable **title** (`prompt`, `ref_image`, `seed`, `width`, `height`, `length_frames`, `fps`, `lora_strength`, …) and the output node a title (`output_video`).
3. Copy `contracts/_example.contract.yaml` → `contracts/<name>.contract.yaml` and fill it in: input titles, types, defaults, ranges, draft/final profiles, output title, components used (each must be `cleared` in `knowledge/licenses.md`).
4. Deploy it (`docs/COMFY-DEPLOY.md`); record the release ID in the contract.
5. Run the golden clips; only then reference it from a concept's `comfy_recipe`.

## Patterns borrowed from openjutsu
Parameters are injected by node title (its `lib/simple.ts`-style patchers) · each workflow is a small mode (simple swap, advanced swap, object swap, face-fix, colour-fix) · pre-flight checks that every node class and model file exists · tests assert node pruning against the exports.

## Rules (`.claude/rules/workflows.md`)
API-format only · node titles are the interface · every change is a new release · idempotent, restartable jobs · no unlicensed components.
