---
description: "Best practices for patching and editing files."
applyTo: "**"
---

# Patching and Editing

- Always use the exact lines and whitespace from the file as context before and after your change.
- Make small, targeted changes rather than large or repeated edits.
- If a patch fails, review the file for extra blank lines, indentation, or unexpected changes, and adjust the patch context accordingly.
- Use tools that automatically generate patches based on the latest file content to minimize manual errors.
- Document patches clearly and store them in the appropriate directory.
