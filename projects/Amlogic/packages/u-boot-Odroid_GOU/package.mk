# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot-Odroid_GOU"
PKG_VERSION="9235942906216dc529c1e96f67dd2364a94d0738"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL="https://github.com/hardkernel/u-boot/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain openssl:host pkg-config:host Python3:host swig:host pyelftools:host gcc-linaro-aarch64-elf:host gcc-linaro-arm-eabi:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

if [ -n "${UBOOT_FIRMWARE}" ]; then
  PKG_DEPENDS_TARGET+=" ${UBOOT_FIRMWARE}"
  PKG_DEPENDS_UNPACK+=" ${UBOOT_FIRMWARE}"
fi

configure_package() {
  PKG_UBOOT_CONFIG="odroidgou_defconfig"
}

make_target() {
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
  export PATH=${TOOLCHAIN}/lib/gcc-linaro-aarch64-elf/bin/:${TOOLCHAIN}/lib/gcc-linaro-arm-eabi/bin/:${PATH}
  DEBUG=${PKG_DEBUG} CROSS_COMPILE=aarch64-elf- ARCH=arm CFLAGS="" LDFLAGS="" make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE=aarch64-elf- ARCH=arm CFLAGS="" LDFLAGS="" make ${PKG_UBOOT_CONFIG}
  DEBUG=${PKG_DEBUG} CROSS_COMPILE=aarch64-elf- ARCH=arm CFLAGS="" LDFLAGS="" make HOSTCC="${HOST_CC}" HOSTSTRIP="true"

  # repack odroidbios.bin for rocknix
  ${TOOLCHAIN}/sbin/fsck.cramfs --extract=rocknix tools/odroid_resource/ODROIDBIOS.BIN
  sed -e "s/ODROIDGOU/ROCKNIX/" -i rocknix/boot.ini
  ${TOOLCHAIN}/sbin/mkfs.cramfs -N little rocknix tools/odroid_resource/ODROIDBIOS.BIN
}

makeinstall_target() {
  : # nothing
}
