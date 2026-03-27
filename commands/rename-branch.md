Rename the current feature branch to a descriptive name.

1. Ask the user what the feature is about (or use context from the conversation).
2. Generate a short kebab-case slug (e.g., `add-meal-search`, `fix-auth-timeout`).
3. Rename: `git branch -m feature/<slug>`
4. If a session.json exists in `/tmp/orchestrator/`, update it with the new branch name.
5. Confirm the rename to the user.
