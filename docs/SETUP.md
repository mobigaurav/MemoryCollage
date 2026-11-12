# Setup guide (owner steps)

Things only a repository admin can configure so the agent flow works. Nothing here is a secret in the
repo; do not paste secret values into issues or comments.

## 1. Copilot access for the workflows
`plan-on-issue.yml` and `agent-build.yml` run GitHub Copilot CLI (`npm install -g @github/copilot`) and
authenticate with the job token plus the permission `copilot-requests: write`. There is **no Copilot token
secret to create**. Requirements:
- The repository owner account (or organization) has a Copilot plan that allows Copilot CLI in GitHub Actions.
  If a run says the permission is unavailable or unauthorized, enable Copilot CLI / coding agent for the repo
  in Settings > Copilot, or ask GitHub support to enable `copilot-requests`.
- Optional repository variables (Settings > Secrets and variables > Actions > Variables):

| Variable | Meaning |
|---|---|
| `AGENT_BUILD_ENABLED` | Set to `false` to turn automatic builds off |
| `BUILD_MODEL` | Copilot model for builds (default: Copilot's default) |
| `PLANNER_MODEL` | Copilot model for plans |
| `PLANNER_DAILY_CAP` | Maximum automatic plans per day |

## 2. Actions settings
Settings > Actions > General:
- Workflow permissions: **Read and write**, and tick **Allow GitHub Actions to create and approve pull requests**.
- Fork pull request workflows: require approval. PRs opened by `github-actions[bot]` always wait for the owner
  to click **Approve workflows to run**; that click is the intended human gate.

## 3. Labels to create
`type:feature`, `type:bug`, `type:chore`, `agent:proposed`, `agent:plan-ready`, `agent:approved`,
`agent:in-progress`, `agent:awaiting-ci-approval`, `agent:needs-human`, `released`, `release`.
```bash
for l in type:feature type:bug type:chore agent:proposed agent:plan-ready agent:approved agent:in-progress \
         agent:awaiting-ci-approval agent:needs-human released release; do gh label create "$l" 2>/dev/null; done
```

## 4. Branch protection (rulesets)
Create two rulesets (Settings > Rules > Rulesets), no force-push and no deletion on either:

| Ruleset | Target | Merge method | Required status checks |
|---|---|---|---|
| main | `main` | merge commit | API, Web, Flutter, agents-check, branch-policy, docs-check, plan-gate |
| dev | `dev` | squash | API, Web, Flutter, agents-check, branch-policy, docs-check, plan-gate |

- Require a pull request. Required approvals: 0 while you are the only maintainer (raise to 1 when a second
  CODEOWNER joins). `CODEOWNERS` lists `@mobigaurav`; change it if the owner handle differs.
- Set the repository's allowed merge methods to include both squash and merge commit.
- Add the `agents-check`, `branch-policy`, `docs-check` and `plan-gate` checks only after each has run once
  (they appear in the check picker after their first run).

## 5. Environment
No GitHub environment is required for the agent flow. The existing site deploy (`web.yml`) uses repository secrets.

## 6. Existing secrets (unchanged)
`VERCEL_TOKEN` (required for the site deploy; optional `VERCEL_ORG_ID`). Without `VERCEL_TOKEN`, `web.yml`
exits without deploying, so `release-closeout.yml` still closes issues; set the token before a real release.
AWS and store credentials are not used by any workflow. Do not add Apple, Google Play or signing secrets
for agents.

## 7. Local tooling
```bash
make install          # needs Python 3.12 or newer
make test-scripts     # unit tests for scripts/
make agents-check     # validate agents and skills
ruff check scripts tests
```
Flutter: `./flutterw` expects the SDK in `.tools/flutter`
(`git clone --depth 1 -b stable https://github.com/flutter/flutter.git .tools/flutter`).

## 8. First run checklist
1. Merge the setup branch into `dev`, then `dev` into `main` with a release PR (so workflows exist on the default branch;
   issue and comment workflows only run from the default branch).
2. Create the labels and rulesets above.
3. Open a small test issue with the Feature template; the plan should appear within minutes.
4. Comment `approve`; watch the build, click "Approve workflows to run" on the PR.
