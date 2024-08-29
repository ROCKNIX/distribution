# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="611716febddb824a7203d0d3b5d399608a54ccf6"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL="https://github.com/ROCKNIX/hardkernel-uboot/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain openssl:host pkg-config:host Python3:host swig:host pyelftools:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"

if [ -n "${UBOOT_FIRMWARE}" ]; then
  PKG_DEPENDS_TARGET+=" ${UBOOT_FIRMWARE}"
  PKG_DEPENDS_UNPACK+=" ${UBOOT_FIRMWARE}"
fi

configure_package() {
  PKG_UBOOT_CONFIG="odroidgoa_defconfig"
  PKG_RKBIN="$(get_build_dir rkbin)"
  PKG_LOADER="${PKG_RKBIN}/bin/rk33/rk3326_miniloader_v1.28.bin"
  export BL31="${PKG_RKBIN}/bin/rk33/rk3326_bl31_v1.22.elf"
  export ROCKCHIP_TPL="${PKG_RKBIN}/bin/rk33/rk3326_ddr_333MHz_v1.15.bin"
}

make_target() {
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
  setup_pkg_config_host

  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make ${PKG_UBOOT_CONFIG}
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm _python_sysroot="${TOOLCHAIN}" _python_prefix=/ _python_exec_prefix=/ make HOSTCC="$HOST_CC" HOSTLDFLAGS="-L${TOOLCHAIN}/lib" HOSTSTRIP="true" CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"

  ${PKG_BUILD}/tools/mkimage -n px30 -T rksd -d ${ROCKCHIP_TPL} -C bzip2 ${PKG_BUILD}/idbloader.img

  ${PKG_BUILD}/tools/loaderimage --pack --uboot ${PKG_BUILD}/u-boot-dtb.bin ${PKG_BUILD}/u-boot.img 0x00200000

  cat >${PKG_BUILD}/trust.ini <<EOF
[BL30_OPTION]
SEC=0
[BL31_OPTION]
SEC=1
PATH=${BL31}
ADDR=0x00010000
[BL32_OPTION]
SEC=0
[BL33_OPTION]
SEC=0
[OUTPUT]
PATH=trust.img
EOF
  ${PKG_BUILD}/tools/trust_merger --verbose ${PKG_BUILD}/trust.ini
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

  PKG_IDBLOADER=${PKG_BUILD}/idbloader.img
  PKG_UBOOTIMG=${PKG_BUILD}/u-boot.img
  PKG_TRUSTIMG=${PKG_BUILD}/trust.img

  if [ ${PKG_IDBLOADER} ]; then
    cp -av ${PKG_IDBLOADER} $INSTALL/usr/share/bootloader
  fi
  if [ ${PKG_UBOOTIMG} ]; then
    cp -av ${PKG_UBOOTIMG} $INSTALL/usr/share/bootloader
  fi
  if [ ${PKG_TRUSTIMG} ]; then
    cp -av ${PKG_TRUSTIMG} $INSTALL/usr/share/bootloader
  fi
}
