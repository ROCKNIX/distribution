# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rpcs3-sa"
PKG_VERSION="cd814f8263bf6bfcb60322c3461aa74dd8e34f66"
PKG_REV="1"
PKG_ARCH="any"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/RPCS3/rpcs3"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_SOURCE="rpcs3-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Mesa libglvnd ffmpeg libpng libjpeg-turbo zlib curl vulkan-loader vulkan-headers qt6-base qt6-declarative qt6-svg libX11 libXext libX11-xcb libxcb xcb-util xcb-util-keysyms xcb-util-wm xcb-util-cursor libXrender libXrandr libXi libxkbcommon ALSA pipewire openal-soft cubeb sdl2 rtmidi systemd hidapi Glew pugixml flatbuffers yaml-cpp xxhash ffmpeg"
PKG_PRIORITY="optional"
PKG_SECTION="emulators"
PKG_SHORTDESC="PlayStation 3 emulator"
PKG_LONGDESC="RPCS3 is an open-source PlayStation 3 emulator and debugger written in C++."

PKG_CMAKE_OPTS_TARGET="
  -DCMAKE_BUILD_TYPE=Release
  -DUSE_SYSTEM_LIBFFMPEG=ON
  -DUSE_SYSTEM_ZLIB=ON
  -DUSE_SYSTEM_LIBPNG=ON
  -DUSE_SYSTEM_CURL=ON
  -DUSE_SYSTEM_PUGIXML=ON
  -DUSE_SYSTEM_FLATBUFFERS=ON
  -DUSE_SYSTEM_YAMLCPP=ON
  -DUSE_SYSTEM_XXHASH=ON
  -DUSE_NATIVE_INSTRUCTIONS=OFF
  -DUSE_SYSTEM_FAUDIO=OFF
  -DUSE_VULKAN=ON
  -DUSE_AUDIO=ON
  -DUSE_ALSA=ON
  -DUSE_PULSE=OFF
  -DUSE_JACK=OFF
  -DUSE_SNDIO=OFF
  -DUSE_GUI=ON
  -DUSE_DISCORD_RPC=OFF
  -DBUILD_LLVM_FASTMATH=OFF
"

make_target() {
  cmake --build ${PKG_BUILD} --parallel ${TOOLCHAIN_NUM_JOBS}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp ${PKG_BUILD}/bin/rpcs3 ${INSTALL}/usr/bin/rpcs3-sa
}
