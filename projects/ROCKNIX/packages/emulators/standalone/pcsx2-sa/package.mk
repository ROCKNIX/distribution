# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="pcsx2-sa"
PKG_VERSION="fd9d310ccbb6b8b62c976da8886a3c8fd3a10ff3" # tag v2.8.2
PKG_GIT_TAG="v2.8.2"
PKG_ARCH="x86_64"
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/PCSX2/pcsx2"
PKG_URL="${PKG_SITE}.git"
PKG_LONGDESC="PCSX2 is a free and open-source PlayStation 2 (PS2) emulator."
PKG_DEPENDS_TARGET="toolchain llvm:host SDL3 libpng zlib libjpeg-turbo zstd lz4 libwebp freetype plutosvg rapidyaml curl libpcap ffmpeg dbus libX11 libXext qt6 kddockwidgets shaderc ecm"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="speed"

PATCHES_URL="https://github.com/PCSX2/pcsx2_patches/releases/latest/download/patches.zip"

post_unpack() {
  # PCSX2 reads its version from git describe; the fetched tree has no tags.
  git -C ${PKG_BUILD} tag -f ${PKG_GIT_TAG}
}

pre_make_target() {
  for _f in "${SYSROOT_PREFIX}"/usr/lib/*.o "${SYSROOT_PREFIX}"/usr/lib/*.a; do
    [ -f "${_f}" ] || continue
    "${TOOLCHAIN}/bin/llvm-strip" --strip-debug "${_f}" 2>/dev/null || true
  done

  for _v in CFLAGS CXXFLAGS LDFLAGS; do
    export ${_v}="$(echo ${!_v} | sed 's/-mtune=[^ ]*//g')"
  done
}

make_target() {
  mkdir -p "${PKG_BUILD}/.${TARGET_NAME}"
  cd "${PKG_BUILD}/.${TARGET_NAME}"

  cmake -G Ninja \
    -S "${PKG_BUILD}" \
    -B "${PKG_BUILD}/.${TARGET_NAME}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_MAKE_PROGRAM=ninja \
    -DCMAKE_C_COMPILER="${TOOLCHAIN}/bin/clang" \
    -DCMAKE_CXX_COMPILER="${TOOLCHAIN}/bin/clang++" \
    -DCMAKE_AR="${TOOLCHAIN}/bin/llvm-ar" \
    -DCMAKE_RANLIB="${TOOLCHAIN}/bin/llvm-ranlib" \
    -DCMAKE_C_COMPILER_AR="${TOOLCHAIN}/bin/llvm-ar" \
    -DCMAKE_CXX_COMPILER_AR="${TOOLCHAIN}/bin/llvm-ar" \
    -DCMAKE_C_COMPILER_RANLIB="${TOOLCHAIN}/bin/llvm-ranlib" \
    -DCMAKE_CXX_COMPILER_RANLIB="${TOOLCHAIN}/bin/llvm-ranlib" \
    -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld -Wl,--strip-debug" \
    -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld -Wl,--strip-debug" \
    -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld -Wl,--strip-debug" \
    -DCMAKE_LINKER_TYPE=LLD \
    -DCMAKE_SYSTEM_NAME=Linux \
    -DCMAKE_SYSTEM_PROCESSOR=${TARGET_ARCH} \
    -DCMAKE_C_COMPILER_TARGET=${TARGET_NAME} \
    -DCMAKE_CXX_COMPILER_TARGET=${TARGET_NAME} \
    -DCMAKE_SYSROOT="${SYSROOT_PREFIX}" \
    -DCMAKE_FIND_ROOT_PATH="${SYSROOT_PREFIX}" \
    -DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY \
    -DCMAKE_DISABLE_PRECOMPILE_HEADERS=ON \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF \
    -DLTO_PCSX2_CORE=ON \
    -DDISABLE_ADVANCE_SIMD=ON \
    -DENABLE_TESTS=OFF \
    -DUSE_VULKAN=ON \
    -DUSE_OPENGL=ON \
    -DUSE_BACKTRACE=OFF \
    -DWAYLAND_API=ON \
    -DX11_API=ON
  cmake --build "${PKG_BUILD}/.${TARGET_NAME}"
  wget -c -t 5 -O "bin/resources/patches.zip" ${PATCHES_URL}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/share/pcsx2-sa
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/bin/* ${INSTALL}/usr/share/pcsx2-sa

  mkdir -p ${INSTALL}/usr/config
    cp -a ${PKG_DIR}/config/PCSX2 ${INSTALL}/usr/config
}
