---
description: "Container-first development patterns and standards."
applyTo: "**/Dockerfile, **/docker-compose.yml, **/*container*"
---

# Container-First Development Instructions

## Core Container-First Principles

- **Zero-dependency bootstrap process** (host requires only Docker and Bash)
- **All development tools containerized** for cross-platform compatibility (Linux, macOS, WSL)
- **Environment isolation** with all packages installed in virtual environments inside containers
- **Automatic environment activation** via container initialization scripts
- **Terminal session observability** with host-accessible logging
- **Application logging** to mounted directories accessible from host

## Environment Variables Standard

- Always use project-specific prefixes for container-specific variables (e.g., `SPRINGOS_`, `PROJECT_`)
- Use boolean strings ("true"/"false") rather than 1/0 for consistency
- Validate environment variables in container scripts before use
- Log environment variable values at container startup for debugging
- Export environment variables like `VENV_PYTHON` and `VENV_PIP` for script use

## Container Lifecycle Management

**Separation of Concerns:**
- **Activation**: Start/ensure container daemon is running (`*_container_activation`)
- **Entry**: Enter running container for specific tasks (`*_container_launch`)

### Canonical Workflow Pattern
1. `dev_env_setup` → Sets up host development environment
2. `*_container_setup` → Builds container image
3. `*_container_activation` → Starts container daemon
4. `*_container_launch` → Enters container for specific tasks

## Container Environment Layers

Organize development and deployment into distinct layers:

- **Dev Environment (dev env)**: Developer's local environment with flexibility in tooling
- **Build Environment (build env)**: Containerized build and compilation environment
- **Runtime Environment (runtime env)**: Production-like deployment environment

## Safety Requirements

- **NEVER run setup scripts automatically** - always require explicit user confirmation
- **STRICTLY PROHIBITED**: Automated input simulation with echo, printf, pipes
- Use only safe analysis methods: static code analysis, file checks, log examination
- Implement proper error handling and graceful failure modes

## Python in Containers

- **Virtual Environment Management**: Always use virtual environments inside containers
- **Path Configuration**: Avoid `sys.path` modifications; use standard import mechanisms
- **Environment Activation**: Export `VENV_PYTHON` and `VENV_PIP` variables for script use
- **Dependency Management**: Use `pyproject.toml` or `requirements.txt` for reproducible builds

## Container State Management

- **Re-run Behavior**: If container already running → show "Already Complete!" → offer entry options
- **State Validation**: Use direct Docker commands to verify container is running and accessible
- **Graceful Restart**: Handle container restart scenarios without data loss

---

*Synthesized from SpringOS container-first development practices. Adapt as needed for your project.*
