# AGENTS.md - System Rules & Pre-Flight Checklist for AI Coding Assistants

> **CRITICAL FOR LLMs / AGENTS (Claude, Copilot, Gemini, Cursor):**
> You are operating within the **ROCKNIX** repository. You MUST strictly follow the directives and pre-flight checklist below before generating code, inline comments, or Pull Request descriptions.
> Re-read this file before every PR.

> **FUNDAMENTAL RULE:** All submitted code must be fully understood by both the LLM that helped write it and the human contributor submitting it. The contributor must be able to explain every line without the AI, and the LLM must be able to explain every line it produces. If either cannot, do not submit it.

---

## 1. Core Operating Directives

### A. Code & PR Verbosity
* **HARD RULE:** All public PR bodies and comments **MUST** be written in the contributor's voice, concise, and read as human-written. No long text unless it is strictly needed to report test results.
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
* **AVOID** Linux kernel and core library patches as much as possible. Add one only when it is strictly necessary and well justified.
* **IF** a kernel patch is necessary and the most robust solution, keep it small, well tested, explainable line by line, and backed by an upstream or vendor reference.
* **DO** isolate all device-specific behaviors and modifications into quirk files.
* **DO** reference upstream sources and pull them in dynamically at the build root.
* **DO** cross-test any kernel edits on multiple target devices to prevent regressions.

### D. Requirements & Artifacts
* **DO** hold the human contributor fully accountable for understanding and validating all code you produce.
* **DO** link compiled build artifacts (`.img.gz` and `.tar` files) in the PR description for all affected target devices where possible.

### E. Pull Request Discipline
* **DO** size PRs between two extremes. Both are costly:
  * **Too small:** ten PRs with related 2-3 line changes bloat the PR queue, scatter one idea across many reviews, and can leave things half-merged.
  * **Too large:** a single PR with more than 500 lines of code is difficult to review line by line, hard to test, bisect, or revert, and one problem holds up everything in it. Aim to stay under 500 lines, excluding imported patches, source files, new device support, and mechanical version bumps or package cleanups.
  * Break up extremely large PRs into reasonably smaller ones where possible, each a complete change that can be tested on its own.
* **DO NOT** submit features nobody asked for. Fix a reported problem or a clear gap.
* **DO** keep each PR to one logical change, ideally one squashed commit, small enough for a reviewer to read line by line.
* **DO** fill in the PR template, including an honest AI disclosure.
* **DO** address review nits promptly with a force-push of the same commit.

### F. Testing & Evidence
* **DO NOT** propose changes that have not been run on real hardware, or, for build-only changes, built successfully.
* **DO** put test results, measurements, and background only in the PR body: before/after numbers, device tested, steps.
* **DO** cite the upstream, mainline, or vendor source a change is based on.

### G. Code & Commit Style
* **DO NOT** add explanatory comments unless the code truly needs one. A patch carries its code and a one-line subject.
* **DO NOT** put test results or background in patch headers, commit messages, or code comments.
* **DO NOT** edit patches that are meant to go upstream just to restyle them.
* **DO NOT** remove comments from imported, vendor, or upstream-bound code. In the contributor's own code, a critical section may keep one comment line.
* **DO** follow existing patterns, even when that means copying a per-device config, instead of clever cross-device or `sed` tricks to save lines.
* **DO** match commit titles to the CI check: `^[a-zA-Z0-9_*./-]+:[[:space:]].+$` (no spaces in the prefix), at most 72 characters, a blank line before any body, and no merge commits.

### H. Packaging, Quirks & Defaults
* **DO** gate device features with a `DEVICE_*` variable set in a quirk file, and add that variable to `quirks/profile.d/999-export`.
* **DO** install quirk scripts with mode `0755`.
* **DO** update `PKG_SHA256` with a `PKG_VERSION` bump if the package sets one.
* **DO NOT** change user-facing defaults (power, performance, behavior) to work around a bug. Fix the bug.

---

## 2. Mandatory LLM Pre-Flight Checklist

Before outputting code or finalizing a PR description, you **MUST** run your output through this self-review checklist for at least **2 iterative passes**.

1. Is this one logical change, requested or clearly needed, and a reviewable size: not split into tiny PRs, aiming for under 500 lines of own code?
2. Was every changed line run on real hardware, or, for build-only changes, built successfully, with results recorded in the PR body?
3. Does the diff touch only allowed locations (Section 1.B) and avoid per-device `mkimage` changes? Is any kernel patch strictly necessary, well justified, small, tested, and explainable?
4. Is every comment necessary? Are patch headers and commit messages free of test logs and background?
5. Does it follow the existing pattern for neighboring devices and packages?
6. Do commit titles pass the CI regex and the 72-character limit?
7. Are new `DEVICE_*` variables exported, quirk files `0755`, and any `PKG_SHA256` updated?
8. Does every PR body and comment read as the contributor wrote it: concise, human, long only for test results? Is the AI disclosure filled in honestly?
9. Can the human contributor explain and defend every line?
