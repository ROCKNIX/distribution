---
description: "Commit message standards and Git workflow best practices."
applyTo: "**"
---

# Commit Standards

## Commit Message Format

Use the conventional commit format for clear, structured commit messages:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Commit Types

- **feat**: A new feature for the user
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
- **refactor**: A code change that neither fixes a bug nor adds a feature
- **perf**: A code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **build**: Changes that affect the build system or external dependencies
- **ci**: Changes to CI configuration files and scripts
- **chore**: Other changes that don't modify src or test files
- **revert**: Reverts a previous commit

### Examples

```
feat(auth): add OAuth2 login integration
fix(api): resolve timeout issue in user endpoints
docs: update installation guide for Docker setup
refactor(utils): simplify timestamp formatting logic
test(auth): add comprehensive login flow tests
```

## Commit Message Guidelines

### Description Rules
- Use the imperative mood: "add feature" not "added feature"
- Keep the first line under 50 characters
- Don't end with a period
- Capitalize the first letter
- Be descriptive but concise

### Body Guidelines
- Wrap at 72 characters
- Explain what and why, not how
- Use bullet points for multiple changes
- Reference issues and pull requests when relevant

### Footer Guidelines
- Include breaking change notices: `BREAKING CHANGE: <description>`
- Reference issues: `Closes #123` or `Fixes #456`
- Co-authored commits: `Co-authored-by: Name <email@example.com>`

## Git Workflow Best Practices

### Branch Management
- Create feature branches from `main`: `git checkout -b feature/new-login`
- Use descriptive branch names: `feature/oauth-integration`, `fix/timeout-bug`
- Keep branches focused on single features or fixes
- Delete merged branches to keep repository clean

### Before Committing
- Review changes: `git diff --staged`
- Test your changes locally
- Ensure code follows project standards
- Update documentation if needed
- Add or update tests for new functionality

### Commit Frequency
- Make atomic commits (one logical change per commit)
- Commit early and often during development
- Squash related commits before merging if needed
- Avoid "WIP" or "fix typo" commits in main branch

### Safety Protocols
- Never force push to shared branches without team agreement
- Use `git stash` to temporarily save uncommitted work
- Create backup branches before major operations: `git branch backup-$(date +%Y%m%d)`
- Prefer `git revert` over `git reset` for shared history

## Pre-commit Checklist

Before making any commit:
- [ ] Changes are tested and working
- [ ] Code follows project style guidelines
- [ ] Documentation is updated if needed
- [ ] Tests pass (run test suite)
- [ ] Commit message follows conventional format
- [ ] No sensitive information (keys, passwords) included
- [ ] Files are properly staged (`git add`)

## Integration with Tools

### Pre-commit Hooks
Consider setting up pre-commit hooks to automatically:
- Run linters and formatters
- Execute test suites
- Validate commit message format
- Check for security issues

### Commit Message Templates
Create a commit message template in `.gitmessage`:
```
# <type>[optional scope]: <description>
# 
# [optional body]
# 
# [optional footer(s)]
```

Set as default: `git config commit.template .gitmessage`

## Examples of Good Commits

```
feat(dashboard): add real-time notifications panel

- Implement WebSocket connection for live updates
- Add notification badge with unread count
- Include sound and visual alerts for urgent messages
- Add user preferences for notification types

Closes #142
```

```
fix(auth): resolve session timeout during long operations

The session was expiring during file uploads and bulk operations
that took longer than 30 minutes. Extended session timeout to
2 hours and added automatic session refresh.

Fixes #89
BREAKING CHANGE: Session timeout increased from 30min to 2hrs
```

```
docs(setup): update Docker installation instructions

- Add macOS-specific Docker Desktop setup steps
- Include troubleshooting section for common issues
- Update environment variable examples
- Add links to official Docker documentation
```

## Related Files

- `.gitmessage`: Commit message template
- `.github/PULL_REQUEST_TEMPLATE.md`: PR template with commit standards
- Pre-commit hook configurations
- CI/CD workflow files for automated checks

---

*Part of the shared Copilot instruction system. Follow these standards for all commits across the project.*
