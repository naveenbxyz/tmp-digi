# SIFT starter kit — Copilot + Sonnet 5 operating layer

A framework-agnostic **workflow and gate layer** for building SIFT with GitHub Copilot
(agent mode, Claude Sonnet 5) in VS Code. It wraps — it does not replace — your existing
SIFT artifacts: the constitution, module specs 000–011, the Envelope Contract, and your
AGENTS.md. Drop these files into the repo root; merge `AGENTS.md` and
`.github/copilot-instructions.md` with anything you already have.

## What's here
- `.github/copilot-instructions.md` — always-on rules (the discipline, injected every turn)
- `.github/agents/` — Planner → Implementer → Reviewer, chained by handoff
- `.github/prompts/` — `/specify`, `/plan`, `/implement`, `/review` (carry the spec flow;
  Spec-Kit-CLI-compatible if you adopt it later)
- `justfile` — the exact commands the agent must run green before "done"
  (hybrid Java+Python and all-Python variants, switched by `SIFT_LANG`)
- `STAGES.md` + `.github/workflows/gates.yml` — the maturity ladder; gates switch on by stage
- `AGENTS.md` — thin, harness-agnostic pointer so non-Copilot hosts read the same rules

## Two variables control everything
| Variable | Default | Meaning |
|---|---|---|
| `SIFT_STAGE` | `0` | Gate maturity: 0 = POC, 1 = hardening, 2 = production. See `STAGES.md`. |
| `SIFT_LANG` | `hybrid` | `hybrid` (Java core + Python sidecar) or `python` (all-Python). |

Progressing to the next stage is a one-line bump, not a rewrite. The language decision is
still open (see the discussion that shipped with this kit) — the kit runs either way.

## Daily loop
1. `/specify` a small increment against the Envelope Contract.
2. `/plan` — Planner drafts the approach and the gate targets; you approve.
3. `/implement` — Implementer writes the smallest diff, runs `just check`, iterates to green.
4. `/review` — Reviewer (cold context) runs the delete pass + adversarial/injection probes.
5. Conventional commit linked to the spec/task id. Merge when `just check` is green for the stage.
