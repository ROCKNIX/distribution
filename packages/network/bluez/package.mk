# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="bluez"
PKG_VERSION="5.75"
PKG_LICENSE="GPL"
PKG_SITE="http://www.bluez.org/"
PKG_URL="https://www.kernel.org/pub/linux/bluetooth/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain dbus glib readline systemd json-c alsa-lib"
PKG_LONGDESC="Bluetooth Tools and System Daemons for Linux."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+lto"

if build_with_debug; then
  BLUEZ_CONFIG="--enable-debug"
else
  BLUEZ_CONFIG="--disable-debug"
fi

BLUEZ_CONFIG+=" --enable-monitor --enable-test"

PKG_CONFIGURE_OPTS_TARGET="--disable-dependency-tracking \
                           --disable-silent-rules \
                           --enable-library \
                           --enable-udev \
                           --disable-cups \
                           --disable-obex \
                           --enable-client \
                           --enable-systemd \
                           --enable-tools \
                           --enable-deprecated \
                           --enable-datafiles \
                           --disable-manpages \
                           --disable-experimental \
                           --enable-sixaxis \
                           --enable-sap \
                           --enable-a2dp \
                           --enable-avrcp \
                           --enable-btpclient \
                           --enable-midi \
                           --enable-mesh \
                           --enable-hid2hci \
                           --enable-experimental \
                           --enable-hid \
                           --with-gnu-ld \
                           ${BLUEZ_CONFIG} \
                           storagedir=/storage/.cache/bluetooth"

pre_configure_target() {
# bluez fails to build in subdirs
  cd ${PKG_BUILD}
    rm -rf .${TARGET_NAME}

  export LIBS="-lncurses -ltinfo"
}

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/lib/systemd
  safe_remove ${INSTALL}/usr/bin/bluemoon
  safe_remove ${INSTALL}/usr/bin/ciptool
  safe_remove ${INSTALL}/usr/share/dbus-1

  mkdir -p ${INSTALL}/etc/dbus-1/system.d
    cp src/bluetooth.conf ${INSTALL}/etc/dbus-1/system.d

  mkdir -p ${INSTALL}/etc/bluetooth
    cp src/main.conf ${INSTALL}/etc/bluetooth

  cat <<EOF >${INSTALL}/etc/bluetooth/input.conf
[General]
ClassicBondedOnly=false
EOF

  mkdir -p ${INSTALL}/usr/share/services
    cp -P ${PKG_DIR}/default.d/*.conf ${INSTALL}/usr/share/services


  # bluez looks in /etc/firmware/
    ln -sf /usr/lib/firmware ${INSTALL}/etc/firmware

  # libbluetooth required for bluez-alsa
  #  sed -i 's/-lbluetooth//g' ${PKG_BUILD}/lib/bluez.pc
    cp -P ${PKG_BUILD}/lib/bluez.pc ${SYSROOT_PREFIX}/usr/lib/pkgconfig
    cp -P -r ${PKG_BUILD}/lib/bluetooth ${SYSROOT_PREFIX}/usr/include/
}

post_install() {
  enable_service bluetooth-defaults.service
  enable_service bluetooth.service
  enable_service obex.service
}
