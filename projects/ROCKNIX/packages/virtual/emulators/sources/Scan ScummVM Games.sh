#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

clear

/usr/bin/sdl2notify --center "Scanning \n ScummVM Games" 255 255 255 2

# Scanning for games...
bash /usr/bin/start_scummvm.sh add >/dev/null 2>&1
# Adding games...
bash /usr/bin/start_scummvm.sh create >/dev/null 2>&1
clear

/usr/bin/sdl2notify --center "Scanning Complete" 255 255 255 2

systemctl restart ${UI_SERVICE}
