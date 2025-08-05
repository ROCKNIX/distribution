---
description: "Step 2: Update and improve shared knowledge instruction files based on analysis."
mode: agent
version: "1.0.0"
---
# Step 2: Update Shared Copilot Knowledge

Implement improvements to the shared knowledge base based on analysis findings from Step 1.

## Core Update Tasks

### 1. Update Current Shared Knowledge
- Modify files in `shared-copilot-knowledge/instructions/` based on Step 1 analysis
- Fill identified gaps with new instruction files
- Improve existing files for clarity and completeness
- Remove outdated or project-specific content that should be generalized

### 2. Incorporate Best Practices  
- Add new instruction files for identified best practices
- Update existing files to incorporate analysis insights
- Ensure modular organization and clear cross-references
- Apply conservative approach to content removal

### 3. Quality Improvements
- Ensure all instruction files follow naming conventions (`.instructions.md`)
- Verify front matter consistency (`description`, `applyTo` fields)
- Update cross-references to use correct paths
- Validate that shared knowledge remains project-agnostic

## Analysis Sources
- **Primary**: `shared-copilot-knowledge/instructions/` (current shared knowledge base)
- **Secondary**: Analysis findings from Step 1
- **Available Backups**: `backups/` directory (if present in this repository)
- **Reference**: Existing workspace instruction files for context

## Output Expectations
- Updated or new instruction files in `shared-copilot-knowledge/instructions/`
- Documentation of changes and rationale
- Preservation of existing valuable content unless clearly obsolete
- Improved modularity and cross-referencing

## Success Criteria
- Shared knowledge base is current and comprehensive
- Identified improvements from Step 1 analysis are implemented
- File organization is logical and modular
- All changes are documented with clear rationale

## Quality Standards
- **Actionable**: Each guideline should be specific enough to follow
- **Universal**: Avoid project-specific language or assumptions  
- **Modular**: Organize into focused, reusable instruction files
- **Cross-Referenced**: Link to related instruction files appropriately

## Completion
After completing these updates, the shared knowledge base should be improved and ready for use in distributed repositories. This completes the distributed workflow for maintaining and improving shared Copilot knowledge.
