# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="lrps2-lr"
PKG_VERSION="f3c8743d6a42fe429f703b476fecfdb5655a98a9"
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain alsa-lib freetype zlib libpng libaio libsamplerate libfmt libpcap soundtouch yamlcpp wxwidgets"
PKG_SITE="https://github.com/libretro/LRPS2"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Hard fork / port of PCSX2. Will target only Libretro specifically."

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER}"
fi

PKG_CMAKE_OPTS_TARGET=" \
                        -DSDL2_API=TRUE \
                        -DDISABLE_PCSX2_WRAPPER=1 \
                        -DPACKAGE_MODE=FALSE \
                        -DPCSX2_TARGET_ARCHITECTURES=x86_64 \
                        -DENABLE_TESTS=OFF \
                        -DEXTRA_PLUGINS=OFF \
                        -DQT_BUILD=FALSE \
                        -DBUILD_SHARED_LIBS=OFF \
                        -DUSE_SYSTEM_LIBS=OFF \
                        -DDISABLE_ADVANCE_SIMD=ON \
                        -DUSE_VTUNE=OFF \
                        -DUSE_VULKAN=ON \
			-DGTK3_API=FALSE \
                        -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=FALSE \
                        -DCMAKE_BUILD_TYPE=Release"

pre_configure_target() {
  export LDFLAGS="${LDFLAGS} -laio"
  # Fixes for GCC 13, thanks to Arch <https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=libretro-lrps2-git#n50>
  sed -i '/include <vector>/a #include <string>' ${PKG_BUILD}/pcsx2/CDVD/CDVDdiscReader.h
  sed -i '/include <thread>/a #include <system_error>' ${PKG_BUILD}/pcsx2/CDVD/CDVDdiscThread.cpp
  sed -i '/include <vector>/a #include <cstdint>' ${PKG_BUILD}/pcsx2/MemoryPatchDatabase.h
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/.${TARGET_NAME}/pcsx2/pcsx2_libretro.so ${INSTALL}/usr/lib/libretro/
}
