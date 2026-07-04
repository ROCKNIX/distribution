# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="yaps2-sa"
PKG_VERSION="6e468c07e0276f17d15502aca31d92e57407681c"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/yaps2/yaps2"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_LONGDESC="yaps2 is an ARM64-focused PlayStation 2 (PS2) emulator, a fork of PCSX2."
PKG_DEPENDS_TARGET="toolchain llvm:host SDL3 libpng zlib libjpeg-turbo zstd lz4 libwebp freetype plutosvg curl libpcap ffmpeg libX11 libXext qt6 shaderc"
PKG_TOOLCHAIN="manual"

PCSX2_CMAKE_BASE=(
  -DCMAKE_BUILD_TYPE=Release
  -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=OFF
  -DCMAKE_DISABLE_PRECOMPILE_HEADERS=ON
  -DUSE_VULKAN=ON
  -DUSE_OPENGL=ON
  -DUSE_BACKTRACE=OFF
  -DENABLE_QT_UI=ON
  -DWAYLAND_API=ON
  -DX11_API=ON
)

PATCHES_URL="https://github.com/PCSX2/pcsx2_patches/archive/refs/tags/latest.zip"

make_target() {
  for _v in CFLAGS CXXFLAGS LDFLAGS; do
    export ${_v}="$(echo ${!_v} | sed 's/-mabi=lp64//g; s/-mtune=[^ ]*//g')"
  done

  mkdir -p "${PKG_BUILD}/.${TARGET_NAME}"
  cd "${PKG_BUILD}/.${TARGET_NAME}"

  local -a tgt_opts=(
    -G Ninja
    -S "${PKG_BUILD}"
    -B "${PKG_BUILD}/.${TARGET_NAME}"
    -DCMAKE_INSTALL_PREFIX=/usr
    -DCMAKE_MAKE_PROGRAM=ninja
    -DCMAKE_C_COMPILER="${TOOLCHAIN}/bin/clang"
    -DCMAKE_CXX_COMPILER="${TOOLCHAIN}/bin/clang++"
    -DCMAKE_C_COMPILER_AR="${TOOLCHAIN}/bin/llvm-ar"
    -DCMAKE_CXX_COMPILER_AR="${TOOLCHAIN}/bin/llvm-ar"
    -DCMAKE_C_COMPILER_RANLIB="${TOOLCHAIN}/bin/llvm-ranlib"
    -DCMAKE_CXX_COMPILER_RANLIB="${TOOLCHAIN}/bin/llvm-ranlib"
    -DCMAKE_EXE_LINKER_FLAGS_INIT="-fuse-ld=lld"
    -DCMAKE_MODULE_LINKER_FLAGS_INIT="-fuse-ld=lld"
    -DCMAKE_SHARED_LINKER_FLAGS_INIT="-fuse-ld=lld"
    -DCMAKE_SYSTEM_NAME=Linux
    -DCMAKE_SYSTEM_PROCESSOR=aarch64
    -DCMAKE_C_COMPILER_TARGET=aarch64-rocknix-linux-gnu
    -DCMAKE_CXX_COMPILER_TARGET=aarch64-rocknix-linux-gnu
    -DCMAKE_SYSROOT="${SYSROOT_PREFIX}"
    -DCMAKE_FIND_ROOT_PATH="${SYSROOT_PREFIX}"
    -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY
    -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY
    -DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY
    -DLLVM_DIR="${TOOLCHAIN}/lib/cmake/llvm"
    "${PCSX2_CMAKE_BASE[@]}"
  )
  cmake "${tgt_opts[@]}"
  cmake --build "${PKG_BUILD}/.${TARGET_NAME}"
  ninja install
  wget -c -t 5 -O "bin/resources/patches.zip" ${PATCHES_URL}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/share/yaps2-sa
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/bin/* ${INSTALL}/usr/share/yaps2-sa

  mkdir -p ${INSTALL}/usr/config
  cp -rf ${PKG_DIR}/config/YAPS2 ${INSTALL}/usr/config
}

post_install() {
  case ${GRAPHICS_DRIVER} in
    panfrost)
      GRAPHICS="export MESA_GL_VERSION_OVERRIDE=3.3 MESA_GLSL_VERSION_OVERRIDE=330"
    ;;
    *)
      GRAPHICS=""
    ;;
  esac

  sed -e "s/@GRAPHICS@/${GRAPHICS}/g" \
        -i ${INSTALL}/usr/bin/start_yaps2.sh
}
