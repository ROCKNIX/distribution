#!/bin/bash
# Copilot Instructions SSH Backup Setup Script
# This script automates the deployment of SSH-based backup hooks to projects

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BACKUP_REPO_URL="git@github.com:maxengel/shared-copilot-knowledge.git"
HOOK_URL="https://raw.githubusercontent.com/maxengel/shared-copilot-knowledge/main/shared-copilot-knowledge/scripts/ssh-backup-hook.sh"

# Helper functions
print_header() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  🚀 Copilot Instructions SSH Backup Setup${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo
}

print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a Git repository! Please run this script from a project root."
        exit 1
    fi
    
    local repo_root=$(git rev-parse --show-toplevel)
    local repo_name=$(basename "$repo_root")
    print_success "Found Git repository: $repo_name"
    return 0
}

# Check for instruction files
check_instruction_files() {
    local github_dir="$(git rev-parse --show-toplevel)/.github"
    local repo_root="$(git rev-parse --show-toplevel)"
    local has_files=false
    
    print_step "Checking for instruction files..."
    
    if [ -f "$github_dir"/*.instructions.md ] 2>/dev/null; then
        print_success "Found .instructions.md files in .github/"
        has_files=true
    fi
    
    if [ -f "$github_dir/copilot-instructions.md" ]; then
        print_success "Found copilot-instructions.md in .github/"
        has_files=true
    fi
    
    if [ -d "$github_dir/instructions" ] && [ -f "$github_dir/instructions"/*.instructions.md ] 2>/dev/null; then
        print_success "Found instruction files in .github/instructions/"
        has_files=true
    fi
    
    if [ "$has_files" = false ]; then
        print_warning "No instruction files found. Hook will be installed but won't backup anything yet."
        echo "  Create instruction files in:"
        echo "  - .github/*.instructions.md"
        echo "  - .github/copilot-instructions.md"
        echo "  - .github/instructions/*.instructions.md"
    fi
}

# Test SSH access to GitHub
test_ssh_access() {
    print_step "Testing SSH access to GitHub..."
    
    if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
        print_success "SSH access to GitHub verified"
        return 0
    else
        print_error "SSH access to GitHub failed!"
        echo
        echo "To fix this:"
        echo "1. Generate SSH key: ssh-keygen -t ed25519 -C \"your.email@example.com\""
        echo "2. Add to GitHub: cat ~/.ssh/id_ed25519.pub"
        echo "3. Go to: https://github.com/settings/keys"
        echo "4. Test: ssh -T git@github.com"
        exit 1
    fi
}

# Install the pre-commit hook
install_hook() {
    local hook_path=".git/hooks/pre-commit"
    
    print_step "Installing SSH backup hook..."
    
    # Backup existing hook if it exists
    if [ -f "$hook_path" ]; then
        print_warning "Existing pre-commit hook found, backing up..."
        mv "$hook_path" "${hook_path}.backup.$(date +%Y%m%d-%H%M%S)"
    fi
    
    # Download the hook
    if curl -s -o "$hook_path" "$HOOK_URL"; then
        chmod +x "$hook_path"
        print_success "Hook downloaded and made executable"
    else
        print_error "Failed to download hook from $HOOK_URL"
        exit 1
    fi
    
    # Update repository URL in hook
    if command -v sed >/dev/null 2>&1; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            sed -i '' "s|git@github.com:yourusername/copilot-instructions.git|$BACKUP_REPO_URL|g" "$hook_path"
        else
            # Linux
            sed -i "s|git@github.com:yourusername/copilot-instructions.git|$BACKUP_REPO_URL|g" "$hook_path"
        fi
        print_success "Hook configured with backup repository URL"
    else
        print_warning "Please manually update the BACKUP_REPO_URL in $hook_path"
    fi
}

# Test the hook
test_hook() {
    print_step "Testing the backup hook..."
    
    if [ -x ".git/hooks/pre-commit" ]; then
        print_success "Hook is executable and ready"
        echo
        print_step "Testing hook execution (dry run)..."
        echo "Note: This will attempt to backup instruction files"
        
        # Create a test commit to trigger the hook
        if git status --porcelain | grep -q "^"; then
            print_warning "Repository has uncommitted changes. Hook will be tested on next commit."
        else
            # Create a minimal change to test
            echo "# Hook test: $(date)" >> .git/hook-test-temp
            git add .git/hook-test-temp
            
            if git commit -m "Test SSH backup hook installation" 2>&1; then
                print_success "Hook executed successfully during commit!"
                # Clean up test file
                rm -f .git/hook-test-temp
            else
                print_warning "Hook execution had issues, but commit completed"
            fi
        fi
    else
        print_error "Hook is not executable"
        exit 1
    fi
}

# Setup privacy configuration
setup_privacy() {
    print_step "Setting up privacy configuration..."
    
    local exclude_file=".git/info/exclude"
    
    # Create .git/info directory if it doesn't exist
    mkdir -p .git/info
    
    # Add instruction files to exclude if not already present
    local exclude_patterns=(
        "# Copilot instructions files"
        ".github/copilot-instructions.md"
        ".github/*.instructions.md"
        ".github/instructions/*.instructions.md"
        "# VS Code settings"
        ".vscode/settings.json"
    )
    
    local added_patterns=false
    for pattern in "${exclude_patterns[@]}"; do
        if ! grep -Fxq "$pattern" "$exclude_file" 2>/dev/null; then
            echo "$pattern" >> "$exclude_file"
            added_patterns=true
        fi
    done
    
    if [ "$added_patterns" = true ]; then
        print_success "Privacy patterns added to .git/info/exclude"
    else
        print_success "Privacy configuration already present"
    fi
}

# Main execution
main() {
    print_header
    
    # Pre-flight checks
    check_git_repo
    check_instruction_files
    test_ssh_access
    
    echo
    print_step "Proceeding with installation..."
    echo
    
    # Installation steps
    install_hook
    setup_privacy
    test_hook
    
    echo
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  🎉 Installation Complete!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════════${NC}"
    echo
    echo "Your project is now configured for SSH-based instruction file backup."
    echo
    echo "What happens next:"
    echo "• Every commit will automatically backup instruction files"
    echo "• Files are backed up to: $BACKUP_REPO_URL"
    echo "• Backup branches created: auto-backup/<project>/<branch>/<hostname>"
    echo "• Files remain private (excluded from version control)"
    echo
    echo "To verify backup is working:"
    echo "1. Make a commit: git commit -m \"Test backup\""
    echo "2. Check backup repository for new auto-backup branch"
    echo
    print_success "Setup complete! 🚀"
}

# Run setup if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
