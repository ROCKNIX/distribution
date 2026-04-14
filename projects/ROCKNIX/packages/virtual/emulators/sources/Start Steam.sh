#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile
set_kill set "-9 FEX"

if [ ! -d "/storage/.config/fex-emu" ]; then
    cp -r "/usr/config/fex-emu" "/storage/.config/"
fi
if [ ! -f "/storage/.local/share/fex-emu/RootFS/ArchLinux.sqsh" ]; then
     echo "FEX needs to download rootfs before starting Steam. This may take a while..."
     FEXRootFSFetcher --distro-name=arch --distro-version=rolling -y -x
fi
cp -f "/usr/share/fex-emu/libvulkan_freedreno.so" "/storage/.local/share/fex-emu/RootFS/ArchLinux/usr/lib"
touch ".local/share/applications/Steam.desktop"
mkdir -p /storage/roms/steam/steamapps
VDF="/storage/.local/share/Steam/steamapps/libraryfolders.vdf"
if [  -f $VDF ]; then
    grep -q '"/storage/roms/steam"' "$VDF" || sed -i '$ s/}/\t"1" {"path" "\/storage\/roms\/steam"}\n}/' "$VDF"
fi

export GSK_RENDERER=gl
systemctl stop systemd-binfmt
swaymsg for_window [instance="steamwebhelper"] fullscreen enable
FEX /usr/bin/steam -bigpicture
systemctl start systemd-binfmt
