---
description: "Architecture and development philosophy best practices."
applyTo: "**"
---

# Architecture & Development Philosophy

## Methodical Development Philosophy

- **"Measure Twice, Cut Once"**: Work methodically through planned steps, don't rush or conflate multiple tasks.
- Always ensure fixes are targeted - identify and isolate the root cause before implementing solutions.
- Verify current state before making changes - never assume the current state, always check first.
- Test after each change - validate that changes work as expected before proceeding.
- One step at a time - complete each phase fully before moving to the next.

## Core Architectural Principles (Optional)

### Three-Tier Architecture Pattern
For applicable projects:
- **Components Layer**: Reusable UI and infrastructure building blocks
- **Templates Layer**: Configurable patterns combining multiple components  
- **Applications Layer**: End-user functionality built from templates

### Container-First Development
Where applicable:
- Zero-dependency bootstrap process (host requires only Docker and Bash)
- All development tools containerized
- Cross-platform compatibility (Linux, macOS, WSL)

### API-Driven Architecture
For projects requiring API integration:
- All core functionality exposed via well-defined APIs
- Clear separation between API layer and implementation
- Consistent error handling and response formats
- Version-aware API design for backward compatibility

## Graceful Failure Handling

- Scripts err on the side of over-communicating with users
- Multiple remediation options offered before script termination
- Clear problem explanation with step-by-step recovery guidance
- **Never leave users at dead ends** - always provide actionable next steps
- **Avoid user-hostile "Aborting" messages** - explain what went wrong and how to fix it

## Safety Requirements

- **NEVER run setup scripts, installers, or any system-modifying commands automatically.**
- Always require explicit user confirmation before suggesting any script that could modify the system.
- Use only safe analysis methods: static code analysis, file checks, log examination.

---

*Synthesized from imported project guidelines and best practices. Review and update as needed for your project.*
