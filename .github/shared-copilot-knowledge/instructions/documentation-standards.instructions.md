---
description: "Documentation standards and path reference best practices."
applyTo: "**/*.md"
---

# Documentation Standards

## Preservation Principle and Safe Editing Guidelines

### Preservation Principle
All edits to documentation, onboarding, troubleshooting, and reference sections must preserve existing content unless there is a clear, documented reason for removal (e.g., obsolete, duplicated, or migrated content). The default action is to retain, not remove, unless justified.

### Multi-Pass Review for Deletions
Before deleting any section or content:
1. **Identify and summarize** what is being considered for removal
2. **Check for references**: Determine if the content is referenced elsewhere, is part of onboarding, troubleshooting, or is a required section
3. **Justify**: Only proceed with deletion if it is confirmed to be safe and justified. Document the reason for removal in the commit message or PR description

### Mandate Restoration of Key Sections
Critical sections that must always be present in onboarding and quickstart guides include:
- "Institutional Knowledge Sources"
- "Getting Help" 
- "Standards Compliance Checklist"
- Any other onboarding, troubleshooting, or reference section required by project standards

If any of these are missing, restore them promptly using version control or canonical instructions.

### Change Justification Requirement
Any removal of content must be accompanied by a clear justification in the commit message or PR description, referencing the reason for deletion (e.g., obsolete, duplicated, migrated, or truly unnecessary).

## Path Reference Standards

All documentation and code references must use absolute paths from the repository root, without a leading slash (e.g., `docs/guide.md`, not `/docs/guide.md` or `./docs/guide.md`). This standard applies to all Markdown links, code comments, configuration files, and Copilot context arrays.

**Examples of correct path usage:**
- ✅ Use: `docs/guide.md`
- ✅ Use: `.github/instructions/documentation.instructions.md`
- ❌ Avoid: `/docs/guide.md`, `./docs/guide.md`, or bare filenames

Whenever you add, remove, or rename files or documentation, you must:
- Update all affected references throughout the codebase and documentation to prevent broken links
- Run link checker scripts before submitting changes where available
- Update Copilot context arrays and documentation lists to reflect the change

## Documentation Quality Standards

- Document the purpose and usage of each file at the top.
- Use clear section headers to help readers quickly find relevant guidance.
- Include timestamp footers where appropriate (e.g., "Last updated: Month DD, YYYY").
- Regularly review and update documentation to reflect current project requirements.

---

*Synthesized from imported project guidelines and best practices. Review and update as needed for your project.*
