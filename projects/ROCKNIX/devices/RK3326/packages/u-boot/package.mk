# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="u-boot"
PKG_VERSION="v2025.10"
PKG_SHA256="5414ee86562abc5ed524c6dc5e092511ad281441020a88e7027de6e83fd16116"
PKG_LICENSE="GPL"
PKG_SITE="https://www.denx.de/wiki/U-Boot"
PKG_URL="https://github.com/u-boot/u-boot/archive/refs/tags/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain Python3:host swig:host pyelftools:host u-boot-legacy"
PKG_LONGDESC="Das U-Boot is a cross-platform bootloader for embedded systems."
PKG_TOOLCHAIN="manual"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"
PKG_NEED_UNPACK+=" ${PROJECT_DIR}/${PROJECT}/options ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"

if [ -n "${UBOOT_FIRMWARE}" ]; then
  PKG_DEPENDS_TARGET+=" ${UBOOT_FIRMWARE}"
  PKG_DEPENDS_UNPACK+=" ${UBOOT_FIRMWARE}"
fi

pre_make_target() {
  PKG_UBOOT_CONFIG="rk3326-handheld_defconfig"
  PKG_RKBIN="$(get_build_dir rkbin)"
  PKG_MINILOADER="${PKG_RKBIN}/bin/rk33/rk3326_miniloader_v1.40.bin"
  PKG_BL31="${PKG_RKBIN}/bin/rk33/rk3326_bl31_v1.34.elf"
  PKG_DDR_BIN="${PKG_RKBIN}/bin/rk33/rk3326_ddr_333MHz_v2.11.bin"
  PKG_DDR_BIN_UART5="${PKG_RKBIN}/rk3326_ddr_uart5.bin"
}

make_target() {
  [ "${BUILD_WITH_DEBUG}" = "yes" ] && PKG_DEBUG=1 || PKG_DEBUG=0
  setup_pkg_config_host

  find_file_path bootloader/rkhelper || exit 4
  RKHELPER=${FOUND_PATH}

  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make mrproper
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm make HOSTCC="${HOST_CC}" HOSTCFLAGS="-I${TOOLCHAIN}/include" HOSTLDFLAGS="${HOST_LDFLAGS}" ${PKG_UBOOT_CONFIG}
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm \
        _python_sysroot="${TOOLCHAIN}" _python_prefix=/ _python_exec_prefix=/ \
        make HOSTCC="${HOST_CC}" HOSTLDFLAGS="-L${TOOLCHAIN}/lib" HOSTSTRIP="true" \
        u-boot-dtb.bin
  . ${RKHELPER}
  mv uboot.bin uboot.bin.default

  ./scripts/config --set-val CONFIG_DEBUG_UART_BASE 0xFF178000
  ./scripts/config --set-str CONFIG_DEVICE_TREE_INCLUDES "rk3326-odroid-go2-emmc.dtsi rk3326-odroid-go2-uart5.dtsi"
  DEBUG=${PKG_DEBUG} CROSS_COMPILE="${TARGET_KERNEL_PREFIX}" LDFLAGS="" ARCH=arm \
        _python_sysroot="${TOOLCHAIN}" _python_prefix=/ _python_exec_prefix=/ \
        make HOSTCC="${HOST_CC}" HOSTLDFLAGS="-L${TOOLCHAIN}/lib" HOSTSTRIP="true" \
        u-boot-dtb.bin
  PKG_DDR_BIN=${PKG_DDR_BIN_UART5} . ${RKHELPER}
  mv uboot.bin uboot.bin.uart5
}

# IMPORTANT!
# For every device `<dev_name>` not in any image this function creates
# an `extlinux.conf.<dev_name>` file passing a corresponding dtb directly
# (effectively bypassing auto-detection by ADC value).
# User needs to rename a single file (replacing the generic `extlinux.conf`)
# to configure any (a/b) image for their device.
generate_custom_extlinux_conf_files() {
  INI_FILES=""
  for SUBDEVICE in ${SUBDEVICES}; do
    if find_file_path config/${SUBDEVICE}_boot.ini; then
      INI_FILES="${INI_FILES} ${FOUND_PATH}"
    fi
  done
  EXTLCONF0=${INSTALL}/usr/share/bootloader/extlinux/extlinux.conf

  echo "INI_FILES ${INI_FILES}"
  for dtbase in $(xmlstarlet sel -t -v "//rocknix/${DEVICE}/*" ${CONFIGXML}); do
    if ! grep -q "\<${dtbase}.dtb" ${INI_FILES}; then
      EXTLCONF=${EXTLCONF0}.${dtbase##*-}
      echo "Generating ${EXTLCONF} for ${dtbase}"
      sed '/##/d;s|^.* FDT .*$|  FDT /'${dtbase}'.dtb|' ${EXTLCONF0} > ${EXTLCONF0}.${dtbase##*-}
    fi
  done
}

makeinstall_target() {
  mkdir -p $INSTALL/usr/share/bootloader

  for SUBDEVICE in ${SUBDEVICES}; do
    if find_file_path config/${SUBDEVICE}_boot.ini; then
      cp -av ${FOUND_PATH} .
      sed -e "s/@DISTRO_BOOTLABEL@/${DISTRO_BOOTLABEL}/" \
          -e "s/@DISTRO_DISKLABEL@/${DISTRO_DISKLABEL}/" \
          -e "s/@EXTRA_CMDLINE@/${EXTRA_CMDLINE}/" \
          -i "${SUBDEVICE}_boot.ini"
      ./tools/mkimage -T script -d "${SUBDEVICE}_boot.ini" "${SUBDEVICE}_boot.scr"
      cp -av "${SUBDEVICE}_boot.scr" "${INSTALL}/usr/share/bootloader/"
    fi
  done

  cp -av uboot.bin.default "${INSTALL}/usr/share/bootloader/b_uboot.bin"
  cp -av uboot.bin.uart5 "${INSTALL}/usr/share/bootloader/b_uboot.bin.uart5"

  find_dir_path config/extlinux || exit 3
  cp -av ${FOUND_PATH} "${INSTALL}/usr/share/bootloader/"
  sed -e "s/@EXTRA_CMDLINE@/${EXTRA_CMDLINE}/" \
    -i ${INSTALL}/usr/share/bootloader/extlinux/*

  # Next call creates an `extlinux.conf.<dev_name>` files for every dts/dtb not in any image.
  # User needs to rename a proper file to `extlinux.conf` (replacing it) as a preparation step.
  generate_custom_extlinux_conf_files

  find_dir_path config/stock && cp -av ${FOUND_PATH} "${INSTALL}/usr/share/bootloader/"
  find_dir_path config/overlays && cp -av ${FOUND_PATH} "${INSTALL}/usr/share/bootloader/"
}
