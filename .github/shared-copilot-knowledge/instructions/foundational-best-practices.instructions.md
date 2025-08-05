---
description: "General Copilot best practices for all projects."
applyTo: "**"
---

# Foundational Best Practices

- Use `.github/copilot-instructions.md` for workspace-wide, general coding practices and requirements. This file is automatically included in every chat request.
- Use `.instructions.md` files for task-specific or file-specific instructions. Each should focus on a single topic, use Markdown formatting, and may include front matter (`description`, `applyTo`).
- **"Measure Twice, Cut Once"**: Work methodically through planned steps, don't rush or conflate multiple tasks.
- **Safety First**: Never run setup scripts, installers, or any system-modifying commands automatically. Always require explicit user confirmation.
- **Git Safety**: Never recommend destructive git operations without explicit user confirmation. Prefer safer alternatives like `git stash` and backup branches.
- **Targeted Fixes**: Always identify and isolate the root cause before implementing solutions. Test after each change.
- **Testing Standards**: Use hybrid testing approaches with comprehensive coverage. Tests should be environment-aware and well-documented.
- **Container-First Development**: Use containerized development environments for cross-platform compatibility where applicable.
- **Setup Script Excellence**: Provide clear progress feedback, interactive elements, error recovery, and robust OS detection in setup scripts.
- **Project Structure**: Use clear top-level directory structure with functional grouping. Follow consistent naming conventions for scripts and documentation.
- **Work Logging**: Maintain detailed work logs for project tracking and historical context when beneficial.
- **MCP Integration**: Use Model Context Protocol servers for enhanced development workflows when applicable.
- **Automation Workflows**: Implement backup automation, pre-commit hooks, and workflow integration patterns when beneficial.
- Use glob patterns in `applyTo` to control scope and visibility of instructions.
- Reference other instruction files using Markdown links for modularity and reuse.
- Avoid conflicting or ambiguous instructions across files.
- Regularly review and update instruction files to reflect current needs and best practices.
- Store workspace instruction files in `.github/instructions/`.
- Use automation (pre-commit hooks, GitHub Actions) to sync and apply shared knowledge.
- Instructions are automatically included in chat requests; avoid including sensitive information.
- Prompt files (`.prompt.md`) are for reusable, task-specific chat prompts and can reference instruction files.
- Foster open, constructive collaboration and communication among contributors.
- Treat all contributors and users with respect, empathy, and professionalism.
- Welcome diversity and maintain an inclusive environment.
- Use clear, descriptive filenames and organize files in appropriate directories.
- Instructions files should be concise, relevant, and well-structured.
- Document the purpose and usage of each file at the top.
- **When moving files or directories, always clean up leftovers (e.g., empty folders) to maintain a tidy workspace.**
- Reference related documentation, onboarding materials, and support channels (e.g., Discord, wiki) for context and collaboration.
- Ensure instructions are automatically detected and used by Copilot (e.g., via workspace settings).
- Check and respect licensing for new packages, scripts, and branding; reference `LICENSE.md` and `README.md` for details.
