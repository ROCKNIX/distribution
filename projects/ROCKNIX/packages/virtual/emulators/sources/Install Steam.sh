#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

source /etc/profile
set_kill set "-9 steam FEX"

STEAM="${STEAM:-/storage/.local/share/Steam}"
STEAM_GAMES_ROOT="${STEAM_GAMES_ROOT:-/storage/games-internal/roms/steam}"
STEAM_DOT="${STEAM_DOT:-/storage/.steam}"
APPLICATIONS="${APPLICATIONS:-/storage/.local/share/applications}"
FEX_DATA="/storage/.local/share/fex-emu"
FEX_ARCH_ROOT="${FEX_DATA}/RootFS/ArchLinux"
FEX_ARCH_USR_LIB="${FEX_ARCH_ROOT}/usr/lib"
RUNTIME_DIR="${STEAM}/steam-runtime-steamrt-arm64"
CLIENT_DIR="${STEAM}/steamrtarm64"
PROTON_NAME="Proton 11.0 (ARM64)"
PROTON_DIR="${STEAM}/steamapps/common/${PROTON_NAME}"
RUNTIME_TAR_URL="https://repo.steampowered.com/steamrt3c/images/latest-public-beta/steam-runtime-steamrt-arm64.tar.xz"
STEAM_MANIFEST_URL="https://client-update.fastly.steamstatic.com/steam_client_publicbeta_linuxarm64"
STEAM_CDN="https://client-update.steamstatic.com"
PROTON_CACHYOS_VERSION_FULL="11.0-20260506-slr"
PROTON_CACHYOS_TAR="proton-cachyos-${PROTON_CACHYOS_VERSION_FULL}-arm64.tar.xz"
PROTON_CACHYOS_DIR="proton-cachyos-${PROTON_CACHYOS_VERSION_FULL}-arm64"
PROTON_CACHYOS_URL="https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${PROTON_CACHYOS_VERSION_FULL}/${PROTON_CACHYOS_TAR}"
unset MESA_LOADER_DRIVER_OVERRIDE

install_fex_config() {
  cp -r "/usr/config/fex-emu" "/storage/.config/"
}

ensure_fex_rootfs() {
  if [ ! -f "${FEX_DATA}/RootFS/ArchLinux.sqsh" ]; then
    echo "FEX needs to download rootfs before starting Steam. This may take a while..."
    FEXRootFSFetcher --distro-name=arch --distro-version=rolling -y -x
  fi
  cp -f "/usr/share/fex-emu/libvulkan_freedreno.so" "${FEX_ARCH_USR_LIB}"
}

link_steam_library() {
  if [ -d "${STEAM}" ] && [ ! -L "${STEAM}" ]; then
    rm -rf "${STEAM}"
  fi
  mkdir -p "${STEAM_GAMES_ROOT}"
  ln -sfn "${STEAM_GAMES_ROOT}" "${STEAM}"
}

ensure_steam_desktop_stub() {
  mkdir -p "${APPLICATIONS}"
  touch "${APPLICATIONS}/Steam.desktop"
}

install_steam_runtime_arm64() {
  if [ -d "${RUNTIME_DIR}" ]; then
    return 0
  fi
  local tar_path="${STEAM}/steam-runtime-steamrt-arm64.tar.xz"
  wget -c -t 5 -O "${tar_path}" "${RUNTIME_TAR_URL}"
  tar xvf "${tar_path}" -C "${STEAM}"
  rm -f "${tar_path}"
  local target
  target=$(echo "${STEAM}"/steam-runtime-steamrt-arm64/steamrt3c_platform_*/files/lib/aarch64-linux-gnu/libibus-1.0.so.5.*)
  mkdir -p "${STEAM}/lib/aarch64-linux-gnu"
  ln -sf "${target}" "${STEAM}/lib/aarch64-linux-gnu/libibus-1.0.so.5"
}

install_steam_client_arm64() {
  if [ -d "${CLIENT_DIR}" ]; then
    return 0
  fi
  local manifest target_file zip_path
  manifest=$(curl -fsSL "${STEAM_MANIFEST_URL}" | strings)
  target_file=$(echo "${manifest}" | grep -oP 'bins_linuxarm64_linuxarm64\.zip\.(?!vz\.)[^"]+')
  zip_path="${STEAM}/linuxarm64.zip"
  wget -c -t 5 -O "${zip_path}" "${STEAM_CDN}/${target_file}"
  unzip -o "${zip_path}" -d "${STEAM}"
  rm -f "${zip_path}"
  chmod +x "${CLIENT_DIR}/steam"
  mkdir -p "${STEAM}/package"
  echo publicbeta > "${STEAM}/package/beta"
  mkdir -p "${STEAM_DOT}"
  ln -sfn "${STEAM}" "${STEAM_DOT}/steam"
  ln -sfn "${STEAM}/linuxarm64" "${STEAM_DOT}/sdkarm64"
  mkdir -p "${STEAM}/compatibilitytools.d/"
  ln -sfn "${PROTON_DIR}/" "${STEAM}/compatibilitytools.d/Proton11ARM"
  cp -f "/usr/share/steam/compatibilitytool.vdf" "${STEAM}/compatibilitytools.d/"
}

install_bundled_proton_files() {
  mkdir -p "${STEAM_DOT}" "${PROTON_DIR}/"
  cp -f "/usr/share/steam/toolmanifest.vdf" "${PROTON_DIR}/"
  cp -f "/usr/share/steam/registry.vdf" "${STEAM_DOT}"
}

install_proton_cachyos() {
  local url="$PROTON_CACHYOS_URL"
  local dest_dir="${STEAM}/compatibilitytools.d"
  local tar_path="${dest_dir}/${PROTON_CACHYOS_TAR}"
  local extracted_dir="${dest_dir}/${PROTON_CACHYOS_DIR}"
  local manifest_file="${extracted_dir}/toolmanifest.vdf"
  if [ -d "${extracted_dir}" ]; then
    echo "Proton-CachyOS already installed. Skipping download."
    return 0
  fi
  mkdir -p "${dest_dir}"
  wget -c -t 5 -O "${tar_path}" "$url"
  tar -xvf "${tar_path}" -C "${dest_dir}"
  rm -f "${tar_path}"
  if [ -f "${manifest_file}" ]; then
    sed -i '/require_tool_appid/d' "${manifest_file}"
  fi
}

run_steam_first_launch() {
  echo 0 > /proc/sys/fs/binfmt_misc/x86_64
  echo 0 > /proc/sys/fs/binfmt_misc/x86
  if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
    swaymsg 'seat seat1 fallback true'
  fi
  FEX /usr/bin/steam -steamdeck -exitsteam
  FEX /usr/bin/steam -steamdeck -exitsteam
  LD_LIBRARY_PATH="${STEAM}/lib/aarch64-linux-gnu/" "${CLIENT_DIR}/steam" -steamdeck -exitsteam
  if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
    swaymsg 'seat seat1 fallback false'
  fi
  systemctl restart systemd-binfmt
}

install_fex_config
ensure_fex_rootfs
link_steam_library
ensure_steam_desktop_stub
install_steam_runtime_arm64
install_steam_client_arm64
install_bundled_proton_files
install_proton_cachyos
run_steam_first_launch

echo ""
echo "Steam installed successfully. You can now start it from EmulationStation from Steam section"
sleep 10
