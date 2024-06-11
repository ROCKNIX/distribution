#!/bin/bash

if pgrep -x "waybar" > /dev/null
then
    # Waybar is running, send SIGUSR1 to toggle visibility
    pkill -SIGUSR1 waybar
else
    # Waybar is not running, start it
    waybar &
fi
