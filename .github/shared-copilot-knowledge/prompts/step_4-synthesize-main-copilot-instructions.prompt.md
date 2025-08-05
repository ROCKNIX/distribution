---
description: "Synthesize main copilot-instructions.md from all project backup analysis and shared knowledge"
mode: agent
version: "1.0.0"
---
# Synthesize Main Copilot Instructions

Create a comprehensive `shared-copilot-knowledge/copilot-instructions.md` file by analyzing and synthesizing instruction files from all project backups and the current shared knowledge base.

## Analysis Sources

### Primary Sources
- **Project Backups**: `backups/*/` - Real-world instruction files from various projects
- **Current Shared Knowledge**: `shared-copilot-knowledge/instructions/` - Existing modular instruction files
- **Central Instructions**: `.github/copilot-instructions.md` - Current central repository instructions

### Secondary Sources
- **Workspace Instructions**: Any other `.github/*.instructions.md` files
- **Documentation**: Project documentation and setup guides

## Synthesis Process

### 1. **Inventory and Analysis**
- Scan all backup directories for copilot-instructions.md and *.instructions.md files
- Identify common patterns, best practices, and foundational principles
- Note project-specific vs. generalizable guidance
- Catalog recurring themes (safety, git practices, development philosophy, etc.)

### 2. **Best Practice Extraction**
- Extract the most frequently mentioned and valuable practices
- Prioritize safety-first approaches (git safety, script execution, etc.)
- Identify architecture principles that apply across projects
- Note development workflow patterns and standards

### 3. **Modular Organization**
- Organize content into logical sections (Safety, Development Philosophy, Architecture, etc.)
- Ensure each section is self-contained but cross-referenced
- Create clear hierarchies from foundational to specialized guidance
- Maintain project-agnostic language while being specific enough to be actionable

### 4. **Content Synthesis**
- Write clear, actionable guidance based on analyzed patterns
- Include cross-references to modular instruction files in `instructions/`
- Preserve critical safety warnings and best practices
- Document the synthesis rationale and sources

## Output Requirements

### File Structure
Create `shared-copilot-knowledge/copilot-instructions.md` with:

#### Header Section
- Clear title and purpose statement
- Distribution notice (automatically distributed, don't modify locally)
- Last updated timestamp

#### Core Sections
- **Agent Execution Guidance** - How Copilot should behave and execute tasks
- **Safety Requirements** - Critical safety protocols (git, scripts, system modifications)
- **Development Philosophy** - Core principles like "Measure Twice, Cut Once"
- **Foundational Best Practices** - Essential practices that apply to all projects
- **Architecture Principles** - Optional patterns for applicable projects
- **File Organization** - Standards for organizing code and documentation
- **Cross-References** - Links to specific instruction files and resources

#### Footer Section
- References to instruction files in `shared-copilot-knowledge/instructions/`
- Distribution system information
- Timestamp and version tracking

### Quality Standards
- **Actionable**: Each guideline should be specific enough to follow
- **Universal**: Avoid project-specific language or assumptions
- **Hierarchical**: Organize from most critical to nice-to-have
- **Cross-Referenced**: Link to relevant modular instruction files
- **Conservative**: Include proven practices, avoid experimental guidance

### Documentation Requirements
- Document which backup sources contributed to each major section
- Note any significant changes from current instructions
- Preserve attribution for best practices where possible
- Include rationale for major organizational decisions

## Success Criteria
- ✅ Comprehensive coverage of common development scenarios
- ✅ Clear safety guidelines prominently featured
- ✅ Logical organization and good cross-referencing
- ✅ Project-agnostic language that applies broadly
- ✅ Integration with existing modular instruction system
- ✅ Proper distribution metadata and versioning

## Implementation Notes
- This should be run after completing backup analysis and shared knowledge updates
- The resulting file will be distributed to all target repositories via GitHub Actions
- Local modifications in target repos will be overwritten, so this must be comprehensive
- Consider this the "source of truth" for foundational Copilot guidance across all projects
