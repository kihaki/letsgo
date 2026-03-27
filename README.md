# LetsGo

A structured development workflow for [Claude Code](https://claude.ai/code). Turns a one-line feature description into a reviewed, implemented pull request — with automated review gates at every stage.

Works with any git repository. No project-specific configuration needed.

## Quick Start

```bash
git clone https://github.com/kihaki/letsgo.git
cd orchestrator
./install.sh
```

Then, from any git repo:

```bash
# Interactive — opens Claude, you type /feature to begin
letsgo

# With a prompt — jumps straight into the workflow
letsgo add dark mode support to the settings screen
```

## What It Does

`letsgo` creates a git worktree with an auto-generated branch off the default branch, then opens Claude Code in that isolated workspace. The `/feature` command drives a 9-phase workflow:

```
Idea ──> Requirements ──> Plan ──> Code ──> PR
           reviewed       reviewed   reviewed   reviewed
```

### The 9 Phases

| # | Phase | What happens |
|---|-------|-------------|
| 1 | **Requirements** | Clarifying questions, writes `requirements.md` |
| 2 | **Idea Review** | AI reviewer stress-tests the idea for scope, risks, and alternatives |
| 3 | **Branch Rename** | Renames random branch to descriptive name (e.g. `feature/add-dark-mode`) |
| 4 | **Planning** | Explores codebase, writes `plan.md` with approach, changes, risks |
| 5 | **Plan Review** | 5 specialized reviewers run in parallel (see below) |
| 6 | **Implementation** | Executes the plan, runs lint/tests |
| 7 | **Local Review** | Cold first-principles code review of the diff |
| 8 | **Commits & PR** | Structured commits, push, create PR |
| 9 | **GitHub Review** | Posts inline review comments, implementer addresses every one |

Every phase with user interaction presents **selectable options** — click to proceed, no typing needed.

### The 5 Plan Reviewers (Phase 5)

All run in parallel and write independent review artifacts:

| Reviewer | Focus |
|----------|-------|
| **Architecture** | Does the plan respect existing patterns, data flow, and module boundaries? |
| **Edge Cases** | Exhaustive failure modes — nulls, boundaries, race conditions, platform quirks |
| **First Principles** | Challenges assumptions — is this solving the right problem? Is there a simpler way? |
| **Simplicity** | Can anything be eliminated? Shows concrete simpler alternatives |
| **Ecosystem** | Searches the web — do existing dependencies already provide this? Any new APIs? |

After all reviewers complete, feedback is synthesized and the plan is auto-revised before presenting to you.

## How It Works

### File Layout

```
letsgo/
├── install.sh                  # Symlinks everything into place
├── bin/
│   └── letsgo                  # CLI entry point
└── commands/
    ├── feature.md              # 9-phase workflow (/feature)
    └── rename-branch.md        # Branch rename utility (/rename-branch)
```

After installation:

| Source | Installed to | Purpose |
|--------|-------------|---------|
| `bin/letsgo` | `~/.local/bin/letsgo` | Shell command |
| `commands/*.md` | `~/.claude/commands/` | Claude Code slash commands |

### Worktree Structure

Each `letsgo` invocation creates an isolated worktree:

```
your-repo/
├── ...                                    # Your main checkout
└── ../.worktrees/your-repo/
    └── bold-nexus-a3f1/                   # Isolated worktree
        ├── ...                            # Full repo copy
        └── .claude/settings.local.json    # Auto-granted permissions
```

### Artifacts

Workflow artifacts live in `/tmp/letsgo/<repo>/<branch>/artifacts/` — they are **not** committed to the repo:

```
/tmp/letsgo/your-repo/bold-nexus-a3f1/
├── session.json              # Branch, base, timestamps
└── artifacts/
    ├── requirements.md       # Phase 1
    ├── idea-review.md        # Phase 2
    ├── plan.md               # Phase 4
    ├── review-architecture.md    # Phase 5
    ├── review-edge-cases.md      # Phase 5
    ├── review-first-principles.md # Phase 5
    ├── review-simplicity.md      # Phase 5
    ├── review-ecosystem.md       # Phase 5
    ├── review-local.md       # Phase 7
    └── changelog.md          # Phase 6
```

## Git Behavior

All git activity is designed to look indistinguishable from a human developer:

- Commits use the repo's locally configured `user.name` and `user.email`
- No AI attribution, co-authored-by lines, or mentions of automated tooling
- Structured commits that follow a logical implementation timeline
- PR descriptions read as if written by the developer

## Configuration

| Variable | Default | Purpose |
|----------|---------|---------|
| `LETSGO_WORKTREE_ROOT` | `.worktrees` | Directory name for worktrees (relative to repo parent) |

## Requirements

- [Claude Code](https://claude.ai/code) CLI
- `git` with worktree support
- `gh` CLI (for PR creation and GitHub reviews)
- `openssl` (for random branch name generation)

## Portability

Clone the repo on a new machine, run `./install.sh`, done. The install script creates symlinks back to the repo, so pulling updates takes effect immediately.
