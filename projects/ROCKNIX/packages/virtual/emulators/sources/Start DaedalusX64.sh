#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile

set_kill set "daedalus"

cd /storage/.config/DaedalusX64/
/storage/.config/DaedalusX64/daedalus >/dev/null 2>&1
