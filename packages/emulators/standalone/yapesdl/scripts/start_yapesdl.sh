#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023-present ROCKNIX (https://github.com/ROCKNIX)

CONFIG_DIR="/storage/.config/yapesdl"
PREFS_LINK="/storage/.local/share/Gaia/yapeSDL"

mkdir -p "$CONFIG_DIR"
mkdir -p "$(dirname "$PREFS_LINK")"

ln -snf "$CONFIG_DIR" "$PREFS_LINK"

/usr/bin/yapesdl "$@"