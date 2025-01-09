
#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

set_kill set "-9 melonDS"

sway_fullscreen "net.kuribo64.melonDS" &

export QT_QPA_PLATFORM=wayland

/usr/bin/melonDS
