# Shared Copilot Instructions

This file contains the foundational Copilot instructions that should be applied across all projects in your development environment.

## Agent Execution Guidance

If you state that you will take an action (such as updating or creating instruction files, or documenting changes), you must immediately and proactively perform that action as part of your workflow. Never simply state intent or delay—always complete the promised action and document it in the relevant files without waiting for further input. Always proceed to the next step as soon as you are ready, without waiting for user input or approval.

## Critical Guidance: Be Conservative with Deletions

When updating, modularizing, or synthesizing Copilot instruction files, always err on the side of caution with deletions.
Never remove content unless you are certain it is obsolete, fully redundant, or has been safely and clearly replaced elsewhere.
When in doubt, preserve valuable or potentially relevant content, and prefer to mark it for review or move it to an archival section rather than deleting outright.
Document the rationale for any removal or major change, and encourage peer review for significant deletions.

## Foundational Best Practices

- Use `.github/copilot-instructions.md` for workspace-wide, general coding practices and requirements. This file is automatically included in every chat request.
- Use `.instructions.md` files for task-specific or file-specific instructions. Each should focus on a single topic, use Markdown formatting, and may include front matter (`description`, `applyTo`).
- **"Measure Twice, Cut Once"**: Work methodically through planned steps, don't rush or conflate multiple tasks.
- **Safety First**: Never run setup scripts, installers, or any system-modifying commands automatically. Always require explicit user confirmation.
- **Git Safety**: Never recommend destructive git operations without explicit user confirmation. Prefer safer alternatives like `git stash` and backup branches.
- **Targeted Fixes**: Always identify and isolate the root cause before implementing solutions. Test after each change.
- **Testing Standards**: Use hybrid testing approaches with comprehensive coverage. Tests should be environment-aware and well-documented.
- **Container-First Development**: Use containerized development environments for cross-platform compatibility.
- **Setup Script Excellence**: Provide clear progress feedback, interactive elements, error recovery, and robust OS detection in setup scripts.
- **Project Structure**: Use clear top-level directory structure with functional grouping. Follow consistent naming conventions for scripts and documentation.
- **Work Logging**: Maintain detailed work logs for project tracking and historical context.
- **MCP Integration**: Use Model Context Protocol servers for enhanced development workflows when applicable.
- **Automation Workflows**: Implement backup automation, pre-commit hooks, and workflow integration patterns.

## Development Philosophy

- **"Measure Twice, Cut Once"**: Work methodically through planned steps, don't rush or conflate multiple tasks.
- Always ensure fixes are targeted - identify and isolate the root cause before implementing solutions.
- Verify current state before making changes - never assume the current state, always check first.
- Test after each change - validate that changes work as expected before proceeding.
- One step at a time - complete each phase fully before moving to the next.

## Safety Requirements

- **NEVER run setup scripts, installers, or any system-modifying commands automatically.**
- Always require explicit user confirmation before suggesting any script that could modify the system.
- Use only safe analysis methods: static code analysis, file checks, log examination.

## Git Safety Protocols

**NEVER recommend or execute Git head resets without explicit user confirmation and understanding of consequences:**

- **ALWAYS double-check before proposing `git reset --hard` or similar destructive Git operations**
- **Explain potential data loss clearly** before suggesting any reset operations
- **Prefer safer alternatives** like `git stash`, `git checkout`, or creating backup branches
- **Request explicit confirmation** when reset operations are truly necessary

## Architecture Principles

### Three-Tier Architecture Pattern (Optional)
For applicable projects:
- **Components Layer**: Reusable UI and infrastructure building blocks
- **Templates Layer**: Configurable patterns combining multiple components  
- **Applications Layer**: End-user functionality built from templates

### Container-First Development (Optional)
Where applicable:
- Zero-dependency bootstrap process (host requires only Docker and Bash)
- All development tools containerized
- Cross-platform compatibility (Linux, macOS, WSL)

### API-Driven Architecture (Optional)
For projects requiring API integration:
- All core functionality exposed via well-defined APIs
- Clear separation between API layer and implementation
- Consistent error handling and response formats
- Version-aware API design for backward compatibility

## File Organization

- Use clear, descriptive filenames and organize files in appropriate directories.
- Instructions files should be written in Markdown, concise, relevant, and well-structured.
- Document the purpose and usage of each file at the top.
- **When moving files or directories, always clean up leftovers (e.g., empty folders) to maintain a tidy workspace.**
- Reference related documentation or instructions for context and onboarding.

## Backup & Privacy

- Use pre-commit hooks to automate backup of instruction files to a secure location.
- Add all instruction files to `.git/info/exclude` to keep them private and untracked.
- Instructions files are automatically excluded from git tracking for privacy.

## Cross-References

For complete documentation and additional instruction files, see:
- **Instructions Directory**: `.github/shared-copilot-knowledge/instructions/` - Modular, topic-specific instruction files
- **Scripts Directory**: `.github/shared-copilot-knowledge/scripts/` - Automation and setup scripts
- **Prompts Directory**: `.github/shared-copilot-knowledge/prompts/` - Reusable task-specific prompts

---

*This file is distributed automatically via the shared-copilot-knowledge system. Local modifications will be overwritten.*
*Last updated: August 5, 2025*
