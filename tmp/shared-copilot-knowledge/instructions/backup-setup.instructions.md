---
description: "SSH-based backup setup for Copilot instruction files with remote Git repository."
applyTo: "**/backup*setup*, **/pre-commit**"
---

# SSH-Based Backup Setup Instructions

## Overview

This guide provides instructions for setting up automated backup of Copilot instruction files using SSH to push directly to a remote Git repository. This eliminates local path dependencies and enables automatic synchronization across machines.

## Advantages Over Local System

✅ **Remote Storage**: Files backed up to GitHub/GitLab, accessible anywhere
✅ **Version Control**: Full git history for instruction file evolution  
✅ **Multi-contributor**: Each contributor's files tracked separately
✅ **Branch Awareness**: Separate backup branches per project/branch/hostname
✅ **Zero Configuration**: Works with existing SSH keys
✅ **Automatic Fallback**: Falls back to local backup if remote fails

## Prerequisites

1. **SSH Key Setup**: Ensure SSH key is configured for Git repository access
2. **Backup Repository**: Create a private repository for instruction backups
3. **Git Access**: Verify you can clone/push to the backup repository

## Setup Process

### 1. Test SSH Access

Verify SSH access to your backup repository:

```bash
# Test SSH connection
ssh -T git@github.com

# Test repository access
git clone git@github.com:yourusername/copilot-instructions.git /tmp/test-backup
rm -rf /tmp/test-backup
```

### 2. Configure Pre-commit Hook

In your project repository, create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# SSH-Based Copilot Instructions Backup Hook
set -e

# Configuration - UPDATE THESE VALUES
BACKUP_REPO_URL="git@github.com:yourusername/copilot-instructions.git"

# Repository context
REPO_NAME="$(basename "$(git rev-parse --show-toplevel)")"
BRANCH_NAME="$(git rev-parse --abbrev-ref HEAD)"
HOSTNAME="$(hostname)"
BACKUP_BRANCH="auto-backup/${REPO_NAME}/${BRANCH_NAME}/${HOSTNAME}"

# Source directory for instruction files
SRC_DIR="$(git rev-parse --show-toplevel)/.github"

# Function to perform backup
backup_instructions() {
    local temp_dir=$(mktemp -d)
    trap 'rm -rf "$temp_dir"' EXIT
    
    echo "[pre-commit] Backing up instruction files..."
    
    # Clone backup repository
    cd "$temp_dir"
    if git clone --depth 1 "$BACKUP_REPO_URL" backup-repo 2>/dev/null; then
        cd backup-repo
        
        # Configure git
        git config user.email "copilot-backup@$(hostname)"
        git config user.name "Copilot Backup Bot"
        
        # Create/checkout backup branch
        git fetch origin "$BACKUP_BRANCH" 2>/dev/null || true
        git checkout -b "$BACKUP_BRANCH" 2>/dev/null || git checkout "$BACKUP_BRANCH"
        
        # Create target directory
        local target_dir="backups/${REPO_NAME}/${BRANCH_NAME}/${HOSTNAME}"
        mkdir -p "$target_dir"
        
        # Copy instruction files
        cp "$SRC_DIR"/*.instructions.md "$target_dir"/ 2>/dev/null || true
        cp "$SRC_DIR"/copilot-instructions.md "$target_dir"/ 2>/dev/null || true
        
        if [ -d "$SRC_DIR/instructions" ]; then
            cp "$SRC_DIR/instructions"/*.instructions.md "$target_dir"/ 2>/dev/null || true
        fi
        
        # Add timestamp
        echo "Backup created: $(date)" > "$target_dir/.backup-timestamp"
        echo "Source: ${REPO_NAME}/${BRANCH_NAME}" >> "$target_dir/.backup-timestamp"
        
        # Commit and push
        git add .
        if ! git diff --staged --quiet; then
            git commit -m "Auto-backup: ${REPO_NAME}/${BRANCH_NAME} from ${HOSTNAME} at $(date)"
            git push origin "$BACKUP_BRANCH"
            echo "[pre-commit] ✓ Instructions backed up successfully"
        else
            echo "[pre-commit] No changes to backup"
        fi
    else
        echo "[pre-commit] ✗ Backup failed - check SSH access"
        return 1
    fi
}

# Perform backup (don't fail commit if backup fails)
backup_instructions || echo "[pre-commit] Backup failed, continuing with commit"
exit 0
```

### 3. Make Hook Executable

```bash
chmod +x .git/hooks/pre-commit
```

### 4. Configure Privacy

Add to `.git/info/exclude`:

```
# Copilot instructions files (kept private)
.github/copilot-instructions.md
.github/*.instructions.md
.github/instructions/*.instructions.md
.vscode/settings.json
```

## Advanced Features

### Custom Backup Script

For more advanced needs, use the provided backup script:

```bash
# Copy the advanced backup script
curl -o .git/hooks/pre-commit \
  https://raw.githubusercontent.com/yourusername/copilot-instructions/main/shared-copilot-knowledge/scripts/ssh-backup-hook.sh

chmod +x .git/hooks/pre-commit
```

### Branch Management

The system creates branches like:
- `auto-backup/project-name/main/hostname`
- `auto-backup/project-name/feature-branch/hostname`

### Backup Verification

Check backup status:

```bash
# View backup branches
git ls-remote origin | grep auto-backup

# Clone backup repository to review
git clone git@github.com:yourusername/copilot-instructions.git
cd copilot-instructions
git branch -r | grep auto-backup
```

## Directory Structure

The SSH backup system creates:

```
copilot-instructions/ (remote repository)
├── backups/
│   └── <project-name>/
│       └── <branch-name>/
│           └── <hostname>/
│               ├── .backup-timestamp
│               ├── copilot-instructions.md
│               └── *.instructions.md
└── shared-copilot-knowledge/
    ├── instructions/
    ├── scripts/
    └── prompts/
```

## Troubleshooting

### SSH Connection Issues

```bash
# Test SSH connection
ssh -T git@github.com

# Check SSH key
ls -la ~/.ssh/
cat ~/.ssh/id_*.pub
```

### Repository Access Problems

```bash
# Verify repository URL
git remote -v

# Test clone access
git clone git@github.com:yourusername/copilot-instructions.git /tmp/test
```

### Permission Denied

```bash
# Make hook executable
chmod +x .git/hooks/pre-commit

# Check repository permissions
ls -la .git/hooks/
```

## Migration from Local System

To migrate from the old local path system:

1. **Install SSH-based hook** using instructions above
2. **Test backup functionality** with a test commit
3. **Remove old local backup directories** once verified
4. **Update any documentation** referencing old paths

## Security Considerations

- **Repository Privacy**: Keep backup repository private
- **SSH Key Security**: Protect SSH private keys
- **Branch Cleanup**: Periodically clean old backup branches
- **Access Control**: Limit repository access to necessary contributors

---

*Updated: August 5, 2025 - SSH-based remote backup system*
