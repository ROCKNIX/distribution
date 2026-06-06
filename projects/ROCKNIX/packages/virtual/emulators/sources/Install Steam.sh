#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

set -e
set -o pipefail

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
PROTON_CACHYOS_VERSION_FULL="11.0-20260521-slr"
PROTON_CACHYOS_TAR="proton-cachyos-${PROTON_CACHYOS_VERSION_FULL}-arm64.tar.xz"
PROTON_CACHYOS_DIR="proton-cachyos-${PROTON_CACHYOS_VERSION_FULL}-arm64"
PROTON_CACHYOS_URL="https://github.com/CachyOS/proton-cachyos/releases/download/cachyos-${PROTON_CACHYOS_VERSION_FULL}/${PROTON_CACHYOS_TAR}"
unset MESA_LOADER_DRIVER_OVERRIDE

# --- Logging & Error Handling Helpers ---
log_info() { echo -e "[\033[1;34mINFO\033[0m] $1"; }
log_success() { echo -e "[\033[1;32mSUCCESS\033[0m] $1"; sleep 10; exit 0; }
die() { echo -e "[\033[1;31mERROR\033[0m] $1" >&2; sleep 10; exit 1; }
# ----------------------------------------

install_fex_config() {
  log_info "Installing FEX config..."
  cp -r "/usr/config/fex-emu" "/storage/.config/" || die "Failed to copy FEX config."
}

ensure_fex_rootfs() {
  if [ ! -f "${FEX_DATA}/RootFS/ArchLinux.sqsh" ]; then
    log_info "FEX needs to download rootfs before starting Steam. This may take a while..."
    FEXRootFSFetcher --distro-name=arch --distro-version=rolling -y -x || die "Failed to fetch FEX RootFS."
  fi
  cp -f "/usr/share/fex-emu/libvulkan_freedreno.so" "${FEX_ARCH_USR_LIB}" || die "Failed to copy libvulkan_freedreno.so."
}

link_steam_library() {
  log_info "Linking Steam library..."
  if [ -d "${STEAM}" ] && [ ! -L "${STEAM}" ]; then
    rm -rf "${STEAM}" || die "Failed to remove existing Steam directory."
  fi
  mkdir -p "${STEAM_GAMES_ROOT}"
  ln -sfn "${STEAM_GAMES_ROOT}" "${STEAM}" || die "Failed to create Steam symlink."
}

ensure_steam_desktop_stub() {
  log_info "Ensuring Steam desktop stub exists..."
  mkdir -p "${APPLICATIONS}"
  touch "${APPLICATIONS}/Steam.desktop" || die "Failed to create Steam.desktop stub."
}

install_steam_runtime_arm64() {
  if [ -d "${RUNTIME_DIR}" ]; then
    log_info "Steam runtime already exists. Skipping."
    return 0
  fi
  log_info "Downloading and installing Steam runtime (ARM64)..."
  local tar_path="${STEAM}/steam-runtime-steamrt-arm64.tar.xz"

  wget -c -t 5 -O "${tar_path}" "${RUNTIME_TAR_URL}" || die "Failed to download Steam runtime."
  tar xvf "${tar_path}" -C "${STEAM}" || die "Failed to extract Steam runtime."
  rm -f "${tar_path}"

  local target
  target=$(echo "${STEAM}"/steam-runtime-steamrt-arm64/steamrt3c_platform_*/files/lib/aarch64-linux-gnu/libibus-1.0.so.5.* | head -n 1)
  if [ ! -f "$target" ]; then
      die "Could not locate libibus target inside runtime."
  fi

  mkdir -p "${STEAM}/lib/aarch64-linux-gnu"
  ln -sf "${target}" "${STEAM}/lib/aarch64-linux-gnu/libibus-1.0.so.5" || die "Failed to symlink libibus."
}

