#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

clear
# Scanning for games...
bash /usr/bin/start_scummvm.sh add >/dev/null 2>&1
# Adding games...
bash /usr/bin/start_scummvm.sh create >/dev/null 2>&1
clear
systemctl restart ${UI_SERVICE}
