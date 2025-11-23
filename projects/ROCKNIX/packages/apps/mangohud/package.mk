# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mangohud"
PKG_VERSION="f60524b9d31261f6ffdc57cd27687f3b76d64301"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/flightlessmango/MangoHud"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain glslang mesa Python3 wayland libxcb dbus"
PKG_LONGDESC="A Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more."
PKG_PATCH_DIRS+="${DEVICE}"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
fi

pre_configure_target() {
  PKG_MESON_OPTS_TARGET+=" -Dwith_xnvctrl=disabled \
                           -Dwith_x11=enabled \
                           -Dmangoplot=disabled \
                           -Dwith_wayland=enabled"

  # Download Sub Modules
  mkdir -p ${PKG_BUILD}/subprojects/

  ### vulkan-headers
  curl -Lo ${PKG_BUILD}/subprojects/vulkan-headers.tar.gz https://github.com/KhronosGroup/Vulkan-Headers/archive/v1.2.158.tar.gz
  tar -xvf ${PKG_BUILD}/subprojects/vulkan-headers.tar.gz -C ${PKG_BUILD}/subprojects/
  curl -Lo ${PKG_BUILD}/subprojects/vulkan-headers_patch.zip https://wrapdb.mesonbuild.com/v2/vulkan-headers_1.2.158-2/get_patch
  unzip -o ${PKG_BUILD}/subprojects/vulkan-headers_patch.zip -d ${PKG_BUILD}/subprojects
  rm -rf ${PKG_BUILD}/subprojects/vulkan-headers.tar.gz
  rm -rf ${PKG_BUILD}/subprojects/vulkan-headers_patches.zip

  ### imgui
  curl -Lo ${PKG_BUILD}/subprojects/imgui.tar.gz https://github.com/ocornut/imgui/archive/refs/tags/v1.89.9.tar.gz
  tar -xvf ${PKG_BUILD}/subprojects/imgui.tar.gz -C ${PKG_BUILD}/subprojects/
  curl -Lo ${PKG_BUILD}/subprojects/imgui_patch.zip https://wrapdb.mesonbuild.com/v2/imgui_1.89.9-1/get_patch
  unzip -o ${PKG_BUILD}/subprojects/imgui_patch.zip -d ${PKG_BUILD}/subprojects
  rm -rf ${PKG_BUILD}/subprojects/imgui.tar.gz
  rm -rf ${PKG_BUILD}/subprojects/imgui_patches.zip

  ### implot
  curl -Lo ${PKG_BUILD}/subprojects/implot.zip https://github.com/epezent/implot/archive/refs/tags/v0.16.zip
  unzip -o ${PKG_BUILD}/subprojects/implot.zip -d ${PKG_BUILD}/subprojects
  curl -Lo ${PKG_BUILD}/subprojects/implot_patch.zip https://wrapdb.mesonbuild.com/v2/implot_0.16-1/get_patch
  unzip -o ${PKG_BUILD}/subprojects/implot_patch.zip -d ${PKG_BUILD}/subprojects
  rm -rf ${PKG_BUILD}/subprojects/implot.zip
  rm -rf ${PKG_BUILD}/subprojects/implot_patches.zip

  ### spdlog
  curl -Lo ${PKG_BUILD}/subprojects/spdlog.tar.gz https://github.com/gabime/spdlog/archive/refs/tags/v1.14.1.tar.gz
  tar -xvf ${PKG_BUILD}/subprojects/spdlog.tar.gz -C ${PKG_BUILD}/subprojects/
  curl -Lo ${PKG_BUILD}/subprojects/spdlog_patch.zip https://wrapdb.mesonbuild.com/v2/spdlog_1.14.1-1/get_patch
  unzip -o ${PKG_BUILD}/subprojects/spdlog_patch.zip -d ${PKG_BUILD}/subprojects
  rm -rf ${PKG_BUILD}/subprojects/spdlog.tar.gz
  rm -rf ${PKG_BUILD}/subprojects/spdlog_patches.zip
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/sources/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/MangoHud
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/MangoHud
}
