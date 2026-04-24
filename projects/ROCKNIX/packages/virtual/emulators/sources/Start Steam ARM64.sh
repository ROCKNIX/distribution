#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile
set_kill set "-9 gamescope steam FEX"

touch ".local/share/applications/Steam.desktop"
mkdir -p /storage/roms/steam/steamapps
VDF="/storage/.local/share/Steam/steamapps/libraryfolders.vdf"
if [  -f $VDF ]; then
    grep -q '"/storage/roms/steam"' "$VDF" || sed -i '$ s/}/\t"1" {"path" "\/storage\/roms\/steam"}\n}/' "$VDF"
fi

#steam-arm
if [ ! -d "/storage/.local/share/Steam/steam-runtime-steamrt-arm64" ]; then
  mkdir -p "/storage/.local/share/Steam"
  wget -c -t 5 -O "/storage/.local/share/Steam/steam-runtime-steamrt-arm64.tar.xz" "https://repo.steampowered.com/steamrt3c/images/latest-public-beta/steam-runtime-steamrt-arm64.tar.xz"
  tar xvf "/storage/.local/share/Steam/steam-runtime-steamrt-arm64.tar.xz" -C "/storage/.local/share/Steam"
  rm -f "/storage/.local/share/Steam/steam-runtime-steamrt-arm64.tar.xz"
  target=$(echo /storage/.local/share/Steam/steam-runtime-steamrt-arm64/steamrt3c_platform_*/files/lib/aarch64-linux-gnu/libibus-1.0.so.5.*)
  mkdir -p /storage/.local/share/Steam/lib/aarch64-linux-gnu
  ln -sf "$target" /storage/.local/share/Steam/lib/aarch64-linux-gnu/libibus-1.0.so.5
fi

if [ ! -d "/storage/.local/share/Steam/steamrtarm64" ]; then
  MANIFEST=$(curl -fsSL "https://client-update.fastly.steamstatic.com/steam_client_publicbeta_linuxarm64" | strings)
  TARGET_FILE=$(echo "$MANIFEST" | grep -oP 'bins_linuxarm64_linuxarm64\.zip\.(?!vz\.)[^"]+')
  wget -c -t 5 -O "/storage/.local/share/Steam/linuxarm64.zip" "https://client-update.steamstatic.com/${TARGET_FILE}"
  unzip -o "/storage/.local/share/Steam/linuxarm64.zip" -d "/storage/.local/share/Steam"
  rm -f "/storage/.local/share/Steam/linuxarm64.zip"
  chmod +x "/storage/.local/share/Steam/steamrtarm64/steam"
  mkdir -p /storage/.local/share/Steam/package && echo publicbeta > /storage/.local/share/Steam/package/beta
  mkdir -p "/storage/.steam"
  ln -sf "/storage/.local/share/Steam" "/storage/.steam/steam"
  ln -sf "/storage/.local/share/Steam/linuxarm64" "/storage/.steam/sdkarm64"
  mkdir -p "/storage/.local/share/Steam/compatibilitytools.d/"
  ln -sf "/storage/.local/share/Steam/steamapps/common/Proton 11.0 (ARM64)/" "/storage/.local/share/Steam/compatibilitytools.d/Proton11ARM"
  cp -f  "/usr/share/steam/compatibilitytool.vdf" "/storage/.local/share/Steam/compatibilitytools.d/"
  LD_LIBRARY_PATH=/storage/.local/share/Steam/lib/aarch64-linux-gnu/ /storage/.local/share/Steam/steamrtarm64/steam
fi

eval $(swaymsg -t get_outputs | jq -r '
  .[] | select(.focused == true) |
  "W=\(.current_mode.width) H=\(.current_mode.height) TRANSFORM=\(.transform) REFRESH=\(.current_mode.refresh // 60000)"
')
REFRESH_HZ=$((REFRESH / 1000))
if [[ "$TRANSFORM" == "90" || "$TRANSFORM" == "270" || "$TRANSFORM" == "flipped-90" || "$TRANSFORM" == "flipped-270" ]]; then
  WIDTH=$H
  HEIGHT=$W
else
  WIDTH=$W
  HEIGHT=$H
fi

mkdir -p "/storage/.local/share/Steam/steamapps/common/Proton 11.0 (ARM64)/"
cp -f "/usr/share/steam/toolmanifest.vdf" "/storage/.local/share/Steam/steamapps/common/Proton 11.0 (ARM64)/"
echo 0 > /proc/sys/fs/binfmt_misc/x86_64
echo 0 > /proc/sys/fs/binfmt_misc/x86
if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
  swaymsg 'seat seat1 fallback true'
fi
swaymsg for_window [instance="steamwebhelper"] fullscreen enable
LD_LIBRARY_PATH=/storage/.local/share/Steam/lib/aarch64-linux-gnu/ gamescope -w $WIDTH -h $HEIGHT -W $WIDTH -H $HEIGHT -r $REFRESH_HZ -f -e -- /storage/.local/share/Steam/steamrtarm64/steam -bigpicture
if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
  swaymsg 'seat seat1 fallback false'
fi
systemctl restart systemd-binfmt
