# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="vulkan-wsi-layer"
PKG_VERSION="40cfec09d0e2d42c5e1f2642cf4cba11e7008112"
PKG_SHA256="43954274b528086371a42bf74accd9e2d8a83a9613fc0833b26f257d882246fc"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ginkage/vulkan-wsi-layer"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libdrm wayland-protocols ${VULKAN}"
PKG_DEPENDS_UNPACK="linux"
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
        -DBUILD_WSI_HEADLESS=OFF \
        -DBUILD_WSI_WAYLAND=ON \
        -DBUILD_WSI_DISPLAY=OFF \
        -DBUILD_WSI_X11=OFF \
        -DSELECT_EXTERNAL_ALLOCATOR=dma_buf_heaps \
        -DWSIALLOC_MEMORY_HEAP_NAME=${HEAP_NAME} \
        -DENABLE_WAYLAND_FIFO_PRESENTATION_THREAD=ON \
        -DKERNEL_HEADER_DIR=$(get_build_dir linux)/arch/${INCLUDE_ARCH}/include \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5"
}

makeinstall_target() {
  # Install to arch libdirs using a bare soname manifest.
  mkdir -p ${INSTALL}/usr/lib
  cp -r ${PKG_BUILD}/.${TARGET_NAME}/libVkLayer_window_system_integration.so ${INSTALL}/usr/lib/
  mkdir -p ${INSTALL}/usr/share/vulkan/implicit_layer.d
  cp -r ${PKG_BUILD}/.${TARGET_NAME}/VkLayer_window_system_integration.json ${INSTALL}/usr/share/vulkan/implicit_layer.d
}
