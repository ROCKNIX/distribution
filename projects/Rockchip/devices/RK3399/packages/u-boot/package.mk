# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="2024.07"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL="https://ftp.denx.de/pub/u-boot/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
PKG_DEPENDS_TARGET="toolchain openssl:host pkg-config:host Python3:host swig:host pyelftools:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"

if [ -n "${UBOOT_FIRMWARE}" ]; then
  PKG_DEPENDS_TARGET+=" ${UBOOT_FIRMWARE}"
  PKG_DEPENDS_UNPACK+=" ${UBOOT_FIRMWARE}"
fi

pre_make_target() {
  PKG_UBOOT_CONFIG="evb-rk3399_defconfig"
  PKG_RKBIN="$(get_build_dir rkbin)"
  PKG_LOADER="${PKG_RKBIN}/bin/rk33/rk3399_miniloader_v1.26.bin"
  export BL31="$(get_build_dir atf)/build/rk3399/release/bl31/bl31.elf"
  export ROCKCHIP_TPL="${PKG_RKBIN}/bin/rk33/rk3399_ddr_933MHz_v1.30.bin"
  PKG_ATF_INI="${PKG_RKBIN}/RKTRUST/RK3399TRUST.ini"
}

make_target() {
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
  setup_pkg_config_host

  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make ${PKG_UBOOT_CONFIG}
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm _python_sysroot="${TOOLCHAIN}" _python_prefix=/ _python_exec_prefix=/ make HOSTCC="${HOST_CC}" HOSTCFLAGS="-I${TOOLCHAIN}/include" HOSTLDFLAGS="${HOST_LDFLAGS}" CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"

  ${PKG_RKBIN}/tools/mkimage -n rk3399 -T rksd -d ${ROCKCHIP_TPL}:${PKG_LOADER} ${PKG_BUILD}/idbloader.img

  ${PKG_RKBIN}/tools/loaderimage --pack --uboot ${PKG_BUILD}/u-boot-dtb.bin ${PKG_BUILD}/u-boot.img 0x00200000

  ${PKG_RKBIN}/tools/trust_merger --ignore-bl32 --prepath ${PKG_RKBIN}/ ${PKG_ATF_INI}

  dd if=${PKG_BUILD}/idbloader.img of=${PKG_BUILD}/rk3399-uboot.bin seek=0 conv=fsync,notrunc
  dd if=${PKG_BUILD}/u-boot.img of=${PKG_BUILD}/rk3399-uboot.bin seek=16320 conv=fsync,notrunc
  dd if=${PKG_BUILD}/trust.img of=${PKG_BUILD}/rk3399-uboot.bin seek=24512 conv=fsync,notrunc
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader

  # Always install the update script
  find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader

  if find_file_path bootloader/boot.ini; then
    cp -av ${FOUND_PATH} $INSTALL/usr/share/bootloader
    sed -e "s/@DISTRO_BOOTLABEL@/${DISTRO_BOOTLABEL}/" \
        -e "s/@DISTRO_DISKLABEL@/${DISTRO_DISKLABEL}/" \
        -e "s/@EXTRA_CMDLINE@/${EXTRA_CMDLINE}/" \
        -i "${INSTALL}/usr/share/bootloader/boot.ini"
  fi

  PKG_UBOOTIMG=${PKG_BUILD}/rk3399-uboot.bin

  if [ ${PKG_UBOOTIMG} ]; then
    cp -av ${PKG_UBOOTIMG} $INSTALL/usr/share/bootloader
  fi
}
