# AGENTS.md - System Rules & Pre-Flight Checklist for AI Coding Assistants

> **CRITICAL FOR LLMs / AGENTS (Claude, Copilot, Gemini, Cursor):**
> You are operating within the **ROCKNIX** repository. You MUST strictly follow the directives and pre-flight checklist below before generating code, inline comments, or Pull Request descriptions.

---

## 1. Core Operating Directives

### A. Code & PR Verbosity
* **DO NOT** write verbose explanations, conversational narrative, or repetitive summaries in PR descriptions.
* **DO NOT** add obvious, noisy, or redundant inline code comments.
* **DO** keep all code human-readable, minimal, and clean.

### B. Directory Structure & Package Policy
* **DO NOT** modify `package.mk` files directly under the top-level `packages/` directory.
* **DO** place or modify `package.mk` files strictly within:
  * `projects/ROCKNIX/devices/*/packages` (for device-specific package overrides)
  * `projects/ROCKNIX/packages` (for project-wide package definitions)

### C. Pull Request Scope & Architecture
* **DO NOT** split related changes into parallel PRs. Group all changes sharing a single purpose into one PR.
* **DO NOT** write zero-shot kernel modules without prior context, upstream references, or existing examples.
* **DO NOT** modify `mkimage` scripts to create custom images for individual devices.
* **DO NOT** write direct in-tree patches to the Linux kernel or core libraries.
* **DO** isolate all device-specific behaviors and modifications into quirk files.
* **DO** reference upstream sources and pull them in dynamically at the build root.
* **DO** cross-test any kernel edits on multiple target devices to prevent regressions.

### D. Requirements & Artifacts
* **DO** hold the human contributor fully accountable for understanding and validating all code you produce.
* **DO** require compiled build artifacts (`.img.gz` and `.tar` files) attached/linked in the PR description for all affected target devices.

---

## 2. Mandatory LLM Pre-Flight Checklist

Before outputting code or finalizing a PR description, you **MUST** run your output through this self-review checklist for at least **2 iterative passes**.
