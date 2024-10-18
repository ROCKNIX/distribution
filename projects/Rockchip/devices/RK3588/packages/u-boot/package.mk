# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="e99376f7dd01e310a0874459a1fe7535be431f43"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL="https://github.com/ROCKNIX/rk3588-uboot/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 swig:host pyelftools:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"
PKG_NEED_UNPACK+=" ${PROJECT_DIR}/${PROJECT}/options ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"

if [ -n "${UBOOT_FIRMWARE}" ]; then
  PKG_DEPENDS_TARGET+=" ${UBOOT_FIRMWARE}"
  PKG_DEPENDS_UNPACK+=" ${UBOOT_FIRMWARE}"
fi

pre_make_target() {
  PKG_UBOOT_CONFIG="orangepi_5_defconfig"
  PKG_RKBIN="$(get_build_dir rkbin)"
  PKG_MINILOADER="spl/u-boot-spl.bin"
  PKG_BL31="${PKG_RKBIN}/bin/rk35/rk3588_bl31_v1.38.elf"
  PKG_DDR_BIN="${PKG_RKBIN}/bin/rk35/rk3588_ddr_lp4_1848MHz_lp5_2736MHz_v1.10.bin"
}

make_target() {
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
  setup_pkg_config_host

  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm64 make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm64 make ${PKG_UBOOT_CONFIG} BL31=${PKG_BL31} ${PKG_MINILOADER} u-boot.dtb u-boot.itb CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm64 _python_sysroot="${TOOLCHAIN}" _python_prefix=/ _python_exec_prefix=/ make HOSTCC="${HOST_CC}" HOSTLDFLAGS="-L${TOOLCHAIN}/lib" HOSTSTRIP="true" CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"

  find_file_path bootloader/rkhelper && . ${FOUND_PATH}
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/share/bootloader

  # Always install the update script
  find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader

  cp -av ${PKG_BUILD}/uboot.bin ${INSTALL}/usr/share/bootloader
}
