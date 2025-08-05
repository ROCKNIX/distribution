---
description: "Step 2: Comprehensive analysis and synthesis of shared knowledge and backup data."
mode: agent
version: "1.0.0"
---
# Step 2: Comprehensive Analysis and Synthesis

Perform deep analysis of both shared knowledge and backup instruction files to identify synthesis opportunities.

## Core Analysis Tasks

### 1. Audit Current Shared Knowledge
- Review all files in `shared-copilot-knowledge/instructions/`
- Identify overlaps, gaps, and modularization opportunities
- Check for outdated or project-specific content that should be generalized

### 2. Analyze Backup Sources  
- Examine instruction files in `backups/` directory from various projects
- Extract generalizable best practices and patterns
- Identify new instruction file topics that should be added to shared knowledge

### 3. Synthesis and Updates
- Create new instruction files for identified best practices
- Update existing files to incorporate backup insights
- Ensure modular organization and clear cross-references
- Remove obsolete or redundant content (with conservative approach)

### 4. Quality Assurance
- Verify all instruction files follow naming conventions (`.instructions.md`)
- Check front matter consistency (`description`, `applyTo` fields)
- Ensure cross-references use correct paths
- Validate that shared knowledge remains project-agnostic

## Analysis Sources
- **Primary**: `shared-copilot-knowledge/instructions/` (centralized knowledge base)
- **Secondary**: `backups/` (real-world project adaptations)
- **Reference**: Existing workspace instruction files for context

## Output Expectations
- Updated or new instruction files in `shared-copilot-knowledge/instructions/`
- Documentation of changes and rationale
- Preservation of existing valuable content unless clearly obsolete
- Improved modularity and cross-referencing

## Success Criteria
- Shared knowledge base is comprehensive and current
- Best practices from backup sources are incorporated
- File organization is logical and modular
- All changes are documented with clear rationale

## Next Steps
After completing this analysis:
1. Run `step_3-analyze_backups-improve_shared_knowledge.prompt.md` to further refine modular instructions
2. Run `step_4-synthesize-main-copilot-instructions.prompt.md` to create the main copilot-instructions.md file for distribution
