# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="libplacebo"
PKG_VERSION="52314e0e435fbcb731e326815d4091ed0ba27475"
PKG_LICENSE="GPLv2+"
PKG_SITE="https://code.videolan.org/videolan/libplacebo"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain ffmpeg SDL2 luajit libass glslang"
PKG_LONGDESC="The core rendering algorithms and ideas of mpv rewritten as an independent library."

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_MESON_OPTS_TARGET+=" -Dvulkan=enabled"
else
  PKG_MESON_OPTS_TARGET+=" -Dvulkan=disabled"
fi

pre_configure_target() {
  export TARGET_LDFLAGS="${LDFLAGS} -lglslang"
}
