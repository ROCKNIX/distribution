#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present UzuCore (https://github.com/UzuCore)

set -e

source /etc/profile

CODEX_BIN="/storage/.local/bin/codex"
CODEX_WORKSPACE="/storage/codex-workspace"

if [ ! -x "${CODEX_BIN}" ]; then
  echo "Codex is not installed. Run Install Codex from Tools first." >&2
  sleep 10
  exit 1
fi

if ! command -v bwrap >/dev/null 2>&1; then
  echo "bubblewrap is missing. Codex cannot safely run shell commands." >&2
  sleep 10
  exit 1
fi

mkdir -p "${CODEX_WORKSPACE}"
cd "${CODEX_WORKSPACE}"

if ! "${CODEX_BIN}" login status >/dev/null 2>&1; then
  echo "Codex sign-in is required."
  echo "Open the displayed URL on another device and enter the one-time code."
  echo ""
  "${CODEX_BIN}" login --device-auth
fi

exec "${CODEX_BIN}" -C "${CODEX_WORKSPACE}"
