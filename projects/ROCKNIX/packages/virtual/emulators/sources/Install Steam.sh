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
RUNTIME_TAR_BASE="https://repo.steampowered.com/steamrt3c/images"
RUNTIME_TAR_VERSION_URL="${RUNTIME_TAR_BASE}/latest-public-stable.txt"
STEAM_MANIFEST_URL="https://client-update.fastly.steamstatic.com/steam_client_publicbeta_linuxarm64"
STEAM_CDN="https://client-update.steamstatic.com"
PROTON_CACHYOS_RELEASE_API="https://api.github.com/repos/CachyOS/proton-cachyos/releases/latest"
PROTON_GE_RELEASE_API="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"
unset MESA_LOADER_DRIVER_OVERRIDE

# --- Logging & Error Handling Helpers ---
log_info() { echo -e "[\033[1;34mINFO\033[0m] $1"; }
log_success() { echo -e "[\033[1;32mSUCCESS\033[0m] $1"; sleep 10; exit 0; }
die() { echo -e "[\033[1;31mERROR\033[0m] $1" >&2; sleep 10; exit 1; }
# ----------------------------------------

fetch_proton_latest_release() {
  local api_url="$1"
  local asset_pattern="$2"
  local tag_prefix_to_strip="$3"
  local var_prefix="$4"
  local display_name="$5"

  log_info "Fetching latest ${display_name} release from GitHub..."

  local release_json
  release_json=$(curl -fsSL "${api_url}") || die "Failed to fetch ${display_name} latest release info."

  # Extract tag name
  local version_tag
  version_tag=$(echo "${release_json}" | grep -oP '"tag_name":\s*"\K[^"]+' | head -n 1) || die "Failed to parse ${display_name} version tag."
  [ -n "${version_tag}" ] || die "${display_name} version tag is empty."

  # Extract download URL for specified asset pattern, excluding checksums
  local download_url
  download_url=$(echo "${release_json}" | grep -oP '"browser_download_url":\s*"\K[^"]*'"${asset_pattern}"'[^"]*' | grep -v '\.sha512sum' | head -n 1) || die "Failed to parse ${display_name} download URL."
  [ -n "${download_url}" ] || die "Could not find ${asset_pattern} asset in ${display_name} release."

  # Extract filename from URL
  local tar_name
  tar_name=$(basename "${download_url}") || die "Failed to extract ${display_name} filename."
  [ -n "${tar_name}" ] || die "${display_name} filename is empty."

  local version_clean="${version_tag}"
  if [ -n "${tag_prefix_to_strip}" ]; then
    version_clean="${version_tag#${tag_prefix_to_strip}}"
  fi

  # Infer directory name based on tar filename
  local dir_name
  dir_name=$(echo "${tar_name}" | sed 's/\.[^.]*$//' | sed 's/\.[^.]*$//')  # Remove .tar.xz or .tar.gz

  # Set global variables dynamically
  eval "${var_prefix}_VERSION_FULL='${version_clean}'"
  eval "${var_prefix}_TAR='${tar_name}'"
  eval "${var_prefix}_DIR='${dir_name}'"
  eval "${var_prefix}_URL='${download_url}'"

  log_info "${display_name} latest version: ${version_clean}"
  log_info "${display_name} download URL: ${download_url}"
}

install_fex_config() {
  log_info "Installing FEX config..."
  cp -r "/usr/config/fex-emu" "/storage/.config/" || die "Failed to copy FEX config."
}

