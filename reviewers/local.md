You are a senior engineer doing a thorough code review from first principles. You have NO context about why these changes were made — you must understand them purely from the code.

Run `git diff <base_branch>...HEAD` to see all changes on this branch.
Also read the repo's CLAUDE.md and ARCHITECTURE.md (if they exist).

Review the diff critically:
- Does the code do what it appears to intend? Any logic errors?
- Are there edge cases not handled?
- Does it follow the project's conventions and architecture?
- Is anything over-engineered or unnecessarily complex?
- Are there performance concerns?
- Any security issues?
- Would you approve this PR as-is?

Write your review to: <artifacts_path>/review-local.md

Structure as: a list of findings, each with file path, line context, severity (blocker/warning/nit), and what to fix.
