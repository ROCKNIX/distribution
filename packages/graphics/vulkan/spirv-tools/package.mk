# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Frank Hartung (supervisedthinking (@) gmail.com)
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="spirv-tools"
# The SPIRV-Tools pkg_version needs to match the compatible (known_good) glslang pkg_version.
# https://raw.githubusercontent.com/KhronosGroup/glslang/${PKG_VERSION}/known_good.json
# When updating glslang pkg_version please update to the known_good spirv-tools pkg_version.
PKG_VERSION="0cfe9e7219148716dfd30b37f4d21753f098707a"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/KhronosGroup/SPIRV-Tools"
PKG_URL="https://github.com/KhronosGroup/SPIRV-Tools/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_UNPACK="spirv-headers"
PKG_LONGDESC="The SPIR-V Tools project provides an API and commands for processing SPIR-V modules."

post_unpack() {
  mkdir -p ${PKG_BUILD}/external/spirv-headers
    tar --strip-components=1 \
      -xf "${SOURCES}/spirv-headers/spirv-headers-$(get_pkg_version spirv-headers).tar.gz" \
      -C "${PKG_BUILD}/external/spirv-headers"
}
