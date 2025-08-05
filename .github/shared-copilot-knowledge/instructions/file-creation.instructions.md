---
description: "Best practices for file creation and organization."
applyTo: "**"
---

# File Creation & Organization

## File Naming & Organization

- Use clear, descriptive filenames and organize files in appropriate directories.
- Instructions files should be written in Markdown, concise, relevant, and well-structured.
- Document the purpose and usage of each file at the top.
- Regularly review and update files to reflect current project requirements.
- **When moving files or directories, always clean up leftovers (e.g., empty folders) to maintain a tidy workspace.**

## Development Philosophy

- **"Measure Twice, Cut Once"**: Work methodically through planned steps, don't rush or conflate multiple tasks.
- Always ensure fixes are targeted - identify and isolate the root cause before implementing solutions.
- Verify current state before making changes - never assume the current state, always check first.
- Test after each change - validate that changes work as expected before proceeding.

## Safety Requirements

- **NEVER run setup scripts, installers, or any system-modifying commands automatically.**
- Always require explicit user confirmation before suggesting any script that could modify the system.
- Use only safe analysis methods: static code analysis, file checks, log examination.

## Backup & Privacy (Optional)

- Add new instruction files to `.git/info/exclude` to keep them private and untracked.

## Cross-References

- Reference related documentation or instructions for context and onboarding.
