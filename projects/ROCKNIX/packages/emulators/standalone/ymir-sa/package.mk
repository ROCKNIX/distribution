# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="ymir-sa"
PKG_VERSION="54fead6a0001d3e4b6741a8d095ee8342266c3dc" # tag v0.3.3
PKG_LICENSE="GPL-3.0-or-later"
PKG_SITE="https://github.com/StrikerX3/Ymir"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain llvm:host SDL3 curl openssl zlib zstd alsa-lib cereal cxxopts date neargye-semver rtmidi stb \
                    tomlplusplus miniz rocknix-hotkey"
PKG_LONGDESC="Ymir - Sega Saturn emulator"
PKG_TOOLCHAIN="manual"

case ${TARGET_ARCH} in
  x86_64)
    YMIR_SIMD="-DYmir_AVX2=ON"
    ;;
esac

pre_configure_target() {
  for _v in CFLAGS CXXFLAGS LDFLAGS; do
    export ${_v}="$(echo ${!_v} | sed 's/-mabi=lp64//g; s/-mtune=[^ ]*//g; s/-fuse-ld=bfd//g')"
  done
}

make_target() {
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
    -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld -Wl,--strip-debug" \
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
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_MODULE_PATH="${PKG_DIR}/cmake" \
    -DCMAKE_PROJECT_Ymir_INCLUDE="${PKG_DIR}/cmake/rocknix-targets.cmake" \
    -DYmir_DEV_BUILD=OFF \
    -DYmir_ENABLE_TESTS=OFF \
    -DYmir_ENABLE_SANDBOX=OFF \
    -DYmir_ENABLE_YMDASM=OFF \
    -DYmir_ENABLE_YMIR_HEADLESS=OFF \
    -DYmir_ENABLE_YMIR_DBG=OFF \
    -DYmir_ENABLE_IMGUI_DEMO=OFF \
    -DYmir_ENABLE_UPDATE_CHECKS=OFF \
    -DYmir_ENABLE_IPO=ON \
    -DYmir_FF_VIRTUA_GUN=ON \
    ${YMIR_SIMD}
  cmake --build "${PKG_BUILD}/.${TARGET_NAME}"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -L ${PKG_BUILD}/.${TARGET_NAME}/apps/ymir-sdl3/ymir-sdl3 ${INSTALL}/usr/bin/ymir
    cp -a ${PKG_DIR}/scripts/start_ymir.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/ymir
    cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/ymir
}
