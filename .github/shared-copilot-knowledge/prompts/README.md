# Shared Copilot Knowledge Prompts

This directory contains prompt files for analyzing and synthesizing Copilot instruction files across all projects in your development environment.

## Workflow Overview

### Step 1: Sync Shared Knowledge
**File**: `step_1-sync-shared-copilot-knowledge.prompt.md`
- Copy the latest shared knowledge to target repositories
- Prepare analysis environment

### Step 2: Analyze Shared Knowledge  
**File**: `step_2-analyze-shared-copilot-knowledge.prompt.md`
- Comprehensive analysis of current shared knowledge and backup data
- Identify synthesis opportunities and gaps
- Update modular instruction files

### Step 3: Improve Shared Knowledge
**File**: `step_3-analyze_backups-improve_shared_knowledge.prompt.md`  
- Generalize and modularize instruction files based on project backups
- Create topic-focused instruction files
- Conservative approach to content changes

### Step 4: Synthesize Main Instructions
**File**: `step_4-synthesize-main-copilot-instructions.prompt.md`
- Create comprehensive main `copilot-instructions.md` file
- Synthesize best practices from all analyzed sources
- Generate the "source of truth" for distribution to all repositories

## Usage

Run these prompts in sequence to maintain and improve the shared Copilot knowledge base:

1. **Initial Setup**: Use Step 1 to sync knowledge to target repos
2. **Regular Analysis**: Run Steps 2-4 when new backup data is available
3. **Maintenance**: Periodically run Steps 3-4 to keep instructions current

## Output Files

- **Modular Instructions**: `../instructions/*.instructions.md` 
- **Main Instructions**: `../copilot-instructions.md` (distributed to all repos)
- **Analysis Documentation**: Updates to instruction files with change rationale

## Integration

These prompts work with:
- **Backup System**: SSH hooks and GitHub Actions that collect instruction files
- **Distribution System**: GitHub Actions workflow that pushes updates to target repositories  
- **Version Control**: Tracked changes and timestamps for all updates

---

*Last updated: August 5, 2025*
