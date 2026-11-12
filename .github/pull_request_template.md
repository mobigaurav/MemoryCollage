## Summary
<!-- What changed and why, in two or three sentences. -->

Closes #<issue>

## Base branch

- A feature or fix targets `dev` (branch `DEV_<N>`, squash merge).
- A release targets `main` and comes from `dev` (merge commit, label `release`). Merging it deploys the site.

## Plan
- Approved plan: <link to the plan comment on the issue>
- Deviations from the plan: none | <list>

## Architecture docs
<!-- Filled by the architect agent. Required by the docs-check job when scripts/, workflows, infra/,
     services/api/mb_api/, app services/data, pubspec or web hosting config change. Use one of the two lines. -->
Sections changed: <file and section numbers, ADRs>
Docs not needed: <reason, delete this line if docs changed>

## Changes
- [ ] Flutter app (`memory_book/`)
- [ ] API (`services/api`)
- [ ] Web (`apps/web`)
- [ ] Infra, workflows or scripts (approval link: )
- [ ] Store version bump in `memory_book/pubspec.yaml` (release notes below)
- [ ] Docs (SYSTEM_DESIGN / BACKEND / README)
- [ ] Agents / skills (version bumped, eval cases run)

## Test plan
- [ ] `./flutterw analyze` and `./flutterw test` pass (app changes)
- [ ] `make api-test` passes (API changes)
- [ ] `cd apps/web && npm run build` passes (web changes)
- [ ] `ruff check scripts tests`, `pytest -q tests` and `make agents-check` pass (script or agent changes)
- [ ] Checked on a simulator or in the browser (screenshots below)

## Screenshots / evidence

## Authored by
<!-- human | agent:<name> via <Copilot> -->
