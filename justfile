# SIFT command surface. `just check` runs the gate set for the current stage.
# Two knobs:
#   SIFT_STAGE : 0 (POC) | 1 (hardening) | 2 (production)   -> see STAGES.md
#   SIFT_LANG  : hybrid (Java core + Python sidecar) | python (all-Python)
# Wire the placeholder commands to your real build. The stage logic is the point;
# the exact tool invocations are yours to set.

stage := env_var_or_default("SIFT_STAGE", "0")
lang  := env_var_or_default("SIFT_LANG", "hybrid")

# ---- aggregate gate: dispatches by stage ----
check:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "== SIFT gates :: stage {{stage}} :: lang {{lang}} =="
    just fmt lint typecheck test contract schema
    if [ "{{stage}}" = "0" ]; then just eval-smoke; fi
    if [ "{{stage}}" -ge "1" ] 2>/dev/null; then just eval-full inject coverage secrets; fi
    if [ "{{stage}}" -ge "2" ] 2>/dev/null; then just sast sca sbom provenance; fi
    echo "== gates passed for stage {{stage}} =="

# ---- always-on (S0+) ----
fmt:
    @if [ "{{lang}}" = "python" ]; then ruff format .; \
     else mvn -q spotless:apply && ruff format sidecar/; fi

lint:
    @if [ "{{lang}}" = "python" ]; then ruff check .; \
     else mvn -q spotless:check checkstyle:check && ruff check sidecar/; fi

typecheck:
    @if [ "{{lang}}" = "python" ]; then mypy .; \
     else mvn -q -DskipTests compile && mypy sidecar/; fi

test:
    @if [ "{{lang}}" = "python" ]; then pytest -q; \
     else mvn -q test && pytest -q sidecar/; fi

# Envelope Contract tests: the machine-validated SSI + legal examples are the fixtures.
contract:
    @echo "contract: run Envelope Contract tests (SSI + legal golden examples)"
    @pytest -q tests/contract || true   # <- wire to real contract suite

# JSON Schema draft 2020-12 validation of Envelope + module schemas.
schema:
    @echo "schema: validate Envelope + module schemas (draft 2020-12)"
    @python -m tools.validate_schemas || true   # <- wire to real validator

# ---- eval gates ----
eval-smoke:
    @echo "eval: smoke set (fast, a few golden cases)"
    @echo "  wire to promptfoo/Langfuse eval — subset"

eval-full:
    @echo "eval: full golden set + regression"
    @echo "  wire to promptfoo/Langfuse eval — full"

# ---- S1+ ----
inject:
    @echo "probe: prompt-injection over untrusted-document corpus (must not comply)"
    @echo "  wire to injection probe suite"

coverage:
    @echo "coverage: enforce floor"

secrets:
    @echo "secrets: gitleaks detect --no-banner"
    @command -v gitleaks >/dev/null && gitleaks detect --no-banner || echo "  (install gitleaks)"

# ---- S2 ----
sast:
    @echo "sast: semgrep ci (or CodeQL in CI)"

sca:
    @if [ "{{lang}}" = "python" ]; then echo "sca: pip-audit / uv audit"; \
     else echo "sca: mvn dependency-check + pip-audit sidecar"; fi

sbom:
    @echo "sbom: syft . -o cyclonedx-json"

provenance:
    @echo "provenance: verify signed commits + spec-linked messages"
