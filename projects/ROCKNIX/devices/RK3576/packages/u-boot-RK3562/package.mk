# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot-RK3562"
PKG_VERSION="1c535d65b8509f388d09e49fb6961f49fda35a1d"
PKG_SHA256="6e369de9f872f51402b10cd5eb9e086a9453cfa1a03b1dd37f85a8bdfe0d4cdb"
PKG_LICENSE="GPL"
PKG_SITE="https://github.com/rockchip-linux/u-boot"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3 swig:host pyelftools:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"

if [ -n "${UBOOT_FIRMWARE}" ]; then
  PKG_DEPENDS_TARGET+=" ${UBOOT_FIRMWARE}"
  PKG_DEPENDS_UNPACK+=" ${UBOOT_FIRMWARE}"
fi

pre_make_target() {
  # this vendor tree builds with -Werror and trips several gcc 16 warnings
  export KCFLAGS="-Wno-error"

  PKG_UBOOT_CONFIG="rk3562_defconfig"
  PKG_SOC="rk3562"
  PKG_RKBIN="$(get_build_dir rkbin)"
  PKG_MINILOADER="spl/u-boot-spl.bin"
  PKG_BL31="${PKG_RKBIN}/bin/rk35/rk3562_bl31_v1.23.elf"
  PKG_BL32="${PKG_RKBIN}/bin/rk35/rk3562_bl32_v1.10.bin"
  PKG_DDR_BIN="${PKG_RKBIN}/bin/rk35/rk3562_ddr_1332MHz_v1.10.bin"
}

make_target() {
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
  setup_pkg_config_host

  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm64 make mrproper
  cp ${PKG_BL31} bl31.elf
  cp ${PKG_BL32} tee.bin
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm64 make HOSTCC="${HOST_CC}" HOSTCFLAGS="-O2 -I${TOOLCHAIN}/include" HOSTLDFLAGS="${HOST_LDFLAGS}" ${PKG_UBOOT_CONFIG} BL31=${PKG_BL31} ${PKG_MINILOADER} u-boot.dtb u-boot.itb CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm64 _python_sysroot="${TOOLCHAIN}" _python_prefix=/ _python_exec_prefix=/ make HOSTCC="${HOST_CC}" HOSTCFLAGS="-O2 -I${TOOLCHAIN}/include" HOSTLDFLAGS="-L${TOOLCHAIN}/lib" HOSTSTRIP="true" CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"

  find_file_path bootloader/rkhelper && . ${FOUND_PATH}
}

makeinstall_target() {
  : # nothing
}
