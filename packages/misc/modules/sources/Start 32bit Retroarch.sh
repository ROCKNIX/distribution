#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

source /etc/profile

set_kill set "retroarch32"
/usr/bin/retroarch32 --appendconfig /usr/config/retroarch/retroarch32bit-append.cfg
