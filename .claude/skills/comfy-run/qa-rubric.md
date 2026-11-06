# Render QA rubric (defaults; calibrate against human verdicts)

Score each 1–5 from the sampled frames and the deterministic report.

| Criterion | 5 | 3 | 1 |
|---|---|---|---|
| **Persona consistency** | face, hair, outfit match the reference sheet in every frame | minor drift | different character |
| **Artifacts** | none | brief warping/hand/teeth issues | obvious melting, extra limbs |
| **Temporal stability** | smooth | slight shimmer | flicker/jumps |
| **Lip-sync** (if speech) | matches | slightly off | clearly off |
| **Framing and composition** | matches the shot list | acceptable | wrong subject/crop |
| **Clean frame** | no stray text/watermark | faint | visible junk text |

**Pass:** every criterion ≥ 3, persona consistency ≥ 4, mean ≥ 3.8.
Deterministic checks must also pass: duration within ±0.5 s of the plan, resolution and fps as contracted, audio present if required, file readable.

## Fix table for retries
| Weak criterion | Try |
|---|---|
| Persona consistency | raise reference/identity strength; pick a cleaner reference frame; run the face-fix pass (license-cleared models only) |
| Artifacts | new seed; slightly more steps; simpler motion in the prompt; avoid hands-on-object shots |
| Temporal stability | lower motion strength; shorter length; frame interpolation in the post pass |
| Lip-sync | regenerate the voice track at steady pace; use the lip-sync pass |
| Framing | tighten the shot description; set explicit aspect/crop params |
| Clean frame | add negative prompt for text/watermark; different seed |

Record scores in `renders.qa` as `{criterion: score, pass: bool, notes}`. The final pass gets deterministic checks plus a 3-frame spot check, not the full rubric.
