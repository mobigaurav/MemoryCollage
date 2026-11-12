# Approvals

| Action | Who approves | How |
|---|---|---|
| Implementation plan | Requester or a CODEOWNER | Comment starting with `approve`, `approved` or `lgtm` (an admin or maintainer comment adds `agent:approved` automatically via `approve-on-comment.yml`), or add the label |
| PR into `dev` | CODEOWNER (not the author) | GitHub review; CI must pass. Automated builds: the owner clicks "Approve workflows to run" on the PR (GitHub holds CI on workflow-opened PRs); `agent-merge.yml` merges after API, Web, Flutter, agents-check, branch-policy, docs-check and plan-gate pass |
| Starting an automated build | Owner or maintainer | The plan approval itself (`approve` comment dispatches `agent-build.yml`); repo variable `AGENT_BUILD_ENABLED=false` turns builds off |
| Release `dev -> main` (deploys the web site) | CODEOWNER | Merge the `release` PR, or an admin/maintainer comments `ship` on it (`ship-on-comment.yml` merges after the required checks pass). The deploy closes the included issues |
| Workflow, ruleset, secret, `infra/` or policy change | Repo admin | Explicit approval comment on the issue |
| Store build, signing, store listing or privacy answers | Owner only | Done by the owner outside the agent flow; agents may only prepare notes and the version bump |
| Sending messages or reports to anyone | Owner | Names the recipients in the issue |

Until a second maintainer is named, required approvals on rulesets are 0 and the owner merges. Raise
`required_approving_review_count` to 1 when a second CODEOWNER joins.
