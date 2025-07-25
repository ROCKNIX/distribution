mode: agent
# Analyze Shared Copilot Knowledge
tools:
  - file_search
  - grep_search
  - apply_patch
  - run_in_terminal
  - insert_edit_into_file
---

# Step 2: Analyze and Synthesize Shared Copilot Knowledge

> Before running this prompt, ensure you have completed `/sync-shared-copilot-knowledge` to update the shared knowledge directory.

1. **Analyze and synthesize:**
   - Review all instruction and prompt files in `shared-copilot-knowledge/instructions/` and `shared-copilot-knowledge/prompts/`.
   - Update the project’s `copilot-instructions.md` and `.github/instructions/` to reflect relevant best practices, modular instructions, and improvements.

2. **Iterate for further improvements:**
   - With the updated project instructions, take another pass through `shared-copilot-knowledge`.
   - Identify and apply any additional changes that would further improve the project’s Copilot experience.

## Checklist for Synthesis
- When reorganizing or modularizing best practices, always preserve and update any summary lists (e.g., "Foundational Best Practices") in their original section.
- After synthesizing topic-specific sections, review the original summary lists and ensure they are still present, accurate, and reflect the latest best practices.
- If a summary list is missing, restore it with the most current and relevant items.

## References

- See [Creating Copilot Instruction Files](../instructions/creating-instructions.instructions.md)
- See [File Creation & Organization](../instructions/file-creation.instructions.md)
- See [Patching and Editing](../instructions/patching.instructions.md)
- See [Creating and Using Copilot Prompt Files](../instructions/prompt-files.instructions.md)

---

This prompt ensures the project benefits from the latest shared knowledge and maintains a feedback loop for continuous improvement.
