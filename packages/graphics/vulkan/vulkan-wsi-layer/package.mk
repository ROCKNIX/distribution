# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vulkan-wsi-layer"
#PKG_VERSION="r51p0-00eac0"
PKG_VERSION="7e27d1d7"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.freedesktop.org/mesa/vulkan-wsi-layer"
PKG_URL="${PKG_SITE}.git"
#PKG_URL="https://developer.arm.com/-/media/Files/downloads/mali-drivers/WSI-Layer/VX501X08X-SW-99009-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Implements Vulkan extensions for Window System Integration inside a Vulkan layer."
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
#PKG_CMAKE_SCRIPT=${PKG_BUILD}/product/vulkan_wsi/tools/wsi_layer/CMakeLists.txt

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
fi

PKG_CMAKE_OPTS_TARGET+=" -DVULKAN_CXX_INCLUDE=${SYSROOT_PREFIX}/usr \
        -DBUILD_WSI_HEADLESS=0 \
        -DBUILD_WSI_WAYLAND=1 \
        -DSELECT_EXTERNAL_ALLOCATOR=ion
        -DKERNEL_DIR=$(get_build_dir linux)"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/vulkan/implicit_layer.d
  cp -r ${PKG_BUILD}/.${TARGET_NAME}/libVkLayer_window_system_integration.so ${INSTALL}/usr/share/vulkan/
  cp -r ${PKG_BUILD}/.${TARGET_NAME}/VkLayer_window_system_integration.json ${INSTALL}/usr/share/vulkan/implicit_layer.d
}
