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
            swaymsg 'output DSI-1 power on, seat seat1 fallback no'
        fi
    fi
    
    # The following conditionals deal with focus revocation quirks on specific devices
    
    # Force all inputs into seat1 to bypass the Thor's 0:0 input ID collisions
    if [[ "${QUIRK_DEVICE}" == "AYN Thor" ]]; then
        swaymsg 'seat seat1 attach "*"'
        swaymsg 'seat * keyboard_grouping none'
    fi

    # Put touchscreen into seat0 for Anbernic RG DS
    if [[ "${QUIRK_DEVICE}" == "Anbernic RG DS" ]]; then
        swaymsg seat seat0 attach "1046:911:Goodix_Capacitive_TouchScreen"
    fi
fi
