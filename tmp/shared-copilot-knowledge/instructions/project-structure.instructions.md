---
description: "Project structure and file organization standards."
applyTo: "**"
---

# Project Structure Standards

## Repository Organization

### Top-Level Structure
Use a clear top-level directory structure appropriate for your project type:

```
project/
├── bin/                    # Executable scripts and entry points
├── config/                 # Configuration files and templates
├── docs/                   # All project documentation
├── examples/               # Usage examples and templates
├── logs/                   # Runtime log files (optional)
├── src/                    # Source code
├── tests/                  # Test suites and fixtures
├── tmp/                    # Temporary files and development artifacts
└── tools/                  # Development and maintenance utilities
```

### Binary Organization
**Functional grouping by purpose:**

```
bin/
├── admin-tools/           # Administrative utilities
├── dev-env-setup/         # Development environment setup
├── pre-commit-hooks/      # Git pre-commit hook implementations
├── shared-utilities/      # Reusable utility scripts
└── install/               # Installation and deployment scripts
```

### Documentation Structure
**Hierarchical organization by audience and purpose:**

```
docs/
├── applications/          # Application-specific guides
├── development_guides/    # Development practices and standards
├── reference_library/     # Technical references
├── setup/                 # Installation and configuration guides
└── troubleshooting/       # Problem-solving and debugging guides
```

## File Naming Conventions

### Script Naming Standards
- Use descriptive, functional names: `dev_env_setup`, `container_activation`
- Avoid generic names: `setup.sh`, `install.sh`
- Avoid phase-based naming: `phase1_installer`

### Instruction File Naming
- **Required suffix**: `.instructions.md`
- **Descriptive names**: `python.instructions.md`, `testing.instructions.md`
- **Use YAML frontmatter** `applyTo` field for file targeting

### Documentation File Standards
- Use lowercase with underscores: `installation_guide.md`
- Include purpose in name: `troubleshooting_guide.md`
- Use absolute paths in references: `docs/guides/setup.md`

## Modularity and Organization Principles

- Group related functionality together
- Separate concerns clearly (e.g., setup vs. runtime vs. testing)
- Use consistent naming patterns across the project
- Organize files by function rather than by file type
- Maintain clear separation between source code, tests, documentation, and utilities

---

*Synthesized from imported project guidelines and best practices. Review and update as needed for your project.*
