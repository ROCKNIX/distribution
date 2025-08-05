---
description: "Phase 3: Update shared-copilot-knowledge instructions based on learnings from imported, improved project instructions, and all generalized best practices."
mode: agent
model: gpt-4o
version: "1.0.0"
---
# Phase 3: Generalize and Modularize Copilot Knowledge

## Steps

1. Gather all relevant instruction files from `backups/`, `.github/instructions/`, and other shared sources.
2. For each instruction file:
   - Read and summarize key best practices, guidelines, and recommendations.
   - Identify gaps, modular instructions, and opportunities for improvement.
   - Synthesize findings into clear, topic-focused instruction files in `shared-copilot-knowledge/instructions/`, ensuring modularity and reusability.
   - Preserve and update summary lists (e.g., "Foundational Best Practices") in their original section.
   - After modularizing, review summary lists to ensure they are present, accurate, and reflect the latest best practices. If missing, restore with the most current and relevant items.
   - Explicitly create or update files for critical topics (e.g., creating instructions, privacy/backup, collaboration, automation), caveating guidance that may not apply to all projects and clarifying when it is optional.
   - Be conservative with deletions: never remove content unless you are certain it is obsolete, fully redundant, or has been safely and clearly replaced elsewhere. When in doubt, preserve valuable or potentially relevant content, and prefer to mark it for review or move it to an archival section rather than deleting outright.
   - Proactively identify and implement changes without waiting for user approval or suggestions. If you state that you will take an action (such as updating or creating instruction files, or documenting changes), you must immediately and proactively perform that action as part of your workflow—never simply state intent or delay. Always proceed to the next step as soon as you are ready, without waiting for user input or approval.
   - Document the rationale for any removal or major change, and encourage peer review for significant deletions. Always document your actions and rationale in the relevant instruction or prompt files as part of the process.
   - Reference: See `analysis-synthesis.instructions.md` and `copilot-instructions.md` for modularization, synthesis, and deletion guidance.
3. Regularly review and update synthesized instruction files as workflows and best practices evolve.

## Completion
You have finished modularizing and improving the shared knowledge instruction files. 

**Next Step**: Run `step_4-synthesize-main-copilot-instructions.prompt.md` to create the comprehensive main copilot-instructions.md file that will be distributed to all target repositories.
