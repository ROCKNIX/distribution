# Scripts Directory

This directory contains automation scripts for the shared-copilot-knowledge backup and distribution system.

## Scripts Overview

### SSH Backup System

- **`ssh-backup-hook.sh`** - Pre-commit hook that automatically backs up instruction files to the shared-copilot-knowledge repository
- **`setup-ssh-backup.sh`** - Installation script for deploying the SSH backup hook to projects
- **`pre-commit-hook-template.sh`** - Template for custom pre-commit hook implementations

## Setup Instructions

### For Project Maintainers

To set up the SSH backup system in your project:

```bash
# Quick setup (requires SSH access to GitHub)
curl -s https://raw.githubusercontent.com/maxengel/shared-copilot-knowledge/main/shared-copilot-knowledge/scripts/setup-ssh-backup.sh | bash
```

### Manual Setup

1. **Copy the hook script**:
   ```bash
   curl -s -o .git/hooks/pre-commit https://raw.githubusercontent.com/maxengel/shared-copilot-knowledge/main/shared-copilot-knowledge/scripts/ssh-backup-hook.sh
   chmod +x .git/hooks/pre-commit
   ```

2. **Configure the backup repository URL** (if different):
   ```bash
   # Edit .git/hooks/pre-commit and update:
   BACKUP_REPO_URL="git@github.com:yourusername/shared-copilot-knowledge.git"
   ```

3. **Test the setup**:
   ```bash
   # Make a test commit to verify backup works
   git add .
   git commit -m "Test SSH backup hook"
   ```

## How It Works

### SSH Backup Hook (`ssh-backup-hook.sh`)

**Purpose**: Automatically backs up instruction files from project repositories to the central shared-copilot-knowledge repository.

**What gets backed up**:
- All `.instructions.md` files from `.github/`
- `copilot-instructions.md` from `.github/`
- All `.instructions.md` files from `.github/instructions/`

**Backup location**: `backups/<project-name>/<branch>/<hostname>/`

**Fallback behavior**:
1. Try SSH backup to remote repository
2. Fall back to HTTPS (not yet implemented)
3. Fall back to local backup in `~/.copilot-backups/`

### Distribution System

The SSH backup works in tandem with GitHub Actions that:
1. Collect instruction files from various projects via the backup system
2. Analyze and synthesize best practices into the shared knowledge base
3. Distribute the enhanced shared knowledge back to projects via the `push-shared-copilot-knowledge.yml` workflow

## Prerequisites

- **SSH Key Setup**: SSH key must be configured for Git repository access
- **Repository Access**: Write access to the backup repository
- **Git Configuration**: Basic git user.name and user.email configuration

## Troubleshooting

### Common Issues

1. **SSH Access Failed**
   ```bash
   # Test SSH connection
   ssh -T git@github.com
   
   # If failed, set up SSH key:
   ssh-keygen -t ed25519 -C "your.email@example.com"
   # Add ~/.ssh/id_ed25519.pub to GitHub: https://github.com/settings/keys
   ```

2. **Permission Denied**
   ```bash
   # Ensure hook is executable
   chmod +x .git/hooks/pre-commit
   ```

3. **Repository Not Found**
   ```bash
   # Verify backup repository URL in hook script
   grep BACKUP_REPO_URL .git/hooks/pre-commit
   ```

## Architecture

```
Project Repository                 Shared-Copilot-Knowledge Repository
├── .github/                      ├── backups/
│   ├── *.instructions.md    →    │   └── <project>/<branch>/<hostname>/
│   ├── copilot-instructions.md   │       ├── *.instructions.md
│   └── instructions/             │       ├── copilot-instructions.md
│       └── *.instructions.md     │       └── .backup-timestamp
├── .git/hooks/                   ├── shared-copilot-knowledge/
│   └── pre-commit               │   ├── instructions/      # Synthesized best practices
└── (project files)               │   ├── scripts/          # These automation scripts
                                  │   └── prompts/          # Analysis workflows
                                  └── .github/workflows/
                                      └── push-shared-copilot-knowledge.yml
```

## Security Notes

- Instructions files are automatically excluded from git tracking (via `.git/info/exclude`)
- SSH keys provide secure authentication for backup operations
- Local fallback ensures no instruction loss even if remote backup fails
- Pre-commit hooks never block commits (always exit 0)

---

*Last updated: August 5, 2025*
