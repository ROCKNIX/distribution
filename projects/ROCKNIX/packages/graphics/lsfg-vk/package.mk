# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="lsfg-vk"
PKG_VERSION="8b0da2661c6f3473a7fccc8ba643880050e71642"
PKG_LICENSE="GPL-3.0"
PKG_SITE="https://github.com/PancakeTAS/lsfg-vk"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_HOST="toolchain:host vulkan-headers:host"
PKG_DEPENDS_TARGET="toolchain ${VULKAN} lsfg-vk:host"
PKG_LONGDESC="Lossless Scaling Frame Generation Vulkan layer for Linux."
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                           -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
                           -DLSFGVK_BUILD_UI=OFF \
                           -DLSFGVK_BUILD_CLI=OFF \
                           -DLSFGVK_INSTALL_DEVELOP=OFF \
                           -DLSFGVK_INSTALL_XDG_FILES=OFF \
                           -DLSFGVK_LAYER_LIBRARY_PATH=/usr/lib/liblsfg-vk-layer.so"
}

pre_configure_host() {
  PKG_CMAKE_OPTS_HOST+=" -DCMAKE_BUILD_TYPE=Release \
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

  if ! grep -q '"enable_environment"' ${INSTALL}/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json; then
    sed -i '/"disable_environment"/i\    "enable_environment": { "LSFGVK_ENV": "1" },' \
      ${INSTALL}/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json
  fi

  mkdir -p ${INSTALL}/usr/lib/pressure-vessel/overrides/share/vulkan/implicit_layer.d
    cp ${INSTALL}/usr/share/vulkan/implicit_layer.d/VkLayer_LSFGVK_frame_generation.json \
       ${INSTALL}/usr/lib/pressure-vessel/overrides/share/vulkan/implicit_layer.d

  mkdir -p ${INSTALL}/usr/share/fex-emu
    cp -a ${TOOLCHAIN}/lib/liblsfg-vk-layer.so ${INSTALL}/usr/share/fex-emu
}


