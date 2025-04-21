#!/bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

if [ ${DEVICE_HAS_TOUCHSCREEN} = 'true' ]; then

# Identify touchscreen controller
TRIES=0
TOUCHSCREEN=$(swaymsg -t get_inputs | jq -r '.[] | select(.type == "touch") | .identifier')
while [ -z "${TOUCHSCREEN}" -a $TRIES -lt 30 ]; do
	TRIES=$((TRIES+1))
	sleep 1
	TOUCHSCREEN=$(swaymsg -t get_inputs | jq -r '.[] | select(.type == "touch") | .identifier')
done

# Identify display output
OUTPUT=$(swaymsg -t get_outputs | jq -r '.[] | select (.focused).name')

# Map touchscreen
swaymsg input "${TOUCHSCREEN}" map_to_output "${OUTPUT}"

fi
