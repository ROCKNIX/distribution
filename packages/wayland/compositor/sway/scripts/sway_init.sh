#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

export SWAY_HOME=/storage/.config/sway/
export SWAY_CONFIG=/usr/share/sway/config.kiosk

if [ ! -d "$SWAY_HOME" ]
then
  mkdir $SWAY_HOME
fi

# Copy base config, we are overwriting any user config
cp $SWAY_CONFIG $SWAY_HOME/config

# get the card number, this may not be a safe way to derive it...
card_no=$(ls /sys/class/drm/ | grep -E "HDMI|DSI" | head -n 1 | cut -b 5)

env_file=/storage/.config/profile.d/095-sway

# Write wlroots env vars
rm -f ${env_file}
echo "WLR_DRM_DEVICES=/dev/dri/card${card_no}" >> ${env_file}
echo "WLR_BACKENDS=drm,libinput" >> ${env_file}

# Scan connectors
card=/sys/class/drm/card${card_no}
for connector in ${card}/card${card_no}*/
do
    status=$(cat ${connector}/status)
    if [ "$status" = "connected" ]; then
	con=$(basename $connector)
	con=${con: +6}
    fi
done

# Generate output line for sway config
if [[ $(grep -L "output" $SWAY_HOME/config) ]]
then
rot=$(cat /sys/class/graphics/fbcon/rotate)
output="output ${con}"
    if [ $rot = 1 ]; then
        angle="90"
    elif [ $rot = 2 ]; then
        angle="180"
    elif [ $rot = 3 ]; then
        angle="270"
    else
        angle="0"
    fi
    echo "${output} transform ${angle}" >> $SWAY_HOME/config
    echo "${output} max_render_time off" >> $SWAY_HOME/config
fi