ensure_fex_rootfs() {
  rm -rf ${FEX_DATA}/RootFS/ArchLinux* || die "Failed to remove existing FEX RootFS."

  if [ ! -d "${FEX_DATA}/RootFS/ArchLinux" ]; then
    log_info "FEX needs to download rootfs before starting Steam. This may take a while..."
    FEXRootFSFetcher --distro-name=arch --distro-version=rolling -y -x || die "Failed to fetch FEX RootFS."
    rm -rf ${FEX_DATA}/RootFS/ArchLinux.sqsh || die "Failed to remove FEX RootFS sqsh."
  fi

  cp -f "/usr/lib/liblsfg-vk-layer.so" "${FEX_ARCH_USR_LIB}"  || die "Failed to copy liblsfg-vk-layer.so."
  cp -f "/usr/share/fex-emu/liblsfg-vk-layer-x86.so" "${FEX_ARCH_USR_LIB}"  || die "Failed to copy liblsfg-vk-layer-x86.so."
  cp -f "/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json" \
     "${FEX_ARCH_ROOT}/usr/share/vulkan/implicit_layer.d/" || die "Failed to copy VkLayer_LSFGVK_frame_generation.json to ArchLinux rootfs."
  cp -f "/usr/share/fex-emu/VkLayer_LSFGVK_frame_generation-x86.json" \
     "${FEX_ARCH_ROOT}/usr/share/vulkan/implicit_layer.d/" || die "Failed to copy VkLayer_LSFGVK_frame_generation-x86.json to ArchLinux rootfs."
  sed -i 's/"name": "VK_LAYER_LSFGVK_frame_generation"/"name": "VK_LAYER_LSFGVK_frame_generation_x86"/' "${FEX_ARCH_ROOT}/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation-x86.json"
  sed -i 's|"library_path": "/usr/lib/libvulkan_freedreno.so"|"library_path": "libvulkan_freedreno.so"|' \
    ${FEX_ARCH_ROOT}/usr/share/vulkan/icd.d/freedreno_icd.x86_64.json
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

  local runtime_version
  runtime_version=$(curl -fsSL "${RUNTIME_TAR_VERSION_URL}" | tr -d '[:space:]') || die "Failed to fetch Steam runtime version."
  [ -n "${runtime_version}" ] || die "Steam runtime version string is empty."
  local RUNTIME_TAR_URL="${RUNTIME_TAR_BASE}/${runtime_version}/steam-runtime-steamrt-arm64.tar.xz"
  log_info "Steam runtime URL: ${RUNTIME_TAR_URL}"

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

  target=$(echo "${STEAM}"/steam-runtime-steamrt-arm64/steamrt3c_platform_*/files/lib/aarch64-linux-gnu/libva.so.2.* | head -n 1)
  if [ ! -f "$target" ]; then
      die "Could not locate libva target inside runtime."
    fi
  ln -sf "${target}" "${STEAM}/lib/aarch64-linux-gnu/libva.so.2" || die "Failed to symlink libva."
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
}

install_bundled_proton_files() {
  log_info "Installing bundled Proton files..."
  cp -f "/usr/share/steam/registry.vdf" "${STEAM_DOT}" || die "Failed to copy registry.vdf."
}

install_proton_variant() {
  local display_name="$1"
  local url="$2"
  local tar_name="$3"
  local dir_name="$4"
  local cleanup_glob="$5"

  local dest_dir="${STEAM}/compatibilitytools.d"
  local tar_path="${dest_dir}/${tar_name}"
  local extracted_dir="${dest_dir}/${dir_name}"
  local manifest_file="${extracted_dir}/toolmanifest.vdf"

  if [ -d "${dest_dir}" ]; then
    for old_dir in "${dest_dir}"/${cleanup_glob}; do
      [ -d "${old_dir}" ] || continue
      if [ "${old_dir}" != "${extracted_dir}" ]; then
        log_info "Removing old ${display_name}: $(basename "${old_dir}")"
        rm -rf "${old_dir}"
      fi
    done
  fi

  if [ -d "${extracted_dir}" ]; then
    log_info "${display_name} already installed. Skipping download."
    return 0
  fi

  log_info "Downloading and installing ${display_name}..."
  mkdir -p "${dest_dir}"
  wget -c -t 5 -O "${tar_path}" "$url" || die "Failed to download ${display_name}."
  tar -xvf "${tar_path}" -C "${dest_dir}" || die "Failed to extract ${display_name}."
  rm -f "${tar_path}"
}

install_proton_cachyos() {
  install_proton_variant \
    "Proton-CachyOS" \
    "${PROTON_CACHYOS_URL}" \
    "${PROTON_CACHYOS_TAR}" \
    "${PROTON_CACHYOS_DIR}" \
    "proton-cachyos-*-arm64"
}

install_proton_ge() {
  install_proton_variant \
    "Proton-GE" \
    "${PROTON_GE_URL}" \
    "${PROTON_GE_TAR}" \
    "${PROTON_GE_DIR}" \
    "GE-Proton*-aarch64"
}

run_steam_first_launch() {
  log_info "Running Steam first launch routine..."
  echo 0 > /proc/sys/fs/binfmt_misc/x86 || true
  echo 0 > /proc/sys/fs/binfmt_misc/box32 || true
  echo 0 > /proc/sys/fs/binfmt_misc/box64 || true

  if [ "${DEVICE_HAS_DUAL_SCREEN}" = "true" ]; then
    swaymsg 'seat seat1 fallback true' || log_info "Swaymsg dual screen setup failed, ignoring."
  fi

  # Allow Steam launch commands to fail cleanly if needed, though they shouldn't
  LD_LIBRARY_PATH="${STEAM}/lib/aarch64-linux-gnu/" "${CLIENT_DIR}/steam" -deckard -exitsteam || log_info "Native Steam execution exited with an error."

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
fetch_proton_latest_release "${PROTON_CACHYOS_RELEASE_API}" "arm64" "cachyos-" "PROTON_CACHYOS" "Proton-CachyOS"
install_proton_cachyos
fetch_proton_latest_release "${PROTON_GE_RELEASE_API}" "aarch64" "" "PROTON_GE" "Proton-GE"
install_proton_ge
run_steam_first_launch

echo ""
log_success "Steam installed successfully. You can now start it from EmulationStation from the Steam section."
