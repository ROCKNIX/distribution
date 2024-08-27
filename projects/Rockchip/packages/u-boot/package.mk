# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2022-24 JELOS (https://github.com/JustEnoughLinuxOS)
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_SITE="https://github.com/ROCKNIX"
PKG_LICENSE="GPL"
PKG_DEPENDS_TARGET="toolchain Python3 swig:host rkbin pyelftools:host"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_PATCH_DIRS+="${DEVICE}"

PKG_NEED_UNPACK="$PROJECT_DIR/$PROJECT/bootloader"

case ${DEVICE} in
  RK3399)
    PKG_VERSION="2024.07"
    PKG_URL="https://ftp.denx.de/pub/u-boot/${PKG_NAME}-${PKG_VERSION}.tar.bz2"
    ;;
esac

[ -n "${ATF_PLATFORM}" ] && PKG_DEPENDS_TARGET+=" atf"

make_target() {
  export PKG_RKBIN="$(get_build_dir rkbin)"
  setup_pkg_config_host
  . ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options
  if [ -z "${UBOOT_CONFIG}" ]; then
    echo "UBOOT_CONFIG must be set to build an image"
  else
    [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
    if [[ "${PKG_BL31}" =~ ^/bin ]]; then
      PKG_BL31="$(get_build_dir rkbin)/${PKG_BL31}"
    fi
    if [[ "${PKG_LOADER}" =~ ^/bin ]]; then
      PKG_LOADER="$(get_build_dir rkbin)/${PKG_LOADER}"
    fi

    if [[ "${PKG_SOC}" =~ "rk3399" ]]; then
      echo "Building for MBR (${UBOOT_DTB})..."
      if [[ "${ATF_PLATFORM}" =~ "rk3399" ]]; then
        export BL31="$(get_build_dir atf)/.install_pkg/usr/share/bootloader/bl31.elf"
      fi
      DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make mrproper
      DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make ${UBOOT_CONFIG}
      DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm _python_sysroot="${TOOLCHAIN}" _python_prefix=/ _python_exec_prefix=/ make HOSTCC="${HOST_CC}" HOSTCFLAGS="-I${TOOLCHAIN}/include" HOSTLDFLAGS="${HOST_LDFLAGS}" CONFIG_MKIMAGE_DTC_PATH="scripts/dtc/dtc"
    fi
  fi
}

makeinstall_target() {
    mkdir -p ${INSTALL}/usr/share/bootloader
    # Only install u-boot.img et al when building a board specific image
    if [ -n "${UBOOT_CONFIG}" ]; then
      find_file_path bootloader/install && . ${FOUND_PATH}
    fi

    # Always install the update script
    find_file_path bootloader/update.sh && cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader

    # Always install the canupdate script
    if find_file_path bootloader/canupdate.sh; then
      cp -av ${FOUND_PATH} ${INSTALL}/usr/share/bootloader
      sed -e "s/@PROJECT@/${DEVICE:-${PROJECT}}/g" \
          -i ${INSTALL}/usr/share/bootloader/canupdate.sh
    fi
}
