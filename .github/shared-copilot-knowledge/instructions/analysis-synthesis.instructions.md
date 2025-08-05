## Agent Guidance

As an agent, do not wait for user approval to proceed with analysis, synthesis, or file updates. Proactively identify which files should be updated or created, make the changes directly, and document your actions and rationale in the relevant instruction or prompt files as part of the process.

**SSH Backup System Integration (August 5, 2025):**
**Current Workflow**: Instruction files are automatically backed up via SSH pre-commit hooks to `backups/<project>/<branch>/<hostname>/` directories.
**Analysis Sources**: Both `shared-copilot-knowledge/instructions/` (centralized knowledge) and `backups/` (real-world project adaptations) should be analyzed for synthesis.
**Workflow Integration**: The `/step_1-sync-shared-copilot-knowledge` and `/step_2-analyze-shared-copilot-knowledge` prompts now incorporate backup data analysis alongside shared knowledge review.

**Root Cause Analysis (August 4, 2025):**
**Issue**: Files were initially created in `tmp/shared-copilot-knowledge/instructions/` instead of the correct `shared-copilot-knowledge/instructions/` directory.
**Resolution**: Updated prompts to use correct directory paths and integrated SSH backup system for comprehensive analysis.
**Lesson**: Prompt instructions must specify exact target directories and leverage all available knowledge sources.

## Synthesis Actions Completed (August 4, 2025)

**Phase 1 Analysis Completed (August 5, 2025):**

**Analysis Scope:**
- Analyzed 152 instruction files from `backups/` directory across multiple projects (SpringOS, RockNiX, copilot-instructions master)
- Examined copilot-instructions.md files, project-specific guidelines, and modular instruction files
- Focused on identifying generalizable best practices applicable across projects

**Key Findings Synthesized:**
- **Container-first development practices**: Comprehensive workflows from SpringOS including environment management, lifecycle patterns, and safety requirements
- **Enhanced Python/testing standards**: Platform-specific considerations (macOS vs Linux), hybrid testing approaches (pytest/unittest), environment variable management
- **MCP server development**: Authentication patterns, configuration best practices, troubleshooting guidance
- **Work logging and project tracking**: Timestamp management, structured logging patterns, historical context maintenance
- **Utility organization**: Single source of truth principles, purpose-based categorization, anti-duplication strategies

**Files Updated (.github/instructions/):**
- `programming-standards.instructions.md` - Enhanced with container environment management, platform-specific Python considerations
- `testing-standards.instructions.md` - Added hybrid testing approaches, environment-specific setup, mock usage standards
- `project-structure.instructions.md` - Enhanced with utility organization principles and tool categorization
- `copilot-instructions.md` - Updated foundational best practices with references to new instruction files

**New Files Created (.github/instructions/):**
- `container-development.instructions.md` - Container-first development patterns, lifecycle management, safety requirements
- `mcp-development.instructions.md` - Model Context Protocol server development and usage best practices
- `work-logging.instructions.md` - Work logging, timestamp management, and project tracking standards

**Shared Knowledge Updated:**
- `foundational-best-practices.instructions.md` - Added container development, work logging, and MCP integration practices

**Actions Completed:**
- Synthesized 152+ imported instruction files into actionable, modular best practices
- Enhanced existing instruction files with new patterns and practices
- Created new instruction files for emerging development patterns (containers, MCP, work logging)
- Updated cross-references and foundational best practices summary
- Maintained conservative approach to deletions - preserved valuable content and documented rationale

**Phase 3 Analysis Completed (August 5, 2025):**

**Analysis Scope:**
- Updated shared-copilot-knowledge instruction files with all synthesized findings from Phases 1 and 2
- Applied enhanced best practices from 152+ imported instruction files across multiple projects
- Maintained conservative approach to preserve valuable content while enhancing with new patterns

