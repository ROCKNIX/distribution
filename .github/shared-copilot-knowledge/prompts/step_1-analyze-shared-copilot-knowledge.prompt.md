## Default File Listing Behavior
When working with shared copilot knowledge, use shell commands like:

    ls shared-copilot-knowledge/instructions/*.md
    find shared-copilot-knowledge/instructions -name '*.md'

to list instruction files and ensure you have the latest shared knowledge available.

---
description: "Step 1: Analyze current shared knowledge and backup sources for improvement opportunities."
mode: agent
version: "1.0.0"
---
# Step 1: Analyze Shared Copilot Knowledge

Analyze the current shared knowledge base and any available backup sources to identify improvement opportunities.

## Steps
1. **Analyze Current Shared Knowledge**: Review `shared-copilot-knowledge/instructions/` for gaps and opportunities
2. **Examine Available Backups**: Review any instruction files in `backups/` directory from other projects (if available)
3. **Check File Organization**: Ensure proper naming conventions and front matter consistency
4. **Identify Patterns**: Look for emerging best practices and missing instruction topics
5. **Prepare Analysis Summary**: Document findings for the next step

## Next Step
When complete, run `step_2-update-shared-copilot-knowledge` to implement improvements based on analysis findings.
