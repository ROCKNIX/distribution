---
description: "Git safety protocols and best practices for repository operations."
applyTo: "**"
---

# Git Safety Protocols

## Destructive Operation Prevention

**NEVER recommend or execute Git head resets without explicit user confirmation and understanding of consequences:**

- **ALWAYS double-check before proposing `git reset --hard` or similar destructive Git operations**
- **Explain potential data loss clearly** before suggesting any reset operations
- **Prefer safer alternatives** like `git stash`, `git checkout`, or creating backup branches
- **Request explicit confirmation** when reset operations are truly necessary

## Safe Alternatives to Consider First

- `git stash push -m "backup before changes"` (preserves work)
- `git checkout -- <file>` (revert specific files)
- `git branch backup-$(date +%Y%m%d)` (create backup branch)
- `git clean -n` (dry run cleanup) then `git clean -f` (actual cleanup)

## Repository Safety Guidelines

- Always create backup branches before major operations
- Use `git status` to understand current state before making changes
- Prefer incremental commits over large, sweeping changes
- Test changes in isolated branches before merging
- Use descriptive commit messages for easier history navigation

## Best Practices for Collaboration

- Never force push to shared branches without team agreement
- Use pull requests for code review and discussion
- Keep commit history clean and meaningful
- Document major changes in commit messages or pull request descriptions

**Rationale:** Git operations can permanently destroy uncommitted work, staged changes, and recent commits. User oversight and explicit consent are essential to prevent data loss and maintain development workflow integrity.

---

*Synthesized from imported project guidelines and best practices. Review and update as needed for your project.*
