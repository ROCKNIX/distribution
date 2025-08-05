## Default File Listing Behavior
When working with shared copilot knowledge, use shell commands like:

    ls shared-copilot-knowledge/instructions/*.md
    find shared-copilot-knowledge/instructions -name '*.md'

to list instruction files and ensure you have the latest shared knowledge available.

---
description: "Step 1: Ensure shared-copilot-knowledge is current and backups are analyzed."
mode: agent
version: "1.0.0"
---
# Step 1: Sync and Analyze Backup Sources

Before running analysis or synthesis, ensure you have the latest shared knowledge and backup data.

## Steps
1. **Update Shared Knowledge**: Ensure `shared-copilot-knowledge/` is current with latest best practices
2. **Analyze Backup Sources**: Review instruction files in `backups/` directory from other projects
3. **Check Prompt Versions**: Compare prompt file versions between `tmp/shared-copilot-knowledge/prompts/` and `.github/prompts/`
4. **Identify New Patterns**: Look for emerging best practices from backed up project files
5. **Prepare for Synthesis**: Confirm both shared knowledge and backup data are ready for analysis

## Version Management
When shared knowledge is deployed to projects, prompt files are placed in `.github/shared-copilot-knowledge/prompts/` for safety.
- **Check for version comparison script**: `./compare-prompt-versions.sh`
- **Compare versions**: Run the script to see what prompt versions are available
- **Manual deployment**: If newer versions exist, consider copying them to `.github/prompts/` after review
- **Version tracking**: All prompt files now include version numbers in their frontmatter

## Backup Integration
- Backup files are automatically collected in `backups/<project>/<branch>/<hostname>/`
- Each backup contains: `copilot-instructions.md`, `*.instructions.md` files, and timestamps
- Use backup data to identify patterns across projects and improve shared knowledge

## Next Step
When complete, run `/step_2-analyze-shared-copilot-knowledge` to begin comprehensive analysis and synthesis.
