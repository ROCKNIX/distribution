#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

set_kill set "touchHLE"

/usr/bin/touchHLE --fullscreen >/dev/null 2>&1
