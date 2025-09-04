# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="image"
PKG_LICENSE="GPL"
PKG_SITE="https://libreelec.tv"

PKG_SECTION="virtual"
PKG_LONGDESC="Root package used to build and create complete image"

PKG_DEPENDS_TARGET="toolchain squashfs-tools:host dosfstools:host fakeroot:host kmod:host \
                    mtools:host populatefs:host libc gcc linux linux-drivers linux-firmware \
                    ${BOOTLOADER} busybox umtprd util-linux usb-modeswitch unzip poppler jq socat \
                    p7zip file initramfs grep wget util-linux btrfs-progs zstd lz4 empty lzo libzip \
                    bash coreutils system-utils autostart quirks powerstate gnupg \
                    gzip six xmlstarlet pyudev dialog dbus-python network rocknix"

PKG_UI="emulationstation es-themes textviewer"

PKG_UI_TOOLS="fbgrab grim"

PKG_GRAPHICS="imagemagick"

PKG_FONTS="corefonts"

PKG_MULTIMEDIA="ffmpeg vlc mpv gmu m8c"

PKG_SOUND="espeak libao"

PKG_SYNC="synctools"

PKG_TOOLS="patchelf ectool i2c-tools evtest"

PKG_DEBUG="debug"

if [ "${BASE_ONLY}" = "true" ]
then
  EMULATION_DEVICE=no
  ENABLE_32BIT=no
  PKG_DEPENDS_TARGET+=" ${PKG_TOOLS} ${PKG_FONTS}"
else
  PKG_DEPENDS_TARGET+=" ${PKG_TOOLS} ${PKG_FONTS} ${PKG_SOUND} ${PKG_SYNC} ${PKG_GRAPHICS} ${PKG_UI} ${PKG_UI_TOOLS} ${PKG_MULTIMEDIA} misc-packages"

  # GL demos and tools
  [[ ! -z "${OPENGL_SUPPORT}" ]] && PKG_DEPENDS_TARGET+=" mesa-demos"

  # GLmark2
  [[ ! -z "${OPENGLES_SUPPORT}" ]] && PKG_DEPENDS_TARGET+=" glmark2"

  # Vulkan demos and tools
  [ "${VULKAN_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" vkmark"

  # Weston kiosk shell dpms support.
  [ "${WINDOWMANAGER}" = "weston" ] && PKG_DEPENDS_TARGET+=" weston-kiosk-shell-dpms"

  # Sound support
  [ "${PIPEWIRE_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" alsa pulseaudio pipewire wireplumber"

fi

# Device is an emulation focused device
[ "${EMULATION_DEVICE}" = "yes" ] && PKG_DEPENDS_TARGET+=" emulators gamesupport"

# Add support for containers
[ "${CONTAINER_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" ${PKG_TOOLS} docker"

[ "${DEBUG_PACKAGES}" = "yes" ] && PKG_DEPENDS_TARGET+=" ${PKG_DEBUG}"

# 32Bit package support
[ "${ENABLE_32BIT}" == true ] && PKG_DEPENDS_TARGET+=" lib32"

# Architecture specific tools
[ "${ARCH}" = "x86_64" ] && PKG_DEPENDS_TARGET+=" ryzenadj lm_sensors dmidecode"

# Automounter support
[ "${UDEVIL}" = "yes" ] && PKG_DEPENDS_TARGET+=" udevil"

# EXFAT support
[ "${EXFAT}" = "yes" ] && PKG_DEPENDS_TARGET+=" exfatprogs"

# NFS support
[ "${NFS_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" nfs-utils"

# NTFS 3G support
[ "${NTFS3G}" = "yes" ] && PKG_DEPENDS_TARGET+=" ntfs-3g_ntfsprogs"

# Installer support
[ "${INSTALLER_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" installer"

# Devtools... (not for Release)
[ "${TESTING}" = "yes" ] && PKG_DEPENDS_TARGET+=" testing"

# OEM packages
[ "${OEM_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" oem"

# htop
[ "${HTOP_TOOL}" = "yes" ] && PKG_DEPENDS_TARGET+=" htop"

# btop
[ "${BTOP_TOOL}" = "yes" ] && PKG_DEPENDS_TARGET+=" btop"

# modules packages
[ "${MODULES_PKG}" = "yes" ] && PKG_DEPENDS_TARGET+=" modules"

# Entware support
mkdir -p ${INSTALL}
ln -sf /storage/.opt ${INSTALL}/opt
PKG_DEPENDS_TARGET+=" entware"

true
