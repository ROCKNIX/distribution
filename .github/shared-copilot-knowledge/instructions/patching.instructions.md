---
description: "Best practices for patching and editing files."
applyTo: "**"
---

# Patching and Editing

## Patch Creation Best Practices

- Always use the exact lines and whitespace from the file as context before and after your change.
- Make small, targeted changes rather than large or repeated edits.
- If a patch fails, review the file for extra blank lines, indentation, or unexpected changes, and adjust the patch context accordingly.
- Use tools that automatically generate patches based on the latest file content to minimize manual errors.
- Read the file immediately before applying a patch to ensure the context matches the current file state.

## Development Philosophy

- **"Measure Twice, Cut Once"**: Work methodically through planned steps, especially during refactoring or standardization.
- Always ensure fixes are targeted - identify and isolate the root cause before implementing solutions.
- Confirm fixes actually solve the problem - test that the specific issue is resolved.
- Establish measurable success criteria - always ensure there's a way to know if a problem is solved.
- One step at a time - complete each phase fully before moving to the next.

## General Editing Standards

- Document patches clearly and store them in the appropriate directory.
- Document the purpose and usage of each change in commit messages and planning files.
- Regularly review and update files to reflect current project requirements.
- Avoid including sensitive information in any file.

## Backup & Privacy (Optional)

- Add all instruction files to `.git/info/exclude` to keep them private and untracked.

## Cross-References

- Reference related documentation or instructions for context and onboarding.
