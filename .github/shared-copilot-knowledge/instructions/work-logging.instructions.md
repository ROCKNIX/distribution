---
description: "Work logging, timestamp management, and project tracking best practices."
applyTo: "**/*work_log*, **/*timestamp*, **/docs/**"
---

# Work Logging and Timestamp Management

## Work Log Principles

Maintain a detailed, structured work log that serves as a blended changelog, commit summary, and work diary. This provides essential historical context for all contributors and enables effective project tracking.

## Work Log Entry Standards

### Chronological Organization
- **Reverse chronological order**: Most recent entries at the top
- **Date headers**: Use format `#### July 30, 2025`
- **Time stamps**: Include time in HH:MM AM/PM format (project timezone)

### Entry Insertion Rules

**Same Date Insertion:**
```markdown
#### July 30, 2025

11:56 AM [new entry]
New entry content here.

11:54 AM [previous latest entry]
Previous entry content here.
```

**New Date Insertion:**
```markdown
# Project Work Log
#### July 30, 2025

11:56 AM [new entry]
New entry content here.

---

#### July 29, 2025

11:54 PM [previous latest entry]
Previous entry content here.
```

### Entry Formatting Standards
- **Time format**: HH:MM AM/PM (project timezone)
- **Event tags**: In brackets following timestamp: `[problem identified]`, `[feature completed]`, `[bug fixed]`
- **Content structure**: Tag on same line as timestamp, content on new line
- **Spacing**: Blank line between entries for readability

### Event Tag Categories
- `[analysis]`: Investigation and research work
- `[development]`: Code implementation and changes
- `[testing]`: Testing activities and results
- `[documentation]`: Documentation updates and additions
- `[problem identified]`: Issues discovered during development
- `[solution implemented]`: Problems resolved or workarounds applied
- `[meeting]`: Team discussions and decisions
- `[deployment]`: Release and deployment activities

## Timestamp Management

### Documentation Timestamps
- All code and documentation files must include properly formatted "Last updated:" footer
- Use automated tools for timestamp management where available
- Maintain timestamp accuracy for tracking changes and documentation integrity
- Include timezone information for clarity across distributed teams

### Automated Timestamp Tools
- Implement pre-commit hooks for timestamp validation and updates
- Use project-specific timestamp format standards
- Validate timestamp accuracy during CI/CD processes
- Provide tools for bulk timestamp updates when needed

## Project Tracking Integration

### Work Log as Historical Context
- Link work log entries to specific commits, PRs, and issues
- Include relevant file paths and function names in entries
- Document decision rationale and alternatives considered
- Track time estimates vs. actual time for future planning

### Collaboration Benefits
- Enable effective knowledge transfer between team members
- Provide context for code reviews and debugging sessions
- Support project retrospectives and process improvements
- Maintain institutional knowledge through personnel changes

## Best Practices

### Daily Workflow Integration
- Update work log throughout the day, not just at completion
- Include both successes and challenges encountered
- Document unexpected discoveries and learning opportunities
- Reference external resources and documentation used

### Quality Standards
- Use clear, descriptive language in entries
- Include sufficient context for future reference
- Avoid overly technical jargon that limits accessibility
- Maintain consistent formatting and terminology

---

*Synthesized from project tracking and work logging best practices. Adapt timestamp formats and timezone requirements for your project.*
