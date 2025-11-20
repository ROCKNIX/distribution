#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile.d/001-functions

# Get Cheevos LED state
CHEEVOS_LED=$(get_setting "global.retroachievements.leds")
if [ ! -n "${CHEEVOS_LED}" ]; then
  set_setting "global.retroachievements.leds" "0"
fi

if [ "${CHEEVOS_LED}" == "1" ]; then
  if [ -f "/usr/lib/autostart/quirks/devices/${QUIRK_DEVICE}/bin/achievements" ]; then
    "/usr/lib/autostart/quirks/devices/${QUIRK_DEVICE}/bin/achievements" $* &
  elif [ -f "/usr/lib/autostart/quirks/platforms/${HW_DEVICE}/bin/achievements" ]; then
    "/usr/lib/autostart/quirks/platforms/${HW_DEVICE}/bin/achievements" $* &
  fi
fi
