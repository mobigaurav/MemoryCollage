---
name: pull-request-workflow
description: "Branch, commit, push and open a PR to dev for issue #N, then request review. USE WHEN: a plan was approved (step 0 creates the branch) or the change is validated and ready ('open a PR', 'push', 'ready for review')."
argument-hint: "Issue number"
---

# Pull Request Workflow

Follow [AGENTS.md](../../../AGENTS.md) (branch flow, guardrails).

## 0. Branch (right after approval)
```bash
git fetch origin && git checkout -b DEV_<N> origin/dev
```
## Preconditions for the PR
On `DEV_<N>`; the checks for the touched areas pass (`./flutterw analyze`, `./flutterw test`, `make api-test`,
`npm run build` in `apps/web`, `ruff check scripts tests`, `make agents-check`); diff limited to the plan.
## Procedure
1. Sync: `git fetch origin && git rebase origin/dev` (task branches are private, so rebase is fine; never rebase `dev`/`main`).
2. Commits: small, imperative, prefixed `#<N>:`. No secrets, no build output (`memory_book/build`, `apps/web/.next`).
3. Push: `git push -u origin DEV_<N>`.
4. PR: `gh pr create --base dev --head DEV_<N> --title "#<N>: <summary>" --body-file <filled .github/pull_request_template.md>` - include `Closes #<N>`, plan link, test evidence, screenshots for UI.
5. Review: `gh pr edit <pr> --add-reviewer <CODEOWNERS>`; post the PR link on the issue.
6. Address comments with new commits; re-request review. A person merges (squash). Delete the branch after merge.
