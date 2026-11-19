#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile
set_kill set "-9 heroic Heroic"

HEROIC_BASE="/storage/.local/share/heroic-arm64"
HEROIC_BIN=""
WVKBD_PID=""
TOUCHKB_WAS_ACTIVE=0

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
  if [ -n "${WVKBD_PID}" ]; then
    kill "${WVKBD_PID}" 2>/dev/null || true
  fi
  if [ "${TOUCHKB_WAS_ACTIVE}" = "1" ]; then
    systemctl start touchkeyboard.service >/dev/null 2>&1 || true
  fi
  if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
    swaymsg 'seat seat1 fallback false' >/dev/null 2>&1 || true
  fi
}

if ! resolve_heroic_bin; then
  echo "Heroic: launcher binary not found under ${HEROIC_BASE}. Run 'Install Heroic Games Launcher.sh' first." >&2
  exit 1
fi

trap 'cleanup_keyboard' EXIT

cd "$(dirname "${HEROIC_BIN}")" || exit 1
if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
  swaymsg 'seat seat1 fallback true'
fi
swaymsg for_window [app_id="heroic"] fullscreen disable
swaymsg for_window [class="heroic"] fullscreen disable

if systemctl is-active --quiet touchkeyboard.service; then
  TOUCHKB_WAS_ACTIVE=1
  systemctl stop touchkeyboard.service >/dev/null 2>&1 || true
fi
killall wvkbd-mobintl >/dev/null 2>&1 || true
sleep 0.2

WVKBD_OUT="$(swaymsg -t get_outputs -r 2>/dev/null | jq -r '.[] | select(.focused == true) | .name' | head -n1)"
WVKBD_ARGS=(
  -L 500
  -fg 6b6b75 -fg-sp 6b6b75 -bg 1d1d1d --text ffffff --text-sp ffffff -press 000000 --press-sp 000000 -fn 48 -l simple
)
[ -n "${WVKBD_OUT}" ] && WVKBD_ARGS+=(--output "${WVKBD_OUT}")
/usr/bin/wvkbd-mobintl "${WVKBD_ARGS[@]}" >/dev/null 2>&1 &
WVKBD_PID=$!
sleep 0.25
kill -USR2 "${WVKBD_PID}" 2>/dev/null || true

export ELECTRON_OZONE_PLATFORM_HINT=wayland
"${HEROIC_BIN}" --no-sandbox --ozone-platform=wayland "$@"
