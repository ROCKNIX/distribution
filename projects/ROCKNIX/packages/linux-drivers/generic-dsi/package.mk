# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="generic-dsi"
PKG_VERSION="fa1bd4c5b55bb60bfded06a1c1964328b871345d"
PKG_LICENSE="GPL"
PKG_LONGDESC="generic DSI panel driver and stock DTB import scripts"
PKG_DEPENDS_TARGET="pyFDT"
PKG_URL="https://github.com/stolen/overlay_server/archive/${PKG_VERSION}.zip"
PKG_TOOLCHAIN="manual"

unpack() {
  mkdir -p "${PKG_BUILD}"
  cd "${PKG_BUILD}"
  unzip "${SOURCES}/${PKG_NAME}/${PKG_SOURCE_NAME}"
}

### For development. Easier to check if code compiles and works.
### No need for a long build-transfer-reboot-wait-reboot-check loop
make_target() {
  if [ "${I_AM_DEVELOPER}" == "yes" ]; then
    # rename the driver to not conflict with built-in one
    sed 's|define DRIVER_NAME .*$|define DRIVER_NAME "panel-generic-dsi-test"|' panel-generic-dsi.c > panel-generic-dsi-test.c
    echo 'obj-m += panel-generic-dsi-test.o' > ${PKG_BUILD}/Makefile
    kernel_make -C $(kernel_path) M=${PKG_BUILD}
  fi
}

makeinstall_target() {
  mkdir -p "${INSTALL}/usr/libexec/generic-dsi"
  # rocknix_dtbo.py is a better script handling not just panel, but also joypad, headphones, etc.
  cp -v "${PKG_BUILD}/"overlay_server*"/rocknix_dtbo.py" "${INSTALL}/usr/libexec/generic-dsi/"
  # importpanel.py still here because it's simple, documented in wiki and performs just one task well
  cp -v "${PKG_DIR}/scripts/importpanel.py" "${INSTALL}/usr/libexec/generic-dsi/"
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
