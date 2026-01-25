# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="mangohud"
PKG_VERSION="d7654ebcefb3bdb106d581c937417aa2007eaeeb" # v0.8.3-rc1 + a few fixes
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
  curl -Lo ${PKG_BUILD}/subprojects/vulkan-headers.tar.gz https://github.com/KhronosGroup/Vulkan-Headers/archive/v1.3.283.tar.gz
  tar -xvf ${PKG_BUILD}/subprojects/vulkan-headers.tar.gz -C ${PKG_BUILD}/subprojects/
  #curl -Lo ${PKG_BUILD}/subprojects/vulkan-headers_patch_1.3.283-1.zip https://wrapdb.mesonbuild.com/v2/vulkan-headers_1.3.283-1/get_patch
  #unzip -o ${PKG_BUILD}/subprojects/vulkan-headers_patch_1.3.283-1.zip -d ${PKG_BUILD}/subprojects
  unzip -o ${PKG_DIR}/meson-patches/vulkan-headers_patch_1.3.283-1.zip -d ${PKG_BUILD}/subprojects
  rm -rf ${PKG_BUILD}/subprojects/vulkan-headers.tar.gz
  rm -rf ${PKG_BUILD}/subprojects/vulkan-headers_patch_1.3.283-1.zip

  ### imgui
  curl -Lo ${PKG_BUILD}/subprojects/imgui.tar.gz https://github.com/ocornut/imgui/archive/refs/tags/v1.91.6.tar.gz
  tar -xvf ${PKG_BUILD}/subprojects/imgui.tar.gz -C ${PKG_BUILD}/subprojects/
  #curl -Lo ${PKG_BUILD}/subprojects/imgui_patch_1.91.6-3.zip https://wrapdb.mesonbuild.com/v2/imgui_1.91.6-3/get_patch
  #unzip -o ${PKG_BUILD}/subprojects/imgui_patch_1.91.6-3.zip -d ${PKG_BUILD}/subprojects
  unzip -o ${PKG_DIR}/meson-patches/imgui_patch_1.91.6-3.zip -d ${PKG_BUILD}/subprojects
  rm -rf ${PKG_BUILD}/subprojects/imgui.tar.gz
  rm -rf ${PKG_BUILD}/subprojects/imgui_patch_1.91.6-3.zip

  ### implot
  curl -Lo ${PKG_BUILD}/subprojects/implot.zip https://github.com/epezent/implot/archive/refs/tags/v0.16.zip
  unzip -o ${PKG_BUILD}/subprojects/implot.zip -d ${PKG_BUILD}/subprojects
  #curl -Lo ${PKG_BUILD}/subprojects/implot_patch_0.16-1.zip https://wrapdb.mesonbuild.com/v2/implot_0.16-1/get_patch
  #unzip -o ${PKG_BUILD}/subprojects/implot_patch_0.16-1.zip -d ${PKG_BUILD}/subprojects
  unzip -o ${PKG_DIR}/meson-patches/implot_patch_0.16-1.zip -d ${PKG_BUILD}/subprojects
  rm -rf ${PKG_BUILD}/subprojects/implot.zip
  rm -rf ${PKG_BUILD}/subprojects/implot_patch_0.16-1.zip

  ### spdlog
  curl -Lo ${PKG_BUILD}/subprojects/spdlog.tar.gz https://github.com/gabime/spdlog/archive/refs/tags/v1.14.1.tar.gz
  tar -xvf ${PKG_BUILD}/subprojects/spdlog.tar.gz -C ${PKG_BUILD}/subprojects/
  #curl -Lo ${PKG_BUILD}/subprojects/spdlog_patch_1.14.1-1.zip https://wrapdb.mesonbuild.com/v2/spdlog_1.14.1-1/get_patch
  #unzip -o ${PKG_BUILD}/subprojects/spdlog_patch_1.14.1-1.zip -d ${PKG_BUILD}/subprojects
  unzip -o ${PKG_DIR}/meson-patches/spdlog_patch_1.14.1-1.zip -d ${PKG_BUILD}/subprojects
  rm -rf ${PKG_BUILD}/subprojects/spdlog.tar.gz
  rm -rf ${PKG_BUILD}/subprojects/spdlog_patch_1.14.1-1.zip
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/sources/* ${INSTALL}/usr/bin
  chmod +x ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/MangoHud
  cp -rf ${PKG_DIR}/config/* ${INSTALL}/usr/config/MangoHud

  # Customize config per platform, eg set font size for display resolution
  case ${DEVICE} in
    RK3326)
      sed -e "s/@FONT_SIZE@/30/g" -i ${INSTALL}/usr/config/MangoHud/MangoHud.conf
    ;;
    S922X)
      sed -e "s/@FONT_SIZE@/30/g" -i ${INSTALL}/usr/config/MangoHud/MangoHud.conf

      # No GPU temperature sensor available
      sed -i 's/^gpu_temp/\# gpu_temp/g' ${INSTALL}/usr/config/MangoHud/MangoHud.conf
    ;;
    *)
      sed -e "s/@FONT_SIZE@/40/g" -i ${INSTALL}/usr/config/MangoHud/MangoHud.conf
    ;;
  esac
}
