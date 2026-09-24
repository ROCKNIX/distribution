# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="shadps4-sa"
PKG_VERSION="e3ce810f3a653f43ac64ebab63023de281a4103a" # tag v.0.18.0
PKG_ARCH="x86_64"
PKG_LICENSE="GPL-2.0-or-later"
PKG_SITE="https://github.com/shadps4-emu/shadPS4"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain llvm:host SDL3 ffmpeg boost libfmt freetype libpng zlib openal-soft pugixml miniupnpc \
                    nlohmann-json libX11 wayland util-linux systemd ${VULKAN} jq"
PKG_LONGDESC="shadPS4 - Sony PlayStation 4 emulator"
PKG_TOOLCHAIN="manual"

pre_configure_target() {
  for _v in CFLAGS CXXFLAGS LDFLAGS; do
    export ${_v}="$(echo ${!_v} | sed 's/-mtune=[^ ]*//g; s/-fuse-ld=bfd//g')"
  done
}

make_target() {
  # The bundled protoc is a target binary; run it through the sysroot loader at build time.
  local _loader="${SYSROOT_PREFIX}/usr/lib/ld-linux-x86-64.so.2;--library-path;${SYSROOT_PREFIX}/usr/lib:${TOOLCHAIN}/${TARGET_NAME}/lib"

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
    -DCMAKE_CROSSCOMPILING_EMULATOR="${_loader}" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION_RELEASE=ON \
    -DENABLE_SYSTEM_LIBRARIES=ON \
    -DCMAKE_DISABLE_FIND_PACKAGE_glslang=ON \
    -DCMAKE_DISABLE_FIND_PACKAGE_VulkanHeaders=ON \
    -DCMAKE_DISABLE_FIND_PACKAGE_stb=ON \
    -DCMAKE_DISABLE_FIND_PACKAGE_miniz=ON \
    -DENABLE_DISCORD_RPC=OFF \
    -DENABLE_UPDATER=OFF \
    -DENABLE_TESTS=OFF
  cmake --build "${PKG_BUILD}/.${TARGET_NAME}"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    cp -a ${PKG_BUILD}/.${TARGET_NAME}/shadps4 ${INSTALL}/usr/bin
    cp -a ${PKG_DIR}/scripts/start_shadps4.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/shadps4
    cp -a ${PKG_DIR}/config/* ${INSTALL}/usr/config/shadps4

  mkdir -p ${INSTALL}/usr/config/modules
    cp -a ${PKG_DIR}/sources/"Start shadPS4.sh" ${INSTALL}/usr/config/modules
}
