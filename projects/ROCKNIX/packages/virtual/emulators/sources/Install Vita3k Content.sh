#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://rocknix.org/)

ROMS_PATH="/storage/roms/psvita"
CONFIG_FILE="/storage/.config/vita3k/config.yml"

#Iterate on the PUP Files and install them
cd $ROMS_PATH

for file in *.zip
do
echo "$file"
[ -f "$file" ] || continue
vita3k-sa -F -f "$CONFIG_FILE" "$file"
rm $file
done
/usr/bin/scan_vita3k.sh

