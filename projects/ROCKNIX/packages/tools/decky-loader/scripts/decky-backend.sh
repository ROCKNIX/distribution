#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

DECKY_LOADER_HOME="/storage/.config/decky-loader"
mkdir -p $DECKY_LOADER_HOME/data
mkdir -p $DECKY_LOADER_HOME/plugins

UNPRIVILEGED_PATH="$DECKY_LOADER_HOME/data" \
    PLUGIN_PATH="$DECKY_LOADER_HOME/plugins" \
    PYTHONPATH="/usr/share/decky-loader/backend/lib/" python3 /usr/share/decky-loader/backend/main.py