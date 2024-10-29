# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019 Trond Haugland (trondah@gmail.com)

PKG_NAME="mame-lr"
PKG_VERSION="8b9b8f5f5b47161327d93522318c81fba2087b2f"
PKG_LICENSE="GPLv2"
PKG_SITE="https://github.com/libretro/mame"
PKG_URL="https://github.com/libretro/mame/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain zlib flac sqlite expat"
PKG_LONGDESC="MAME - Multiple Arcade Machine Emulator"
PKG_TOOLCHAIN="make"
PKG_BUILD_FLAGS="-lto +pic"

case ${TARGET_ARCH} in
  arm|aarch64)
    MAME_PLATFORM="PLATFORM=arm64"
    CROSS_BUILD="1"
    PTR64=0
  ;;
  *)
    CROSS_BUILD="0"
    PTR64=1
  ;;
esac

PKG_MAKE_OPTS_TARGET="REGENIE=1 \
		      VERBOSE=1 \
		      NOWERROR=1 \
		      OPENMP=1 \
		      CROSS_BUILD=${CROSS_BUILD} \
		      TOOLS=0 \
		      RETRO=1 \
		      PTR64=${PTR64} \
		      NOASM=0 \
		      PYTHON_EXECUTABLE=python3 \
		      CONFIG=libretro \
		      LIBRETRO_OS=unix \
		      LIBRETRO_CPU= \
		      ${MAME_PLATFORM} \
		      ARCH= \
		      TARGET=mame \
		      SUBTARGET=mame \
		      OSD=retro \
		      USE_SYSTEM_LIB_EXPAT=1 \
		      USE_SYSTEM_LIB_ZLIB=1 \
		      USE_SYSTEM_LIB_FLAC=1 \
		      USE_SYSTEM_LIB_SQLITE3=1"

pre_configure_target() {
  sed -i "s/-static-libstdc++//g" scripts/genie.lua
}

make_target() {
  unset ARCH
  unset DISTRO
  unset PROJECT
  if [ "${PLATFORM}" = "arm64" ]
  then
    export ARCHOPTS="-D__aarch64__ -DASMJIT_BUILD_X86"
  fi
  make ${PKG_MAKE_OPTS_TARGET} OVERRIDE_CC=${CC} OVERRIDE_CXX=${CXX} OVERRIDE_LD=$LD AR=${AR} ${MAKEFLAGS}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp *.so ${INSTALL}/usr/lib/libretro/mame_libretro.so
  mkdir -p ${INSTALL}/usr/config/retroarch/savefiles/mame/hi
  cp plugins/hiscore/hiscore.dat ${INSTALL}/usr/config/retroarch/savefiles/mame/hi
}
