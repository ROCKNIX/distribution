#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile
set_kill set "-9 heroic Heroic"

HEROIC_BASE="/storage/.local/share/heroic-arm64"
HEROIC_BIN=""

resolve_heroic_bin() {
  HEROIC_BIN=""
  for candidate in "${HEROIC_BASE}"/Heroic*/heroic "${HEROIC_BASE}"/heroic; do
    [ -x "${candidate}" ] || continue
    HEROIC_BIN="${candidate}"
    return 0
  done
  return 1
}

cleanup_keyboard() {
  kwin_keyboard 0
  kwin_keyboard off
}

if ! resolve_heroic_bin; then
  echo "Heroic: launcher binary not found under ${HEROIC_BASE}. Run 'Install Heroic Games Launcher.sh' first." >&2
  exit 1
fi

trap 'cleanup_keyboard' EXIT

cd "$(dirname "${HEROIC_BIN}")" || exit 1
kwin_keyboard on
systemctl is-active --quiet touchkeyboard && kwin_keyboard 1

export ELECTRON_OZONE_PLATFORM_HINT=wayland
"${HEROIC_BIN}" --no-sandbox --ozone-platform=wayland "$@"
