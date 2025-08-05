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
