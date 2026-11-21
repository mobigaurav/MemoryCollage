# Approvals

| Action | Who approves | How |
|---|---|---|
| Implementation plan | Requester or a CODEOWNER | Comment starting with `approve`, `approved` or `lgtm` (an admin or maintainer comment adds `agent:approved` automatically via `approve-on-comment.yml`), or add the label |
| PR into `dev` | CODEOWNER (not the author) | Comment `approve` or `approved` on the pull request (`merge-on-comment.yml`). Checks must pass, then it squash-merges into `dev`. A GitHub review is not required |
| Starting an automated build | Owner or maintainer | The plan approval itself (`approve` comment dispatches `agent-build.yml`); repo variable `AGENT_BUILD_ENABLED=false` turns builds off |
| Release `dev -> main` (deploys the web site) | CODEOWNER | Merge the `release` PR, or an admin/maintainer comments `ship` on it (`ship-on-comment.yml` merges after the required checks pass). The deploy closes the included issues. If that merge changes `memory_book`, `deploy-mobile.yml` also uploads TestFlight and Play internal |
| Workflow, ruleset, secret, `infra/` or policy change | Repo admin | Explicit approval comment on the issue |
| Store build | `deploy-mobile.yml` on `main` | Runs only when `memory_book` changed. TestFlight and Play internal. No App Review submit and no Play production. Listing text and privacy answers stay with the owner |
| Sending messages or reports to anyone | Owner | Names the recipients in the issue |

Until a second maintainer is named, required approvals on rulesets are 0 and the owner merges. Raise
`required_approving_review_count` to 1 when a second CODEOWNER joins.
