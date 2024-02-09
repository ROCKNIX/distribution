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

if [ ! -f "$SWAY_HOME/config" ]
then
    cp $SWAY_CONFIG $SWAY_HOME/config
fi

# Scan connectors
card_no=${WLR_DRM_DEVICES: -1}
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
output_tmp="output ${con} transform "
    if [ $rot = 1 ]; then
        output="${output_tmp} 90"
    elif [ $rot = 2 ]; then
        output="${output_tmp} 180"
    elif [ $rot = 3 ]; then
        output="${output_tmp} 270"
    else
        output="${output_tmp} 0"
    fi
    echo "${output}" >> $SWAY_HOME/config
fi
