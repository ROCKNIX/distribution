# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="libplacebo"
PKG_VERSION="05ac2cca6571c04d06369a26825d207781b73f32"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://code.videolan.org/videolan/libplacebo"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain ffmpeg SDL2 luajit libass"
PKG_LONGDESC="The core rendering algorithms and ideas of mpv rewritten as an independent library."

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN} glslang spirv-tools"
  PKG_MESON_OPTS_TARGET+=" -Dvulkan=enabled -Dglslang=enabled"
else
  PKG_MESON_OPTS_TARGET+=" -Dvulkan=disabled -Dglslang=disabled"
fi

pre_configure_target() {
  if [ "${VULKAN_SUPPORT}" = "yes" ]; then
    # meson does not automatically link libglslang
    export TARGET_LDFLAGS="${LDFLAGS} -lglslang -lSPIRV-Tools-opt -lSPIRV-Tools"
  fi
}

