## Default File Listing Behavior
When working in `tmp/shared-copilot-knowledge/instructions/`, use shell commands like:

    ls tmp/shared-copilot-knowledge/instructions/*.md
    find tmp/shared-copilot-knowledge/instructions -name '*.md'

to list instruction files, since `tmp/` is likely in `.gitignore` and may not be visible to git or glob-based tools.
---
description: "Step 1: Ensure shared-copilot-knowledge is present and up-to-date in the current project."
mode: agent
---
# Step 1: Sync Shared Copilot Knowledge

Before running any analysis or synthesis, ensure the `shared-copilot-knowledge` directory is present and up-to-date in your project.

## Steps
1. If missing, copy the latest version from the central source (e.g., via script, manual copy, or GitHub Action).
2. If outdated, update it to the latest version.
3. Confirm the sync is complete before proceeding to analysis.

## Next Step
When complete, run `/analyze-shared-copilot-knowledge` to begin analysis and synthesis.
