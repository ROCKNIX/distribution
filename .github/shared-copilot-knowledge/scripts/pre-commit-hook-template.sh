#!/bin/bash
set -e
SRC_DIR="$(git rev-parse --show-toplevel)/.github"
DEST_DIR="$(git rev-parse --show-toplevel)/imported/$(hostname)"
mkdir -p "$DEST_DIR"
cp "$SRC_DIR"/*.instructions.md "$DEST_DIR" 2>/dev/null || true
cp "$SRC_DIR"/copilot-instructions.md "$DEST_DIR" 2>/dev/null || true
# Also back up instructions from .github/instructions/
if [ -d "$SRC_DIR/instructions" ]; then
  cp "$SRC_DIR/instructions"/*.instructions.md "$DEST_DIR" 2>/dev/null || true
fi
if [ $? -eq 0 ]; then
  echo "[pre-commit] Copilot instructions backup completed successfully."
else
  echo "[pre-commit] Copilot instructions backup failed." >&2
fi
exit 0
