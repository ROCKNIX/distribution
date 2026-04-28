#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile
set_kill set "-9 steam FEX"
cp -r "/usr/config/fex-emu" "/storage/.config/"
if [ -d /storage/.local/share/Steam ] && [ ! -L /storage/.local/share/Steam ]; then
    rm -rf /storage/.local/share/Steam
fi
if [ ! -f "/storage/.local/share/fex-emu/RootFS/ArchLinux.sqsh" ]; then
     echo "FEX needs to download rootfs before starting Steam. This may take a while..."
     FEXRootFSFetcher --distro-name=arch --distro-version=rolling -y -x
fi
cp -f "/usr/share/fex-emu/libvulkan_freedreno.so" "/storage/.local/share/fex-emu/RootFS/ArchLinux/usr/lib"
touch ".local/share/applications/Steam.desktop"
mkdir -p /storage/roms/steam
ln -sf "/storage/roms/steam" "/storage/.local/share/Steam"

#steam-arm
if [ ! -d "/storage/.local/share/Steam/steam-runtime-steamrt-arm64" ]; then
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
fi

mkdir -p "/storage/.local/share/Steam/steamapps/common/Proton 11.0 (ARM64)/"
cp -f "/usr/share/steam/toolmanifest.vdf" "/storage/.local/share/Steam/steamapps/common/Proton 11.0 (ARM64)/"
cp -f "/usr/share/steam/registry.vdf" "/storage/.steam"
echo 0 > /proc/sys/fs/binfmt_misc/x86_64
echo 0 > /proc/sys/fs/binfmt_misc/x86
if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
  swaymsg 'seat seat1 fallback true'
fi
FEX /usr/bin/steam -steamdeck -exitsteam
FEX /usr/bin/steam -steamdeck -exitsteam
LD_LIBRARY_PATH=/storage/.local/share/Steam/lib/aarch64-linux-gnu/ /storage/.local/share/Steam/steamrtarm64/steam -steamdeck -exitsteam
if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
  swaymsg 'seat seat1 fallback false'
fi
systemctl restart systemd-binfmt
echo "\n"
echo "Steam installed successfully. You can now start it from EmulationStation from Steam section"
sleep 10