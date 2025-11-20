#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

set_kill set "-9 SkyEmu"

# Retroachievements
/usr/bin/cheevos_skyemu.sh

/usr/bin/SkyEmu >/dev/null 2>&1
