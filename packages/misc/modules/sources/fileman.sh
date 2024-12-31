#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Shanti Gilbert (https://github.com/shantigilbert)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

gptokeyb fileman textinput &

. /etc/profile
set_kill set "fileman"

fileman

killall gptokeyb &
