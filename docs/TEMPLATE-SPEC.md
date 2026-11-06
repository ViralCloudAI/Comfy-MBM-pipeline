# Template spec (the shared contract between the engine and a future product)

A **template** is a locked ComfyUI workflow that someone can run without seeing or changing the graph. The engine's internal workflows and the product's public catalog use the **same** spec, so a workflow can be *promoted* from internal to product without rework. Everything is optional for internal-only workflows (leave the contract's `template:` block empty).

## Where it lives
`workflows/contracts/<workflow>.contract.yaml` → optional `template:` block (see `_example.contract.yaml`). The product repo keeps its own `templates/` catalog and copies/pins promoted contracts; it never reads this repo's database or keys.

## Manifest fields
| Field | Meaning |
|---|---|
| `id`, `version` | stable slug; **semver**. A published version is immutable: any graph/model change is a new version |
| `display_name`, `tagline`, `category` | `swap` · `effect` · `image_edit` · `upscale` · `caption` · `utility` |
| `safety_class` | `low` (non-face media) · `face_input` (any human face in inputs/outputs) · `high` (anything that could depict real people in sensitive contexts). `face_input` and `high` require the full safety stack |
| `consent_required` | true when a user's likeness is processed |
| `inputs_ui` | per input title: label, help text, accepted types, size/duration/resolution limits, max faces |
| `credits` | product price in credits, derived from measured COGS (never guessed) |
| `previews` | storage paths to demo outputs |
| `comfy` | pinned Build/release IDs, GPU profile per pass (draft/final) |
| `components` | every model/node with its `knowledge/licenses.md` status |
| `output_policy` | watermark on/off by plan, C2PA marking, visible AI label, retention period |
| `status` | `draft → internal → beta → public → deprecated` |

## What is locked vs exposed
- **Exposed:** user media, a small set of presets/sliders, optional text, length/aspect choices within safe ranges.
- **Locked:** the graph, models, LoRAs, samplers/steps, negative prompts, seeds policy, safety checks, resolution caps.

## Promotion checklist (internal → product)
1. Every component `cleared` for third-party commercial use (not just internal use).
2. Contract complete: input validation rules, draft/final profiles, output node, timeouts including cold start.
3. Golden clips pass on the pinned release; QA rubric thresholds recorded.
4. Cost measured on the target GPU; `credits` set from COGS with margin.
5. Safety class assigned; moderation points defined (pre-input, pre-generation, post-output); consent flow attached when required.
6. Previews rendered from original content or licensed/owned inputs.
7. Rollback plan: previous version stays deployable.
8. Human sign-off (product lead; trust-and-safety for `face_input`/`high`).

## Versioning and deprecation
Immutable versions · new release = new version · keep N-1 live for in-flight jobs and API clients · announce deprecation with a date · never silently change outputs.

## Input validation rules (minimums)
File type allowlist, size/duration caps, resolution caps, face count limits, nudity/minor/violence screening, malware scan, EXIF stripped, per-user rate and spend limits.

## Mapping to the engine
The engine's agents use the same contracts for internal renders (`studio` via `comfy_run`). A promoted template is therefore tested in production on our own content first.
