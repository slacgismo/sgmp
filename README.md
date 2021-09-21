# SGMP Smart Grid

> Welcome to the SGMP Smart Grid repo.

# Contribution Policy
Since the team is working on a mono repo, certain rules might apply for every one to better contribute to the project.

## Branches
- `master/main` branch is a protected branch. We directly modify it only when necessary and with great caution. Instead, it is more appropriate to create a pull request to `master/main` so we can examine possible conflicts and provide feedbacks on the changes.
- Most of the time, team members work on their own branch, which is prefixed by their Andrew ID. One example would be for Haotian (`hzheng3`), he should work on `hzheng3/dev`, `hzheng3/fix`, and other branches that explictly have `hzheng3/` as prefix. One can decide their own naming system after the `<andrew-id>/` prefix.
- Tags follow the same prefix conventions. 
## Folders
- To prevent conflicts, we divide the root-level folder into four sub-folders, `mobile`, `frontend`, `backend`, and `references` (subject to change based on team discussions). It is recommended that people only put code within the corresponding folder. 
- Overall, current structure looks like this:
  - mobile
  - frontend
  - backend
  - references
    - samples
      - edge_devices
## Commits
- Following [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) standard is endorsed but not enforced.
  - Under conventional commits, each commit comes with a title using format `<type>[optional scope]: <description>`, where:
    - `type` implies the nature of the change, like `feat`, `docs` or `refactor`
    - `scope` means the actual componments changed, like `mobile`, `frontend`, or `backend`.
    - `desc` is where people type in the message they want to add
  - One can use [JetBrains](https://plugins.jetbrains.com/plugin/13389-conventional-commit), [VS Code](https://marketplace.visualstudio.com/items?itemName=vivaxy.vscode-conventional-commits), or [CLI](https://github.com/commitizen/cz-cli) plugins to help commit in the conventional commits standard.

# Contact
- Sponsor
  - Gustavo
- Team Energizer
  - Mobile
    - Haotian
  - Frontend
    - Huilin
  - Backend
    - Yingdong
    - Chih-wei