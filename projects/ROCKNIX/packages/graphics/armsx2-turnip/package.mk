# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="armsx2-turnip"
PKG_VERSION="axfl1-011"
PKG_SHA256="b3c888b40587f0d30513709f6c5ae6f0171da4279bbf77d17511a0fb317560fa"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/bmdhacks/armsx2-turnip"
PKG_URL="${PKG_SITE}/releases/download/${PKG_VERSION}/turnip-${PKG_VERSION}-aarch64.tar.gz"
PKG_SOURCE_DIR="turnip/${PKG_VERSION}"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Prebuilt Mesa Turnip (Adreno 6xx/7xx Vulkan) with ARMSX2's fixes, loaded only by ARMSX2."
PKG_TOOLCHAIN="manual"
# Keep the release binary byte-identical, so its sha256 identifies it on device
PKG_BUILD_FLAGS="-strip"

# Installed beside ARMSX2, not over the system Mesa. start_armsx2.sh points the
# Vulkan loader at this ICD for the emulator process only.
TURNIP_DIR="/usr/share/armsx2-sa/turnip"

makeinstall_target() {
  mkdir -p ${INSTALL}${TURNIP_DIR}
    cp -a ${PKG_BUILD}/libvulkan_freedreno.so ${INSTALL}${TURNIP_DIR}

  # The release's manifest names its /storage staging path; write one for ours.
  ICD_API_VERSION=$(sed -n 's/.*"api_version": *"\([^"]*\)".*/\1/p' ${PKG_BUILD}/freedreno_icd.aarch64.json)
  cat >${INSTALL}${TURNIP_DIR}/freedreno_icd.aarch64.json <<ICD
{
    "ICD": {
        "api_version": "${ICD_API_VERSION}",
        "library_arch": "64",
        "library_path": "${TURNIP_DIR}/libvulkan_freedreno.so"
    },
    "file_format_version": "1.0.1"
}
ICD
}
