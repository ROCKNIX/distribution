# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="shaderc"
PKG_VERSION="2025.3"
PKG_SHA256="a8e4a25e5c2686fd36981e527ed05e451fcfc226bddf350f4e76181371190937"
PKG_LICENSE="Apache-2.0"
PKG_SITE="https://github.com/google/shaderc"
PKG_URL="${PKG_SITE}/archive/refs/tags/v${PKG_VERSION}.tar.gz"
PKG_LONGDESC="A collection of tools, libraries, and tests for Vulkan shader compilation."
PKG_DEPENDS_TARGET="toolchain glslang"
PKG_DEPENDS_UNPACK="spirv-headers"
PKG_TOOLCHAIN="cmake"

post_unpack() {
  mkdir -p ${PKG_BUILD}/external/spirv-headers
    tar --strip-components=1 \
      -xf "${SOURCES}/spirv-headers/spirv-headers-$(get_pkg_version spirv-headers).tar.gz" \
      -C "${PKG_BUILD}/external/spirv-headers"
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+="-DSHADERC_SKIP_TESTS=ON \
                       -DSHADERC_SKIP_EXAMPLES=ON \
                       -Dglslang_SOURCE_DIR=${SYSROOT_PREFIX}/usr/include/glslang \
                       -DSPIRV-Headers_SOURCE_DIR=${PKG_BUILD}/external/spirv-headers"

  mkdir -p ${PKG_BUILD}/glslc/src
  echo '"$(PKG_VERSION)\n"' > ${PKG_BUILD}/glslc/src/build-version.inc
  export TARGET_LDFLAGS="${LDFLAGS} -lglslang"
}
