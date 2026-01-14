#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://rocknix.org/)

BIOS_PATH=/storage/roms/bios/vita3k
CONFIG_FILE="/storage/.config/vita3k/config.yml"

#Iterate on the PUP Files and install them
cd $BIOS_PATH
for FW in *.PUP
do
vita3k-sa -f $CONFIG_FILE --firmware $FW
done
