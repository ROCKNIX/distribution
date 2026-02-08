#!/bin/bash
# Will be called by PortMaster mod_ROCKNIX.txt

. /etc/profile

if echo "${UI_SERVICE}" | grep -q "sway"; then
    # Call the function to fullscreen the window for app_id asynchronously
    sway_fullscreen "${1}" &

    # Create a virtual touch keyboard device if there are two displays
    if [[ "${DEVICE_HAS_DUAL_SCREEN}" == "true" ]]; then
        TSKEY=$(get_setting "rocknix.touchscreen-keyboard.enabled")
        if [[ "${TSKEY}" == "1" ]]; then
            swaymsg 'output DSI-1 power on'
            (
              sleep 2
              swaymsg 'seat seat1 fallback yes'
            ) &
        fi
    fi
fi
