# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="rpcs3-sa"
PKG_VERSION="2f4034590f261cc2aafbc10139744c68a146b5a4"
PKG_LICENSE="GPL-2.0-or-later.txt"
PKG_SITE="https://github.com/RPCS3/rpcs3"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain llvm qt6 SDL3 ffmpeg curl zlib zstd libpng pugixml \
                    libusb libevdev alsa-lib pulseaudio openal-soft miniupnpc"
PKG_LONGDESC="PS3 Emulator"
PKG_WIKI_CONFIG_DB="https://api.rpcs3.net/config/?api=v1"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glew"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN} vulkan-headers"
fi

PKG_CMAKE_OPTS_TARGET+=" -DWITH_LLVM=ON \
                         -DBUILD_LLVM=OFF \
                         -DSTATIC_LINK_LLVM=OFF \
                         -DLLVM_DIR=${SYSROOT_PREFIX}/usr/lib/cmake/llvm \
                         -DUSE_NATIVE_INSTRUCTIONS=OFF \
                         -DUSE_PRECOMPILED_HEADERS=OFF \
                         -DUSE_LTO=ON \
                         -DUSE_DISCORD_RPC=OFF \
                         -DUSE_SYSTEM_FFMPEG=ON \
                         -DUSE_SYSTEM_CURL=ON \
                         -DUSE_SYSTEM_SDL=ON \
                         -DUSE_SYSTEM_ZLIB=ON \
                         -DUSE_SYSTEM_ZSTD=ON \
                         -DUSE_SYSTEM_LIBPNG=ON \
                         -DUSE_SYSTEM_PUGIXML=ON \
                         -DUSE_SYSTEM_LIBUSB=ON \
                         -DUSE_SYSTEM_OPENAL=ON \
                         -DUSE_SYSTEM_MINIUPNPC=ON \
                         -DUSE_SYSTEM_OPENCV=OFF"

pre_configure_target() {
  # llvm is linked from the sysroot, drop its build tree to free disk for rpcs3
  rm -rf "$(get_build_dir llvm)"

  export CFLAGS="${CFLAGS} -DGLEW_EGL"
  export CXXFLAGS="${CXXFLAGS} -DGLEW_EGL"
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
    DESTDIR=${INSTALL} cmake --install ${PKG_BUILD}/.${TARGET_NAME}
    mv ${INSTALL}/usr/bin/rpcs3 ${INSTALL}/usr/bin/rpcs3-sa
    cp -a ${PKG_DIR}/scripts/start_rpcs3.sh ${INSTALL}/usr/bin

  mkdir -p ${INSTALL}/usr/config/rpcs3
    cp -aL ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/rpcs3

  mkdir -p ${INSTALL}/usr/config/rpcs3/GuiConfigs
    CONFIG_DB="${PKG_BUILD}/config_database.dat"
    if curl -fLo "${CONFIG_DB}" "${PKG_WIKI_CONFIG_DB}" && grep -q '"games"' "${CONFIG_DB}"; then
      cp "${CONFIG_DB}" ${INSTALL}/usr/config/rpcs3/GuiConfigs
    else
      log_qa_check "config_database" "could not fetch a valid config database from ${PKG_WIKI_CONFIG_DB}"
    fi
}
