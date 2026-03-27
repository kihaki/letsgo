You are running the **Feature Workflow** — a structured, multi-phase process for turning a feature idea into a reviewed, implemented PR.

# Session setup

1. Read the session metadata from `/tmp/orchestrator/*/session.json` (find the one matching this repo).
2. Create a scratch directory for this feature's artifacts: `/tmp/orchestrator/<repo>/<branch-slug>/artifacts/`
3. All `.md` artifacts produced during this workflow go in that scratch directory.

# Workflow phases

Execute these phases in order. **Stop and wait for user input at every checkpoint (marked with ⏸️).**

# Checkpoint format

At every checkpoint, use the **AskUserQuestion** tool to present selectable options. This gives the user clickable choices instead of typing. Always:
- Make the first option the "proceed" action (recommended)
- Include 2-3 tailored alternatives for the phase
- The tool automatically adds an "Other" free-text option, so you don't need a "I have feedback" option
- Add "(Recommended)" to the first option's label when proceeding is the expected path
- Write a brief summary of what happened as text output BEFORE calling AskUserQuestion

---

## Phase 1: Requirements Gathering

**Goal:** Understand what the user wants to build.

1. Ask the user: *"What do you want to build?"*
2. Ask clarifying questions — dig into edge cases, scope, and acceptance criteria.
3. Keep asking until you have a clear picture. Don't rush this.
4. Write `requirements.md` to the artifacts directory with:
   - **Summary** (1-2 sentences)
   - **User stories** or **acceptance criteria**
   - **Out of scope** (explicitly)
   - **Open questions** (if any remain)

⏸️ **Checkpoint:** Present the requirements summary, then use AskUserQuestion:
- Question: "How do the requirements look?"
- Options:
  - "Looks good (Recommended)" — Proceed to idea review
  - "Scope too broad" — Help trim the scope, then re-present
  - "Missing something" — Ask what's missing, update requirements

---

## Phase 2: Idea Review

**Goal:** Stress-test the idea before investing in a plan.

1. Read the reviewer prompt from `~/.claude/letsgo/reviewers/idea.md`, replace `<artifacts_path>` with the actual path, and spawn an **Idea Reviewer** subagent with that prompt.

2. Read the idea review and present a summary to the user.
3. Highlight any concerns or suggested alternatives.

⏸️ **Checkpoint:** Present the reviewer's key points, then use AskUserQuestion:
- Question: "How do you want to handle the review feedback?"
- Options:
  - "No concerns, proceed (Recommended)" — Move to planning
  - "Adjust requirements" — Auto-update based on feedback and re-review
  - "Disagree with feedback" — Explain why and proceed anyway

If adjustments are chosen, update `requirements.md` and re-run the review.

---

## Phase 3: Branch Rename

Now that requirements are clear, rename the branch to something descriptive:

1. Derive a short slug from the feature summary (e.g., `add-meal-search`, `fix-sync-conflict`).
2. Rename the branch: `git branch -m feature/<slug>`
3. Update `session.json` with the new branch name.
4. Inform the user of the new branch name.

---

## Phase 4: Planning

**Goal:** Create a concrete implementation plan.

1. Explore the codebase to understand relevant existing code, patterns, and architecture.
2. Write `plan.md` to the artifacts directory with:
   - **Approach** — high-level strategy (1-3 sentences)
   - **Changes** — ordered list of files to create/modify, with what changes
   - **Dependencies** — any new libraries, migrations, or infra changes needed
   - **Testing strategy** — what to test and how
   - **Risks** — what could go wrong

Keep it concise. Decisions, not essays.

**No checkpoint here — immediately launch all reviewers.**

---

## Phase 5: Plan Review

**Goal:** Stress-test the plan from multiple angles before implementation.

Launch **all five reviewers in parallel** (use multiple Agent tool calls in a single message). For each reviewer, read its prompt from `~/.claude/letsgo/reviewers/<name>.md`, replace `<artifacts_path>` with the actual artifacts path, and spawn a subagent with the result.

| Reviewer | Prompt file | Output artifact |
|----------|-------------|-----------------|
| Architecture | `architecture.md` | `review-architecture.md` |
| Edge Cases | `edge-cases.md` | `review-edge-cases.md` |
| First Principles | `first-principles.md` | `review-first-principles.md` |
| Simplicity | `simplicity.md` | `review-simplicity.md` |
| Ecosystem | `ecosystem.md` | `review-ecosystem.md` |

### After all reviews complete

1. Read all five review artifacts.
2. Synthesize a consolidated summary — group feedback by theme, note where reviewers agree or disagree.
3. Auto-revise `plan.md` incorporating feedback that is clearly correct (fixing real issues, using existing APIs, simplifying).
4. Present the consolidated review and the updated plan to the user.

**No checkpoint here — immediately launch the dry run.**

---

## Phase 6: Dry Run

**Goal:** Validate the plan by attempting a trial implementation before the real one.

Read the reviewer prompt from `~/.claude/letsgo/reviewers/dry-run.md`, replace `<artifacts_path>` with the actual path. Spawn a **Dry Run** subagent in an isolated worktree (use `isolation: "worktree"`) so it can freely write code without affecting the real branch.

After the dry run completes:

1. Read `review-dry-run.md`.
2. If there are **blockers** or **plan corrections**, auto-revise `plan.md` to fix them.
3. Present the consolidated review summary, dry run findings, and final plan to the user.