install_steam_client_arm64() {
  if [ -d "${CLIENT_DIR}" ]; then
    log_info "Steam client already exists. Skipping."
    return 0
  fi
  log_info "Downloading and installing Steam client (ARM64)..."
  local manifest target_file zip_path

  manifest=$(curl -fsSL "${STEAM_MANIFEST_URL}" | strings) || die "Failed to fetch Steam manifest."
  target_file=$(echo "${manifest}" | grep -oP 'bins_linuxarm64_linuxarm64\.zip\.(?!vz\.)[^"]+') || die "Failed to parse target file from manifest."
  zip_path="${STEAM}/linuxarm64.zip"

  wget -c -t 5 -O "${zip_path}" "${STEAM_CDN}/${target_file}" || die "Failed to download Steam client zip."
  unzip -o "${zip_path}" -d "${STEAM}" || die "Failed to extract Steam client."
  rm -f "${zip_path}"

  chmod +x "${CLIENT_DIR}/steam" || die "Failed to make Steam client executable."

  mkdir -p "${STEAM}/package"
  echo publicbeta > "${STEAM}/package/beta"
  mkdir -p "${STEAM_DOT}"
  ln -sfn "${STEAM}" "${STEAM_DOT}/steam" || die "Failed to symlink STEAM_DOT/steam."
  ln -sfn "${STEAM}/linuxarm64" "${STEAM_DOT}/sdkarm64" || die "Failed to symlink STEAM_DOT/sdkarm64."

  mkdir -p "${STEAM}/compatibilitytools.d/"
  ln -sfn "${PROTON_DIR}/" "${STEAM}/compatibilitytools.d/Proton11ARM" || die "Failed to symlink Proton11ARM."
  cp -f "/usr/share/steam/compatibilitytool.vdf" "${STEAM}/compatibilitytools.d/" || die "Failed to copy compatibilitytool.vdf."
}

install_bundled_proton_files() {
  log_info "Installing bundled Proton files..."
  mkdir -p "${STEAM_DOT}" "${PROTON_DIR}/"
  cp -f "/usr/share/steam/toolmanifest.vdf" "${PROTON_DIR}/" || die "Failed to copy toolmanifest.vdf."
  cp -f "/usr/share/steam/registry.vdf" "${STEAM_DOT}" || die "Failed to copy registry.vdf."
}

install_proton_cachyos() {
  local url="$PROTON_CACHYOS_URL"
  local dest_dir="${STEAM}/compatibilitytools.d"
  local tar_path="${dest_dir}/${PROTON_CACHYOS_TAR}"
  local extracted_dir="${dest_dir}/${PROTON_CACHYOS_DIR}"
  local manifest_file="${extracted_dir}/toolmanifest.vdf"

  if [ -d "${dest_dir}" ]; then
    for old_dir in "${dest_dir}"/proton-cachyos-*-arm64; do
      [ -d "${old_dir}" ] || continue
      if [ "${old_dir}" != "${extracted_dir}" ]; then
        log_info "Removing old Proton-CachyOS: $(basename "${old_dir}")"
        rm -rf "${old_dir}"
      fi
    done
  fi

  if [ -d "${extracted_dir}" ]; then
    log_info "Proton-CachyOS already installed. Skipping download."
    return 0
  fi

  log_info "Downloading and installing Proton-CachyOS..."
  mkdir -p "${dest_dir}"
  wget -c -t 5 -O "${tar_path}" "$url" || die "Failed to download Proton-CachyOS."
  tar -xvf "${tar_path}" -C "${dest_dir}" || die "Failed to extract Proton-CachyOS."
  rm -f "${tar_path}"

  if [ -f "${manifest_file}" ]; then
    sed -i '/require_tool_appid/d' "${manifest_file}" || die "Failed to patch toolmanifest.vdf."
  fi
}

run_steam_first_launch() {
  log_info "Running Steam first launch routine..."
  echo 0 > /proc/sys/fs/binfmt_misc/x86_64 || true
  echo 0 > /proc/sys/fs/binfmt_misc/x86 || true

  if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
    swaymsg 'seat seat1 fallback true' || log_info "Swaymsg dual screen setup failed, ignoring."
  fi

  # Allow FEX / Steam launch commands to fail cleanly if needed, though they shouldn't
  FEX /usr/bin/steam -steamdeck -exitsteam || log_info "First FEX execution exited with an error."
  FEX /usr/bin/steam -steamdeck -exitsteam || log_info "Second FEX execution exited with an error."
  LD_LIBRARY_PATH="${STEAM}/lib/aarch64-linux-gnu/" "${CLIENT_DIR}/steam" -steamdeck -exitsteam || log_info "Native Steam execution exited with an error."

  if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
    swaymsg 'seat seat1 fallback false' || log_info "Swaymsg dual screen teardown failed, ignoring."
  fi

  systemctl restart systemd-binfmt || die "Failed to restart systemd-binfmt."
}

# --- Execution ---
log_info "Starting Steam Installation Process..."

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
log_success "Steam installed successfully. You can now start it from EmulationStation from the Steam section."
