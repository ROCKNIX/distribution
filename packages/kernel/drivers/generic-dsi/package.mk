# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="generic-dsi"
PKG_VERSION="0.1.0"
PKG_LICENSE="GPL"
PKG_LONGDESC="generic DSI panel driver"
PKG_TOOLCHAIN="manual"


### For development. Easier to check if code compiles and works.
### No need for a long build-transfer-reboot-wait-reboot-check loop
make_target() {
  if [ "${I_AM_DEVELOPER}" != "yes" ]; then
    echo "######   you should not build ${PKG_NAME} as package!  ######" >&2;
    exit 3;
  fi
  echo 'obj-m += panel-generic-dsi.o' > ${PKG_BUILD}/Makefile
  kernel_make -C $(kernel_path) M=${PKG_BUILD}
}

makeinstall_target() {
  :
}


### For possible future use. The driver can use files in /lib/firmware to initialize a panel,
### thus no need in dtbo, just parameter in cmdline (if base dtb already uses generic driver)
make_init() {
  :
}

makeinstall_init() {
  mkdir -p ${INSTALL}/lib
  cp -av ${PKG_DIR}/firmware ${INSTALL}/lib/
}
