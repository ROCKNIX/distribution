---
description: "Model Context Protocol (MCP) server development and usage best practices."
applyTo: "**/*mcp*, **/mcp.json"
---

# MCP Server Development Instructions

## Overview

Model Context Protocol (MCP) servers provide enhanced context, automation, and integration capabilities for development workflows. They enable tools like GitHub Copilot to access project-specific APIs, tools, and data for richer, more relevant suggestions and automation.

## MCP Server Types

- **Local servers**: Running on your machine (e.g., in Docker containers)
- **Remote servers**: Cloud-hosted services (e.g., GitHub MCP server)
- **Custom servers**: Project-specific implementations for specialized workflows

## Authentication and Security

### Authentication Methods
- **OAuth**: Recommended for most users; provides same access as your account
- **Personal Access Token (PAT)**: Allows restricted access with specific scopes
- For remote servers, OAuth is default; for local servers, PAT is typically required

### Security Best Practices
- Always use minimum required scopes for PATs (typically `repo` and `read:packages`)
- Review and understand permissions when using OAuth (grants full account access)
- For organizations: Review Copilot Editor preview features and PAT policies
- Enterprise Managed Users: Check with administrators if PAT restrictions apply

### Configuration Locations
- **Repository-specific**: `.vscode/mcp.json` 
- **Global settings**: VS Code `settings.json`
- Choose based on whether MCP server is project-specific or workspace-wide

## Setup and Integration

### VS Code Integration
- Use command palette: `Cmd+Shift+P` → `mcp: add server`
- **Remote server URL**: `https://api.githubcopilot.com/mcp/`
- **Local server**: Ensure Docker is running; use official images when available

### Server Configuration
- Document required environment variables and authentication setup
- Provide clear setup instructions for team members
- Include Docker configuration examples for local development
- Test configuration across different development environments

## Development Standards

### MCP Server Implementation
- Follow standard API patterns for tool definitions and responses
- Implement proper error handling and logging
- Use typed interfaces for request/response schemas
- Document all available tools and their parameters

### Testing and Validation
- Test MCP servers with different authentication methods
- Validate integration with target development tools
- Test error scenarios and recovery paths
- Document troubleshooting steps for common issues

## Troubleshooting Common Issues

### Server Connection Issues
- Verify server is running and accessible
- Check authentication method validity and required scopes
- Restart IDE after configuration changes
- Review server logs for specific error messages

### Authentication Problems
- Verify PAT has correct scopes and hasn't expired
- For OAuth, ensure proper authorization flow completion
- Check organization-level restrictions for Enterprise users
- Validate network connectivity to remote servers

## Documentation Requirements

- Maintain clear setup instructions for each MCP server
- Document authentication requirements and setup process
- Provide troubleshooting guides for common scenarios
- Include example configurations for different use cases

---

*Synthesized from MCP server development practices. Adapt authentication and configuration details for your specific servers.*