**Key Updates to Shared Knowledge:**
- **Enhanced existing files**: testing-standards, documentation-standards, programming-standards, project-structure, setup-script-standards, foundational-best-practices
- **Transformed docker-usage**: Replaced basic Docker guidance with comprehensive container-first development practices
- **Created new files**: mcp-development, work-logging instruction files for emerging development patterns

**Files Enhanced (shared-copilot-knowledge/instructions/):**
- `testing-standards.instructions.md` - Added platform-specific testing setup, environmental considerations, mock usage standards
- `docker-usage.instructions.md` - Completely updated with container-first development patterns, lifecycle management, safety requirements
- `documentation-standards.instructions.md` - Enhanced with preservation principles, multi-pass review processes, path reference standards
- `programming-standards.instructions.md` - Added container environment management, platform-specific considerations, canonical logging standards
- `project-structure.instructions.md` - Enhanced with utility organization principles, anti-duplication strategies, tool categorization
- `setup-script-standards.instructions.md` - Added canonical logging and verbosity standards, safety rationale
- `foundational-best-practices.instructions.md` - Updated with automation workflows reference

**New Files Created (shared-copilot-knowledge/instructions/):**
- `mcp-development.instructions.md` - Model Context Protocol server development, authentication patterns, troubleshooting guidance
- `work-logging.instructions.md` - Work logging patterns, timestamp management, project tracking standards

**Actions Completed:**
- Synthesized all findings from Phases 1-3 into comprehensive, modular instruction files
- Enhanced existing shared knowledge files with sophisticated patterns from real-world implementations
- Created new instruction files for emerging development patterns (MCP, work logging)
- Updated foundational best practices summary with comprehensive guidance
- Maintained strict preservation principles - no valuable content removed without clear justification
- Documented complete workflow and rationale for future reference

**Synthesis Workflow Complete:**
All three phases of the analyze-backups workflow have been completed successfully. The shared-copilot-knowledge instruction files now contain comprehensive, generalized best practices synthesized from extensive real-world project implementations across SpringOS, RockNiX, and other sources.

**Next Steps:**
- Continue to `/step_3-analyze_backups-improve_shared_knowledge` for shared knowledge synthesis

**Phase 2 Analysis Completed (August 5, 2025):**

**Analysis Focus:**
- Re-examined imported instruction files for patterns not apparent in Phase 1
- Focused on documentation preservation, logging standards, and automation workflows
- Analyzed SpringOS documentation.instructions.md, precommit.instructions.md, setup_scripts.instructions.md
- Examined RockNiX instructions-backup-setup.instructions.md for backup automation patterns

**Key New Findings:**
- **Documentation preservation principles**: Multi-pass review processes, content justification requirements, mandatory restoration of key sections
- **Canonical logging standards**: VERBOSITY/DEBUG flag patterns for Bash scripts with independent control of log file detail and terminal output
- **Backup automation patterns**: Pre-commit hook templates for instruction file backup, privacy management with .git/info/exclude
- **Path reference standards**: Absolute path requirements, link integrity maintenance processes

**Files Enhanced (.github/instructions/):**
- `documentation-standards.instructions.md` - Added preservation principles, path reference standards, change justification requirements
- `setup-script-standards.instructions.md` - Enhanced with canonical logging and verbosity standards for Bash scripts
- `precommit.instructions.md` - Added logging standards for Bash hooks and backup automation integration patterns
- `programming-standards.instructions.md` - Enhanced Bash standards with VERBOSITY/DEBUG logging patterns
- `copilot-instructions.md` - Added reference to new automation-workflow instruction file

**New Files Created (.github/instructions/):**
- `automation-workflow.instructions.md` - Backup automation patterns, pre-commit hook architecture, workflow integration standards, documentation automation

**Actions Completed:**
- Enhanced existing instruction files with detailed logging, preservation, and automation patterns
- Created comprehensive automation workflow instruction file covering backup, pre-commit, and documentation automation
- Updated foundational best practices with automation workflow references
- Maintained conservative approach - preserved all valuable content while enhancing with new patterns

**Files Updated (Phases 1-2):**
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
