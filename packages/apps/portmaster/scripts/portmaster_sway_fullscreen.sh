#!/bin/bash
# Will be called by PortMaster mod_ROCKNIX.txt

# Call the function to fullscreen the window for app_id asynchronously
. /etc/profile.d/001-functions
sway_fullscreen "${1}" &