⏸️ **Checkpoint:** Present everything together (review summary + dry run findings + final plan), then use AskUserQuestion:
- Question: "Plan has been reviewed and dry-run validated. Ready to implement?"
- Options:
  - "Looks good, implement it (Recommended)" — Proceed to implementation
  - "Show me what changed in the plan" — Diff the original vs final plan
  - "Run another review round" — Re-run all reviewers and dry run on the updated plan

---

## Phase 7: Implementation

**Goal:** Execute the plan.

1. Implement the changes described in `plan.md`, following the order specified.
2. Run formatting/lint checks if available (check CLAUDE.md for commands).
3. Run relevant tests if available.
4. Write `changelog.md` to artifacts with a brief summary of what was done.

⏸️ **Checkpoint:** Present implementation summary, then use AskUserQuestion:
- Question: "Ready for pre-PR review?"
- Options:
  - "Looks good, review it (Recommended)" — Proceed to local review
  - "Show me the diff first" — Run git diff and present before proceeding
  - "Run tests first" — Execute tests before proceeding

---

## Phase 8: Local Review

**Goal:** Catch issues before the PR is created.

Read the reviewer prompt from `~/.claude/letsgo/reviewers/local.md`, replace `<artifacts_path>` with the actual path and `<base_branch>` with the base branch from `session.json`. Spawn a **Local Review** subagent with that prompt — it has no context from the implementation.

Read the local review. If there are **blockers**, fix them and re-run the review. For **warnings**, fix them. For **nits**, use judgment.

After addressing all findings, present the summary to the user.

⏸️ **Checkpoint:** Present what was found and fixed, then use AskUserQuestion:
- Question: "Local review complete. Ready to create the PR?"
- Options:
  - "Create the PR (Recommended)" — Proceed to PR creation
  - "Show me the diff" — Run git diff before proceeding
  - "Run another review round" — Re-run local review on updated code

---

## Phase 9: Commits & PR

**Git identity rules — strictly enforced:**
- Use the repo's locally configured git user (`user.name` and `user.email`) for all commits. Never override the author.
- Never mention Claude, AI, LLMs, "generated", "co-authored", or any automated tooling in commit messages, PR titles, PR descriptions, or review comments. All git activity must be indistinguishable from a human developer.

**Commit strategy:**
- Create structured, logical commits that tell the story of the implementation — not one giant squash.
- Each commit should be a coherent unit of work (e.g., "Add gradient color constants", "Apply gradient overlay to dashboard background").
- Write commit messages in imperative mood, concise, focused on *what* and *why*.

**PR creation:**
1. Push the branch to origin.
2. Create a PR using `gh pr create` with:
   - Title: concise summary of the feature (imperative mood, under 70 chars)
   - Body: requirements summary, what changed, and how to test — written as if by the developer
3. Present the PR URL to the user.

---

## Phase 10: GitHub Review & Address

**Goal:** Get an unbiased review posted to GitHub, then address every comment.

### 9a: GitHub Review

Read the reviewer prompt from `~/.claude/letsgo/reviewers/github.md`, replace `<PR_NUMBER>` with the actual PR number and `{owner}/{repo}` with the actual owner/repo. Spawn a **GitHub Reviewer** subagent with that prompt — it has NO context from the implementation.

### 9b: Address Review Comments

After the GitHub reviewer completes:

1. Read all review comments: `gh api repos/{owner}/{repo}/pulls/{pr}/comments`
2. Address **every** comment — no comment goes unanswered:
   - **If actionable:** Fix the code, commit, and reply to the comment explaining what was changed.
   - **If disagree:** Reply with a clear reason why the current approach is correct.
   - **If follow-up candidate:** Use AskUserQuestion to ask the user:
     - Question: "Reviewer suggests: [summary]. Do this now or follow-up?"
     - Options:
       - "Do it now (Recommended)" — Implement in this PR
       - "Follow-up" — Reply to the comment noting it as a follow-up
     - **Default bias: do it now.** When in doubt, implement it in this PR rather than deferring.
3. Reply to every comment using `gh api` — never leave a comment without a response.
4. Push any new commits.

Present the final state to the user.

⏸️ **Checkpoint:** Use AskUserQuestion:
- Question: "All review comments addressed. What do you want to do with the PR?"
- Options:
  - "Merge it (Recommended)" — Merge the PR, then clean up
  - "Leave it open" — Done, PR stays open for manual review
  - "Run another review round" — Spawn a fresh reviewer on the updated PR

### If merging:

1. Fetch latest base branch: `git fetch origin <base_branch>`
2. Check for merge conflicts: `gh pr view <PR_NUMBER> --json mergeable`
3. If there are conflicts:
   - Merge the base branch into the feature branch: `git merge origin/<base_branch>`
   - Resolve all conflicts, preserving the intent of the feature changes
   - Commit the merge resolution, push
4. Merge the PR: `gh pr merge <PR_NUMBER> --squash --delete-branch`
5. Present confirmation to the user

---

# Rules

- **Never skip a checkpoint.** Always wait for user confirmation before proceeding.
- **Keep artifacts updated.** If requirements or plan change, update the .md files.
- **Stay in scope.** Don't add things not in the requirements.
- **Match the repo's style.** Read existing code before writing new code.
