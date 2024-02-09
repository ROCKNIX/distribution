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
                    p7zip file initramfs grep wget util-linux zstd lz4 empty lzo libzip \
                    bash coreutils modules system-utils autostart quirks powerstate gnupg \
                    gzip six lynx xmlstarlet vim pyudev dialog dbus-python network rocknix"

PKG_UI="emulationstation es-themes textviewer"

PKG_UI_TOOLS="fileman fbgrab"

PKG_GRAPHICS="imagemagick"

PKG_FONTS="corefonts"

PKG_MULTIMEDIA="ffmpeg vlc mpv gmu"

PKG_SOUND="espeak libao"

PKG_SYNC="synctools"

PKG_TOOLS="patchelf git ectool make i2c-tools evtest powertop"

PKG_DEBUG="debug"

if [ "${BASE_ONLY}" = "true" ]
then
  EMULATION_DEVICE=no
  ENABLE_32BIT=no
  PKG_DEPENDS_TARGET+=" ${PKG_TOOLS} ${PKG_FONTS}"
else
  PKG_DEPENDS_TARGET+=" ${PKG_TOOLS} ${PKG_FONTS} ${PKG_SOUND} ${PKG_SYNC} ${PKG_GRAPHICS} ${PKG_UI} ${PKG_UI_TOOLS} ${PKG_MULTIMEDIA} misc-packages"

  # GL demos and tools
  [ "${OPENGL_SUPPORT}" = "yes" ] && PKG_DEPENDS_TARGET+=" mesa-demos glmark2"

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
[ "${EXFAT}" = "yes" ] && PKG_DEPENDS_TARGET+=" exfat exfatprogs"

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

true
