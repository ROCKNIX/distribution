#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

GPCAL_PATH="/usr/local/share/gpcal"

source /etc/profile

set_kill set "python3"

sway_fullscreen "python3" &

# Enable the python3 venv that has the pyxel library installed
# Note: the activate script relies on the CWD, thus the cd 
# before
cd "$GPCAL_PATH"
source pyxel/bin/activate

# PYTHONDONTWRITEBYTECODE: We don't expect to do write files
# on a readonly mount point. Thus we tell Python to not try to
# write .pyc files on the import of source modules.
PYTHONDONTWRITEBYTECODE=1 python3 main.py
