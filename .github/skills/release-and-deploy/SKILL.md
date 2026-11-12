---
name: release-and-deploy
description: "Release dev to main and deploy the web site; hotfix and rollback procedures. USE WHEN: 'release', 'ship', 'deploy', 'roll back', a hotfix is needed."
argument-hint: "What to release"
---

# Release And Deploy

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## Release (dev -> main)
1. Check dev is green: `gh run list -b dev -w ci -L 1`.
2. Notes: `git log --oneline origin/main..origin/dev` grouped by issue.
3. `gh pr create --base main --head dev --title "Release YYYY-MM-DD" --label release --body "<notes, issues closed, risks>"`.
4. Merge with a **merge commit** (not squash) so dev and main stay aligned. A person merges, or an admin
   comments `ship` (`ship-on-comment.yml`) once the required checks pass.
5. Merging main deploys the site through `web.yml` (a push, or the dispatch made by `ship`). Verify: run succeeded, the live site loads. Without `VERCEL_TOKEN` the workflow exits without deploying.
6. Released issues close automatically: after a successful `web` run on main, `release-closeout.yml`
   comments "Released", adds `released` and closes every open issue whose merged PR into dev says `Closes #N`.
   Close by hand only if the deploy failed or the PR used `Refs #N`.
7. A store build is separate: see [store-release](../store-release/SKILL.md). Nothing is uploaded by an agent.
## Hotfix
`hotfix/<N>-slug` from `main` -> PR to `main` -> after merge, PR `main -> dev` to back-merge.
## Rollback
Open a revert of the release merge (`git revert -m 1 <merge-sha>`) as a PR to main; the site redeploys on merge. API image rollbacks are owner-only (infra).
