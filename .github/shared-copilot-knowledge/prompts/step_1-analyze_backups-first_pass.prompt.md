---
description: "Phase 1: Analyze imported instruction files and update project instructions."
mode: agent
model: gpt-4
version: "1.0.0"
---
# Phase 1: Analyze and Synthesize Imported Instructions

## Steps

1. Gather all relevant instruction files from `backups/`.
2. For each instruction file:
   - Read and summarize key best practices, guidelines, and recommendations.
   - Identify gaps, modular instructions, and opportunities for improvement.
   - Synthesize findings into clear, topic-focused instruction files, ensuring modularity and reusability.
   - Preserve and update summary lists (e.g., "Foundational Best Practices") in their original section.
   - After modularizing, review summary lists to ensure they are present, accurate, and reflect the latest best practices. If missing, restore with the most current and relevant items.
   - Explicitly create or update files for critical topics (e.g., creating instructions, privacy/backup, collaboration, automation), caveating guidance that may not apply to all projects and clarifying when it is optional.
   - Be conservative with deletions: never remove content unless you are certain it is obsolete, fully redundant, or has been safely and clearly replaced elsewhere. When in doubt, preserve valuable or potentially relevant content, and prefer to mark it for review or move it to an archival section rather than deleting outright.
   - Proactively identify and implement changes without waiting for user approval or suggestions. If you state that you will take an action (such as updating or creating instruction files, or documenting changes), you must actually perform that action as part of your workflow.
   - Document the rationale for any removal or major change, and encourage peer review for significant deletions. Always document your actions and rationale in the relevant instruction or prompt files as part of the process.
   - Reference: See `analysis-synthesis.instructions.md` and `copilot-instructions.md` for modularization, synthesis, and deletion guidance.
3. Update `.github/copilot-instructions.md` and `.github/instructions/` with relevant findings and improvements.
4. Regularly review and update synthesized instruction files as workflows and best practices evolve.

## Checklist for Synthesis
- Preserve and update any summary lists (e.g., “Foundational Best Practices”) in their original section.
- After synthesizing topic-specific sections, review the original summary lists and ensure they are still present, accurate, and reflect the latest best practices.
- If a summary list is missing, restore it with the most current and relevant items.

## Next Step
When complete, run `/step_2-analyze_backups-improvement_pass` to continue to the second pass.
