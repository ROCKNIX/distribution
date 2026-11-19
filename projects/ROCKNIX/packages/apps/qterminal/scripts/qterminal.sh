#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile
set_kill set "qterminal"

if [ ! -d "/storage/.config/qterminal.org" ]; then
     cp -r "/usr/config/qterminal.org" "/storage/.config/"
fi

# wvkbd default layout (`simple`) lacks Ctrl/Alt and arrows, useless in a
# terminal. We want `full,nav,special`. Also, sway fullscreen ignores layer-
# shell exclusive_zone, and plain tiled puts qterminal next to ES/foot in the
# same workspace. Solution: dedicate workspace 99 to qterminal so it's the
# sole tiled window there — sway then fills the workspace area minus wvkbd's
# exclusive_zone, giving us no overlap and no side-by-side tile.
prior_tskb=$(get_setting "rocknix.touchscreen-keyboard.enabled")
set_setting "rocknix.touchscreen-keyboard.enabled" "0"
pkill wvkbd-mobintl 2>/dev/null
sleep 0.2

# -H is portrait height, -L is landscape height. SM8750 boots landscape via
# sway transform=90, so -L is what matters here; without it wvkbd falls back
# to a tiny default (~120 px) and the keys end up squished. -fn 32 fits the
# 5-row `full` layout at 380 px without overflow.
/usr/bin/wvkbd-mobintl -H 380 -L 380 -fg 6b6b75 -fg-sp 6b6b75 -bg 1d1d1d \
  --text ffffff --text-sp ffffff -press 000000 --press-sp 000000 -fn 32 \
  -l full,nav,special &

# Stash the workspace we came from, so we can return there on exit.
prior_ws=$(swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')
swaymsg "workspace 99:qterminal"
swaymsg 'for_window [app_id="qterminal"] move container to workspace 99:qterminal, focus'

cleanup_osk() {
  pkill wvkbd-mobintl 2>/dev/null
  set_setting "rocknix.touchscreen-keyboard.enabled" "${prior_tskb:-1}"
  [ -n "${prior_ws}" ] && swaymsg "workspace ${prior_ws}" 2>/dev/null
}
trap cleanup_osk EXIT INT TERM

cd ~/
/usr/bin/qterminal
