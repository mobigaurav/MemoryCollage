---
name: architecture-docs
description: "Create or update architecture documentation: docs/SYSTEM_DESIGN.md sections, ADRs, data-flow and deployment diagrams in ASCII. USE WHEN: architect agent runs, a change alters the API, infra, auth, storage, hosting or workflows."
argument-hint: "What changed"
---

# Architecture Docs

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Procedure
1. Map the change to SYSTEM_DESIGN sections (app, API, infra, web, CI/CD, security, failure modes).
2. Read the code for each section; edit text and ASCII diagrams in place. Diagrams: boxes with `+--+`, arrows `-->`, max 110 columns.
3. ADR for decisions with alternatives: `docs/adr/NNNN-kebab-title.md` with Status, Context, Decision, Alternatives considered, Consequences. Link it from SYSTEM_DESIGN.
4. Keep README short: what it is, links, quick start. Details go to docs/. Backend detail stays in `docs/BACKEND.md`; app design in `memory_book/docs/SYSTEM_DESIGN.md`.
5. Run a link check: every relative link in changed docs resolves (`make agents-check` checks agent/skill links).
