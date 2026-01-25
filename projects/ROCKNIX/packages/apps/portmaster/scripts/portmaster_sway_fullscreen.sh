#!/bin/bash
# Will be called by PortMaster mod_ROCKNIX.txt

. /etc/profile.d/001-functions

if echo "${UI_SERVICE}" | grep -q "sway"; then
    # Call the function to fullscreen the window for app_id asynchronously
    sway_fullscreen "${1}" &

    # Explicitly map all input devices to the active game seat to prevent wayland focus revocation, and unify virtual input nodes.
    swaymsg 'seat seat1 attach "*"'
    swaymsg 'seat * keyboard_grouping smart'
fi
