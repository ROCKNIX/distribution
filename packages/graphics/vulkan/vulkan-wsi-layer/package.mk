# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vulkan-wsi-layer"
PKG_VERSION="cb1a50cf7e640ad7306e673131ded98c0f133628"
PKG_LICENSE="MIT"
PKG_SITE="https://gitlab.freedesktop.org/mesa/vulkan-wsi-layer"
PKG_URL="${PKG_SITE}/-/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain vulkan-loader vulkan-headers"
PKG_LONGDESC="Implements Vulkan extensions for Window System Integration inside a Vulkan layer."
PKG_TOOLCHAIN="cmake"

pre_configure_target() {
if [ "${DEVICE}" = "RK3588" ]; then
  #BSP name?, probably can be removed when moving to mainline
  HEAP_NAME=cma
else
  HEAP_NAME=linux,cma
fi

if [ "${ARCH}" = "aarch64" ]; then
  INCLUDE_ARCH=arm64
else
  INCLUDE_ARCH=${ARCH}
fi

PKG_CMAKE_OPTS_TARGET+=" -DVULKAN_CXX_INCLUDE=${SYSROOT_PREFIX}/usr \
        -DBUILD_WSI_HEADLESS=0 \
        -DBUILD_WSI_WAYLAND=1 \
        -DSELECT_EXTERNAL_ALLOCATOR=dma_buf_heaps \
		-DWSIALLOC_MEMORY_HEAP_NAME=${HEAP_NAME} \
        -DKERNEL_HEADER_DIR=$(get_build_dir linux)/arch/${INCLUDE_ARCH}/include"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/vulkan/implicit_layer.d
  cp -r ${PKG_BUILD}/.${TARGET_NAME}/libVkLayer_window_system_integration.so ${INSTALL}/usr/share/vulkan/
  cp -r ${PKG_BUILD}/.${TARGET_NAME}/VkLayer_window_system_integration.json ${INSTALL}/usr/share/vulkan/implicit_layer.d
}
