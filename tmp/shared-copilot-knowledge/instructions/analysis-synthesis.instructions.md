## Agent Guidance

As an agent, do not wait for user approval to proceed with analysis, synthesis, or file updates. Proactively identify which files should be updated or created, make the changes directly, and document your actions and rationale in the relevant instruction or prompt files as part of the process.

**Root Cause Analysis (August 4, 2025):**
**Issue**: Files were initially created in `tmp/shared-copilot-knowledge/instructions/` instead of the correct `shared-copilot-knowledge/instructions/` directory.
**Cause**: The Phase 3 prompt (`analyze-imported-improve-shared-copilot-knowledge.prompt.md`) explicitly instructed to synthesize files into `tmp/shared-copilot-knowledge/instructions/` (line 13).
**Resolution**: Updated the prompt to direct synthesis to the correct `shared-copilot-knowledge/instructions/` directory. This ensures future automation will work correctly.
**Lesson**: Prompt instructions must specify the exact correct target directories for automation to work properly.

## Synthesis Actions Completed (August 4, 2025)

**Phase 1 Analysis Summary:**
- Analyzed all imported instruction files from `rocknix/` and `springos/` projects
- Identified key best practices: backup/privacy automation, methodical development philosophy, architecture patterns, safety protocols, documentation standards
- Synthesized findings into updated project instruction files and new modular files

**Phase 2 Analysis Summary:**
- Re-examined imported files for additional insights after Phase 1 updates
- Identified new best practices: testing standards, setup script development, git safety protocols, project structure standards
- Enhanced "Foundational Best Practices" summary with comprehensive guidance from both phases

**Phase 3 Analysis Summary:**
- Updated shared-copilot-knowledge instruction files with all synthesized best practices from Phases 1 and 2
- Enhanced existing files: creating-instructions, file-creation, patching, foundational-best-practices
- Created new files: architecture-philosophy, documentation-standards, programming-standards, git-safety, testing-standards, setup-script-standards, project-structure

**Files Updated (Phases 1-2):**
- `.github/instructions/creating-instructions.instructions.md` - Enhanced with file organization, backup procedures
- `.github/instructions/file-creation.instructions.md` - Added development philosophy, safety requirements
- `.github/instructions/patching.instructions.md` - Added development philosophy, editing standards
- `.github/copilot-instructions.md` - Updated "Foundational Best Practices" summary with latest synthesized guidance

**Files Updated (Phase 3):**
- `shared-copilot-knowledge/instructions/creating-instructions.instructions.md` - Enhanced with file organization and backup procedures
- `shared-copilot-knowledge/instructions/file-creation.instructions.md` - Added development philosophy and safety requirements
- `shared-copilot-knowledge/instructions/patching.instructions.md` - Added development philosophy and editing standards
- `shared-copilot-knowledge/instructions/foundational-best-practices.instructions.md` - Updated with comprehensive best practices from all phases

**New Files Created (Phase 3):**
- `shared-copilot-knowledge/instructions/architecture-philosophy.instructions.md` - Core architectural principles, methodical development, safety requirements
- `shared-copilot-knowledge/instructions/documentation-standards.instructions.md` - Path reference standards, preservation principles
- `shared-copilot-knowledge/instructions/programming-standards.instructions.md` - Python/Bash best practices, code quality standards
- `shared-copilot-knowledge/instructions/git-safety.instructions.md` - Git safety protocols, destructive operation prevention
- `shared-copilot-knowledge/instructions/testing-standards.instructions.md` - Testing methodologies, coverage requirements, documentation standards
- `shared-copilot-knowledge/instructions/setup-script-standards.instructions.md` - User experience standards, safety protocols, OS detection patterns
- `shared-copilot-knowledge/instructions/project-structure.instructions.md` - Repository organization, file naming conventions

**Rationale:** Phase 3 completed the synthesis workflow by updating the shared-copilot-knowledge instruction files with all the enhanced best practices identified in Phases 1 and 2. This ensures the shared knowledge base reflects the most comprehensive and up-to-date best practices for maximum utility and adaptability across all future projects.

## Agent Guidance

---
description: "Best practices for performing analysis and synthesis of instruction files."
applyTo: "**"
---

# Analysis and Synthesis of Instruction Files

- Always begin by gathering all relevant instruction files from both project-specific and backups/shared sources.
- Perform a thorough analysis to identify best practices, gaps, modular instructions, and opportunities for improvement.
- Synthesize findings into clear, topic-focused instruction files, ensuring modularity and reusability.
- When performing synthesis after analysis:
  - Updates should be made to existing instruction files when helpful for clarity, modularity, or project alignment.
  - New instruction files should be created when beneficial to the goals of this specific project, such as introducing new best practices, workflows, or modular topics.
  - Always document the rationale for creating new files or updating existing ones, and ensure changes are conservative and well-reviewed.
- Preserve and update summary lists (e.g., "Foundational Best Practices") in their original section.
- After modularizing, review summary lists to ensure they are present, accurate, and reflect the latest best practices.
- If a summary list is missing, restore it with the most current and relevant items.
- Explicitly create or update files for critical topics (e.g., creating instructions, privacy/backup, collaboration, automation).
- Caveat guidance that may not apply to all projects (e.g., privacy/backup) and clarify when it is optional.
- Document changes and rationale for future contributors.
- Regularly review and update synthesized instruction files as workflows and best practices evolve.

## Agent Guidance

When analyzing and synthesizing instruction files, proactively identify which files should be updated and where new files should be created. Do not ask the user where to make changes—determine the appropriate targets as part of your analysis and synthesis process.
