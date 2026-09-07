# Maturity ladder

Gates switch **on** as the stage rises. Nothing earned is ever removed — a Stage 0 gate
still runs at Stage 2. Set the stage with the `SIFT_STAGE` env var (local) and the
`SIFT_STAGE` repository variable (CI). `just check` reads it and runs the right set.

| Gate | S0 · POC | S1 · Hardening | S2 · Production |
|---|:--:|:--:|:--:|
| format (`fmt`) | ✓ | ✓ | ✓ |
| lint | ✓ | ✓ | ✓ |
| typecheck | ✓ | ✓ | ✓ |
| unit + contract tests | ✓ | ✓ | ✓ |
| schema-validate (Envelope, draft 2020-12) | ✓ | ✓ | ✓ |
| eval gate | smoke | full golden set | full + regression |
| injection probes (untrusted-doc adversarial) | — | ✓ | ✓ |
| coverage floor | — | ✓ | ✓ |
| secret scan (gitleaks) | warn | ✓ block | ✓ block |
| dependency / SCA scan | — | warn | ✓ block |
| SAST (semgrep / CodeQL) | — | — | ✓ block |
| SBOM (syft) | — | — | ✓ |
| signed commits + spec-linked provenance | encouraged | ✓ | ✓ enforced |

## Why staged
SIFT ingests **untrusted counterparty documents**, so the injection-probe and eval gates
are treated as first-class from S1 — they are product-security controls, not just dev
hygiene. The supply-chain tier (SAST/SCA/SBOM) lands at S2 when SIFT stops being a POC and
enters the org's assurance path. Design the pipeline so these are *switches*, not rewrites.

## To advance a stage
1. Bump `SIFT_STAGE` (env + CI repo variable).
2. Run `just check` locally; fix what the newly-active gates surface.
3. Record the transition as an ADR/SCR (what turned on, why now).
