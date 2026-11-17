# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="azahar-lr"
PKG_VERSION="219d743a1e698101fe1ab8bef43e6563126c3c27" # tag 2126.2
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/azahar-emu/azahar"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain llvm:host boost zlib zstd spirv-tools"
PKG_LONGDESC="Azahar Libretro, a Nintendo 3DS emulator core for RetroArch"
PKG_TOOLCHAIN="manual"

if [ ! "${OPENGL}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
fi

pre_configure_target() {
  for _v in CFLAGS CXXFLAGS LDFLAGS; do
    export ${_v}="$(echo ${!_v} | sed 's/-mabi=lp64//g; s/-mtune=[^ ]*//g')"
  done

  if [ "${PREFER_GLES}" = "yes" ]; then
    export CXXFLAGS="${CXXFLAGS} -DUSING_GLES"
  fi
}

make_target() {
  cmake -G Ninja \
        -S "${PKG_BUILD}" \
        -B "${PKG_BUILD}/.${TARGET_NAME}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_C_COMPILER="${TOOLCHAIN}/bin/clang" \
        -DCMAKE_CXX_COMPILER="${TOOLCHAIN}/bin/clang++" \
        -DCMAKE_AR="${TOOLCHAIN}/bin/llvm-ar" \
        -DCMAKE_RANLIB="${TOOLCHAIN}/bin/llvm-ranlib" \
        -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld" \
        -DCMAKE_SYSTEM_NAME=Linux \
        -DCMAKE_SYSTEM_PROCESSOR=${TARGET_ARCH} \
        -DCMAKE_C_COMPILER_TARGET=${TARGET_NAME} \
        -DCMAKE_CXX_COMPILER_TARGET=${TARGET_NAME} \
        -DCMAKE_SYSROOT="${SYSROOT_PREFIX}" \
        -DCMAKE_FIND_ROOT_PATH="${SYSROOT_PREFIX}" \
        -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
        -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
        -DENABLE_LIBRETRO=ON \
        -DENABLE_OPENGL=ON \
        -DENABLE_VULKAN=ON \
        -DENABLE_TESTS=OFF \
        -DENABLE_LTO=OFF \
        -DCITRA_WARNINGS_AS_ERRORS=OFF
  ninja -C "${PKG_BUILD}/.${TARGET_NAME}" ${NINJA_OPTS} citra_libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/bin/Release/azahar_libretro.so ${INSTALL}/usr/lib/libretro
}
