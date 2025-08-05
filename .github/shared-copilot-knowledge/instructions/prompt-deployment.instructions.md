---
description: "Safe deployment strategy for versioned prompt files across projects."
applyTo: "**/*.prompt.md"
---

# Prompt Deployment Strategy

## Version Management
All prompt files include version numbers in their frontmatter:
```yaml
---
description: "Prompt description"
mode: agent
version: "1.0.0"
---
```

## Safe Deployment Process

### Automated Deployment (via GitHub Actions)
1. **Central Updates**: Changes to `shared-copilot-knowledge/prompts/` trigger deployment
2. **Staging Area**: Files are copied to `.github/shared-copilot-knowledge/prompts/` in target projects
3. **Version Comparison**: A script `compare-prompt-versions.sh` is created to compare versions
4. **Manual Review**: Project maintainers review changes before deploying to `.github/prompts/`

### Manual Deployment Steps
1. **Run comparison**: `./compare-prompt-versions.sh`
2. **Review changes**: `diff .github/prompts/[filename] .github/shared-copilot-knowledge/prompts/[filename]`
3. **Deploy selectively**: `cp .github/shared-copilot-knowledge/prompts/[specific-file] .github/prompts/`
4. **Or deploy all**: `cp .github/shared-copilot-knowledge/prompts/*.prompt.md .github/prompts/`

## Safety Features
- **No automatic overwrite** of existing `.github/prompts/` files
- **Version tracking** for change management
- **Diff tools** for detailed comparison
- **Staged deployment** with review process
- **Selective deployment** option for specific files

## Rationale
This approach prevents accidental overwrites of project-specific prompt modifications while still providing centralized updates and clear version tracking. Projects maintain control over when and which prompt updates to adopt.

---

*Implemented August 5, 2025 - Version 1.0.0*
