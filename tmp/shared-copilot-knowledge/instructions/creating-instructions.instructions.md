---
description: "Best practices for creating Copilot instruction files."
applyTo: "**"
---

# Creating Copilot Instruction Files

## File Structure and Organization

- Use a dedicated instruction file (e.g., `.instructions.md`) for each major topic or workflow.
- Author files in Markdown, using clear headings, lists, and code blocks.
- Optionally include front matter for metadata (e.g., `description`, `applyTo`).
- Focus each file on a single topic for clarity and maintainability.
- Document the purpose and usage of each file at the top.
- Use clear section headers to help Copilot and contributors quickly find relevant guidance.

## File Types and Locations

- Place `.instructions.md` files in `.github/instructions/` for automatic detection by Copilot.
- You can create multiple instruction files for different purposes (e.g., migration, onboarding, architecture).
- For workspace instructions, set in `.vscode/settings.json` using: `"github.copilot.workspaceInstructions": "file:<path-to-instructions-file>"`
- For file-specific instructions, add a comment at the top of a file: `// copilot: <your instructions>`

## Backup and Privacy (Optional)

- Use pre-commit hooks to automate backup of instruction files to a secure location.
- Add all instruction files to `.git/info/exclude` to keep them private and untracked.
- Example pre-commit hook setup:
  ```bash
  #!/bin/bash
  SRC_DIR="$(git rev-parse --show-toplevel)/.github"
  DEST_DIR="/path/to/backup/project/$(hostname)"
  mkdir -p "$DEST_DIR"
  cp "$SRC_DIR"/*.instructions.md "$DEST_DIR" 2>/dev/null || true
  cp "$SRC_DIR"/copilot-instructions.md "$DEST_DIR" 2>/dev/null || true
  ```

## Cross-References

- Reference related documentation or instructions for context and onboarding.
- Regularly review and update instruction files to reflect evolving project needs.

For more details, see the [VS Code Copilot Customization Guide](https://code.visualstudio.com/docs/copilot/copilot-customization).
