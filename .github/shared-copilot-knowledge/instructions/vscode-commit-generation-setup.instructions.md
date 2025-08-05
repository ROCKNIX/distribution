# VS Code Settings for Commit Message Generation

Add this to your project's `.vscode/settings.json` to enable AI-powered commit message generation using the shared commit standards:

```json
{
    "github.copilot.chat.commitMessageGeneration.instructions": [
        {
            "file": ".github/shared-copilot-knowledge/instructions/commit-standards.instructions.md"
        }
    ]
}
```

## Alternative Configurations

If your project has additional project-specific commit requirements, you can combine multiple instruction files:

```json
{
    "github.copilot.chat.commitMessageGeneration.instructions": [
        {
            "file": ".github/shared-copilot-knowledge/instructions/commit-standards.instructions.md"
        },
        {
            "file": ".github/instructions/project-specific-commit-rules.instructions.md"
        }
    ]
}
```

## How It Works

When you use VS Code's "Generate Commit Message" feature (via Git panel or Command Palette), Copilot will:

1. Analyze your staged changes
2. Follow the conventional commit format from the instruction file
3. Apply the commit message guidelines and best practices
4. Generate appropriate commit type, scope, and description
5. Include relevant body text for complex changes

## Benefits

- **Consistent formatting** across all commits
- **Proper conventional commit types** (feat, fix, docs, etc.)
- **Appropriate scope detection** based on changed files
- **Quality descriptions** that explain what and why
- **Team alignment** on commit message standards

## Setup Instructions

1. Ensure the shared knowledge is synced to `.github/shared-copilot-knowledge/`
2. Add the settings configuration to `.vscode/settings.json`
3. Stage your changes in VS Code
4. Use "Generate Commit Message" feature in the Git panel
5. Review and edit the generated message as needed

---

*This configuration leverages the shared commit standards for consistent, high-quality commit messages across all projects.*
