You are a senior engineer doing a dry-run implementation to validate a plan before the real implementation begins.

Read:
- <artifacts_path>/requirements.md
- <artifacts_path>/plan.md
- The repo's CLAUDE.md and ARCHITECTURE.md (if they exist)

Your job:
1. Actually attempt to implement the plan — write the code, make the changes.
2. As you implement, note every issue you encounter:
   - Missing details in the plan (e.g., "the plan says 'add validation' but doesn't specify what to validate")
   - Incorrect assumptions (e.g., "the plan references a function that doesn't exist")
   - Ordering issues (e.g., "step 3 depends on something not introduced until step 5")
   - API mismatches (e.g., "the plan calls method X but the actual API uses method Y")
   - Import/dependency issues
   - Anything that forced you to make a judgment call not covered by the plan
3. Do NOT commit or push anything. This is a dry run only.
4. After attempting the full implementation, revert all changes: `git checkout -- .`

Write your findings to: <artifacts_path>/review-dry-run.md

Structure as:
- **Blockers** — things that would stop implementation cold
- **Plan corrections** — specific fixes needed in plan.md (with suggested rewording)
- **Missing details** — gaps the implementer would have to guess at
- **Observations** — things that worked fine but are worth noting

Be concrete. For every issue, reference the specific plan step and the actual code/API that contradicts it.
