---
description: "Programming language best practices (Python, Bash, etc.)."
applyTo: "**/*.py, **/*.sh, **/*.bash"
---

# Programming Language Best Practices

## Python Standards

### Import and Module Organization
- **Always avoid modifying `sys.path` in scripts**
- Place all scripts that need to import from project modules inside the `src` directory
- Use standard Python import mechanisms: `from project.utils.module import function`
- Place imports at the top of files (no E402 violations)

### Code Quality Standards
- Follow PEP 8 with appropriate line limits for code files
- Use proper error handling with specific exception types
- Include comprehensive docstrings for all public functions
- Prefer descriptive function names over underscore prefixes
- Example: `validate_timestamp_format()` instead of `_validate_timestamp_format()`

### Environment and Logging
- Use standard `logging` module, configured at the top of the script before any logging calls
- Log to both console and a file in `tmp/logs/`, named after the script/module
- Use log levels: INFO, DEBUG, WARNING, ERROR
- Use `--verbosity` and `--debug` command-line flags, parsed with `argparse`
- Always use a virtual environment inside containers; validate environment variables

### Container Environment Management
- **Environment Variables**: Always use project-specific prefixes (e.g., `SPRINGOS_`, `PROJECT_`) for container-specific variables
- Use boolean strings ("true"/"false") rather than 1/0 for consistency
- Validate environment variables in container scripts before use
- Log environment variable values at container startup for debugging
- **Virtual Environment**: Export `VENV_PYTHON` and `VENV_PIP` environment variables for script use within containers

### Platform-Specific Python Considerations
- **macOS Homebrew Python**: May require `PYTHONPATH="$PWD/src:$PYTHONPATH"` prefix for proper module imports due to virtual environment isolation issues
- **Linux/Container environments**: Standard virtual environment behavior works as expected
- **Testing**: Always verify module imports before running test suites across different environments

## Bash/Shell Standards

### OS Compatibility
- All scripts must robustly detect the OS and use platform-specific logic
- Use standard error reporting and exit codes
- Use only standardized TUI components for user-facing output; never create custom UI wrappers

### Logging and Verbosity Standards
All Bash scripts should implement consistent logging with two independent flags:
- **`VERBOSITY`**: Controls log file detail levels (low/medium/high)  
- **`DEBUG`**: Controls on-screen debug/info output (true/false)

**Implementation Pattern:**
- Info lines (`log_verbose 'medium'`) are only printed to the terminal if `DEBUG=true`
- All info lines are always logged to the log file, with detail controlled by `VERBOSITY`
- These flags are independent and provide fine-grained control over output behavior

### Development Standards
- Use proper quoting and error handling
- Include usage/help functions
- Validate all input parameters
- Follow consistent naming conventions for variables and functions

## General Standards

- Strictly follow linting rules for blank lines and whitespace (e.g., flake8 for Python)
- Keep functions focused and single-purpose
- Use clear, descriptive variable and function names
- Include appropriate comments for complex logic
- Regularly test and validate code changes

---

*Synthesized from imported project guidelines and best practices. Review and update as needed for your project.*
