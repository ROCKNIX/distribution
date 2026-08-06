# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="lsfg-vk"
PKG_VERSION="8b0da2661c6f3473a7fccc8ba643880050e71642"
PKG_LICENSE="GPL-3.0"
PKG_SITE="https://github.com/PancakeTAS/lsfg-vk"
PKG_URL="${PKG_SITE}.git"
PKG_GIT_CLONE_BRANCH="develop"
PKG_DEPENDS_TARGET="toolchain ${VULKAN}"
PKG_LONGDESC="Lossless Scaling Frame Generation Vulkan layer for Linux."
GET_HANDLER_SUPPORT="git"
PKG_TOOLCHAIN="cmake"

post_unpack() {
  cd ${PKG_BUILD}
  git submodule update --init --recursive
}

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                           -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
                           -DLSFGVK_BUILD_UI=OFF \
                           -DLSFGVK_BUILD_CLI=OFF \
                           -DLSFGVK_INSTALL_DEVELOP=OFF \
                           -DLSFGVK_INSTALL_XDG_FILES=OFF \
                           -DLSFGVK_LAYER_LIBRARY_PATH=/usr/lib/liblsfg-vk-layer.so"
}

makeinstall_target() {
  cd ${PKG_BUILD}/.${TARGET_NAME}
  DESTDIR="${INSTALL}" ninja install
  mkdir -p "${INSTALL}/usr/lib/pressure-vessel/overrides/share/vulkan/implicit_layer.d"
  cp "${INSTALL}/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json" \
     "${INSTALL}/usr/lib/pressure-vessel/overrides/share/vulkan/implicit_layer.d/"
}


