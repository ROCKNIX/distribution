# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2022-present JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="dolphin-sa"
PKG_LICENSE="GPLv2"
PKG_DEPENDS_TARGET="toolchain libevdev libdrm ffmpeg zlib libpng lzo libusb zstd ecm openal-soft pulseaudio alsa-lib libfmt hidapi"
PKG_LONGDESC="Dolphin is a GameCube / Wii emulator, allowing you to play games for these two platforms on PC with improvements. "
PKG_TOOLCHAIN="cmake"

case ${DEVICE} in
  SD865|AMD64|RK3399)
    PKG_VERSION="3ea870ef8c5f4d4b86bd3ce0c2e3ddba6f1f25aa"
    PKG_SITE="https://github.com/dolphin-emu/dolphin"
    PKG_URL="${PKG_SITE}.git"
    PKG_DEPENDS_TARGET+=" qt6"
    PKG_PATCH_DIRS+=" qt6"
    PKG_CMAKE_OPTS_TARGET+=" -DENABLE_QT=ON \
                             -DUSE_RETRO_ACHIEVEMENTS=ON \
                             -DENABLE_HEADLESS=OFF"
  ;;
  *)
    PKG_SITE="https://github.com/dolphin-emu/dolphin"
    PKG_URL="${PKG_SITE}.git"
    PKG_VERSION="e6583f8bec814d8f3748f1d7738457600ce0de56"
    PKG_PATCH_DIRS+=" wayland"
    PKG_CMAKE_OPTS_TARGET+=" -DENABLE_QT=OFF \
                             -DUSE_RETRO_ACHIEVEMENTS=OFF \
                             -DENABLE_HEADLESS=ON"
  ;;
esac

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_EGL=ON"
elif [ "${OPENGLES_SUPPORT}" = yes ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_EGL=ON"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland ${WINDOWMANAGER} xwayland xrandr libXi"
  PKG_CMAKE_OPTS_TARGET+="     -DENABLE_WAYLAND=ON \
                               -DENABLE_X11=ON"
else
    PKG_CMAKE_OPTS_TARGET+="     -DENABLE_X11=OFF"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_VULKAN=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DENABLE_VULKAN=OFF"
fi

pre_configure_target() {
  PKG_CMAKE_OPTS_TARGET+=" -DCMAKE_BUILD_TYPE=Release \
                           -DENABLE_NOGUI=ON \
                           -DENABLE_EVDEV=ON \
                           -DUSE_DISCORD_PRESENCE=OFF \
                           -DBUILD_SHARED_LIBS=OFF \
                           -DLINUX_LOCAL_DEV=OFF \
                           -DENABLE_PULSEAUDIO=ON \
                           -DENABLE_ALSA=ON \
                           -DENABLE_TESTS=OFF \
                           -DENABLE_LLVM=OFF \
                           -DENABLE_ANALYTICS=OFF \
                           -DENABLE_LTO=ON \
                           -DENCODE_FRAMEDUMPS=OFF \
                           -DENABLE_AUTOUPDATE=OFF \
                           -DUSE_MGBA=OFF \
                           -DENABLE_CLI_TOOL=OFF"
  sed -i 's~#include <cstdlib>~#include <cstdlib>\n#include <cstdint>~g' ${PKG_BUILD}/Externals/VulkanMemoryAllocator/include/vk_mem_alloc.h
  sed -i 's~#include <cstdint>~#include <cstdint>\n#include <string>~g' ${PKG_BUILD}/Externals/VulkanMemoryAllocator/include/vk_mem_alloc.h
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -rf ${PKG_BUILD}/.${TARGET_NAME}/Binaries/dolphin* ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/* ${INSTALL}/usr/bin

  chmod +x ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/dolphin-emu
  cp -rf ${PKG_BUILD}/Data/Sys/* ${INSTALL}/usr/config/dolphin-emu
  cp -rf ${PKG_DIR}/config/${DEVICE}/* ${INSTALL}/usr/config/dolphin-emu
}

post_install() {
    case ${DEVICE} in
      RK3588)
        DOLPHIN_PLATFORM="\${PLATFORM}"
        EXPORTS="if [ ! -z 'lsmod | grep panthor' ]; then LD_LIBRARY_PATH='\/usr\/lib\/libmali-valhall-g610-g13p0-x11-gbm.so' PLATFORM='wayland'; else PLATFORM='x11'; fi"
      ;;
      SD865|AMD64|RK3399)
        DOLPHIN_PLATFORM="x11"
        EXPORTS="export QT_QPA_PLATFORM=xcb"
      ;;
      *)
        DOLPHIN_PLATFORM="wayland"
        EXPORTS=""
      ;;
    esac
    sed -e "s/@DOLPHIN_PLATFORM@/${DOLPHIN_PLATFORM}/g" -i ${INSTALL}/usr/bin/start_dolphin_gc.sh
    sed -e "s/@DOLPHIN_PLATFORM@/${DOLPHIN_PLATFORM}/g" -i  ${INSTALL}/usr/bin/start_dolphin_wii.sh

    sed -e "s/@EXPORTS@/${EXPORTS}/g" \
        -i  ${INSTALL}/usr/bin/start_dolphin_gc.sh
    sed -e "s/@EXPORTS@/${EXPORTS}/g" \
        -i  ${INSTALL}/usr/bin/start_dolphin_wii.sh
}
