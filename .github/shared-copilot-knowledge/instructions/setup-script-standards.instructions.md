---
description: "Setup script development standards and user experience best practices."
applyTo: "**/bin/setup/**, **/*setup*, **/*install*"
---

# Setup Script Development Standards

## Safety-First Development

- **NEVER run setup scripts automatically** - always require explicit user confirmation
- **STRICTLY PROHIBITED**: Automated input simulation with `echo`, `printf`, pipes, or input redirection
- Use only safe analysis methods: static code analysis, file checks, log examination
- Request explicit user confirmation before suggesting any system-modifying script

**Rationale:** Setup and configuration scripts can make irreversible system changes. User oversight ensures safety and prevents unintended modifications to their development environment.

## Logging and Verbosity Standards

### Canonical Info Line and Flag Standard for Bash Scripts
All Bash scripts should implement consistent logging with two independent flags:
- **`VERBOSITY`**: Controls log file detail levels (low/medium/high)
- **`DEBUG`**: Controls on-screen debug/info output (true/false)

**Implementation Pattern:**
- Info lines (`log_verbose 'medium'`) are only printed to the terminal if `DEBUG=true`
- All info lines are always logged to the log file, with detail controlled by `VERBOSITY`
- This standard ensures consistent output behavior across all setup scripts

## User Experience Standards

### Progress and Status Feedback
- Always provide clear progress indicators for multi-step operations
- Use consistent status messages and completion feedback
- Show estimated time or step count where appropriate
- Provide clear remediation guidance for failures

### Interactive Elements
- Always confirm destructive or system-modifying operations
- Provide clear yes/no prompts with sensible defaults
- Use arrow key selection menus for complex choices
- Always provide "skip" or "abort" options for optional steps

### Error Recovery and Diagnostics
- Capture and display meaningful error messages
- Provide specific guidance for common failure scenarios
- Log detailed error information for debugging
- Offer retry mechanisms for transient failures

### Documentation Integration
- Link to relevant documentation for complex operations
- Provide inline help text for confusing steps
- Reference troubleshooting guides for known issues
- Include examples for complex configuration steps

## OS Detection and Platform Logic

All setup scripts should implement robust OS detection when platform-specific behavior is needed:

```bash
detect_os() {
    if [ "$(uname)" == "Darwin" ]; then
        echo "macos"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        echo "linux"
    elif grep -q Microsoft /proc/version 2>/dev/null; then
        echo "wsl"
    else
        echo "unknown"
    fi
}
```

## Container-First Architecture Support

Setup logic should support canonical workflow patterns where applicable:
1. Host environment bootstrap (zero dependencies)
2. Container environment setup
3. Container activation and entry
4. Container-based installation execution

---

*Synthesized from imported project guidelines and best practices. Review and update as needed for your project.*
