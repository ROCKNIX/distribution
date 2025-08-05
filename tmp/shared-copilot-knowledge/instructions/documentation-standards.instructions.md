---
description: "Documentation standards and path reference best practices."
applyTo: "**/*.md"
---

# Documentation Standards

## Path Reference Standards

- Use absolute paths from the repository root, without a leading slash (e.g., `docs/guide.md`, not `/docs/guide.md` or `./docs/guide.md`).
- This standard applies to all Markdown links, code comments, configuration files, and Copilot context arrays.
- When adding, removing, or renaming files or documentation:
  - Update all affected references throughout the codebase and documentation to prevent broken links
  - Run link checker scripts before submitting changes
  - Update Copilot context arrays and documentation lists to reflect the change

## Preservation Principle

- All edits to documentation, onboarding, troubleshooting, and reference sections must preserve existing content unless there is a clear, documented reason for removal.
- The default action is to retain, not remove, unless justified.
- Before deleting any section or content:
  1. **Identify and summarize** what is being considered for removal
  2. **Check for references**: Determine if the content is referenced elsewhere
  3. **Justify**: Only proceed with deletion if confirmed to be safe and justified
  4. **Document**: Include rationale in commit message or PR description

## Documentation Quality Standards

- Document the purpose and usage of each file at the top.
- Use clear section headers to help readers quickly find relevant guidance.
- Include timestamp footers where appropriate (e.g., "Last updated: Month DD, YYYY").
- Regularly review and update documentation to reflect current project requirements.

---

*Synthesized from imported project guidelines and best practices. Review and update as needed for your project.*
