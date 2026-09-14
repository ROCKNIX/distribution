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

if ! resolve_heroic_bin; then
  echo "Heroic: launcher binary not found under ${HEROIC_BASE}. Run 'Install Heroic Games Launcher.sh' first." >&2
  exit 1
fi

if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
  swaymsg 'seat seat1 fallback true'
fi
trap '[ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ] && swaymsg "seat seat1 fallback false" || true' EXIT
swaymsg for_window [app_id="heroic"] fullscreen enable
swaymsg for_window [class="heroic"] fullscreen enable

eval "$(swaymsg -t get_outputs | jq -r '
  .[] | select(.focused == true) |
  "W=\(.current_mode.width) H=\(.current_mode.height) TRANSFORM=\(.transform)"
')"
if [[ "${TRANSFORM:-}" == "90" || "${TRANSFORM:-}" == "270" || "${TRANSFORM:-}" == "flipped-90" || "${TRANSFORM:-}" == "flipped-270" ]]; then
  WIDTH="${H}"
  HEIGHT="${W}"
else
  WIDTH="${W}"
  HEIGHT="${H}"
fi

if ! command -v gamescope >/dev/null 2>&1; then
  command -v mako-notify >/dev/null 2>&1 && mako-notify "Heroic: gamescope not installed." -no-es
  exit 1
fi

if [ -z "${WIDTH:-}" ]; then
  command -v mako-notify >/dev/null 2>&1 && mako-notify "Heroic: display size not found." -no-es
  exit 1
fi

cd "$(dirname "${HEROIC_BIN}")" || exit 1
gamescope -f -W "${WIDTH}" -H "${HEIGHT}" -- "${HEROIC_BIN}" --no-sandbox "$@"
