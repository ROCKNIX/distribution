# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="networkmanager"
PKG_VERSION="1.51.4"
PKG_LICENSE="GPL"
PKG_SITE="https://gitlab.freedesktop.org/NetworkManager/NetworkManager"
PKG_URL="https://download.gnome.org/sources/NetworkManager/1.51/NetworkManager-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain glib dbus libndp nss nspr systemd util-linux readline ncurses"
PKG_LONGDESC="Network connection manager (Ethernet and Wi-Fi; Wi-Fi via iwd backend)"
PKG_TOOLCHAIN="meson"

PKG_MESON_OPTS_TARGET="
  -Dsystemdsystemunitdir=no
  -Dudev_dir=no
  -Ddbus_conf_dir=/etc/dbus-1/system.d

  -Dsession_tracking=no
  -Dsession_tracking_consolekit=false
  -Dsuspend_resume=auto
  -Dpolkit=false
  -Dselinux=false
  -Dsystemd_journal=false
  -Dlibaudit=no
  -Dlibpsl=false
  -Dwifi=true
  -Dwext=false
  -Diwd=true
  -Dconfig_wifi_backend_default=iwd
  -Dppp=false
  -Dmodem_manager=false
  -Dofono=false
  -Dconcheck=false
  -Dteamdctl=false
  -Dovs=false
  -Dnmcli=true
  -Dnmtui=false
  -Dnm_cloud_setup=false
  -Dbluez5_dun=false
  -Debpf=false
  -Difcfg_rh=false
  -Difupdown=false
  -Ddhclient=no
  -Ddhcpcd=no
  -Dconfig_dhcp_default=internal
  -Dintrospection=false
  -Dvapi=false
  -Ddocs=false
  -Dtests=no
  -Dfirewalld_zone=false
  -Dmore_logging=false
  -Dvalgrind=no
  -Dqt=false
  -Dreadline=auto
  -Dconfig_plugins_default=keyfile
  -Dcrypto=nss
"

post_makeinstall_target() {
  rm -rf ${INSTALL}/home
  rm -rf ${INSTALL}/mnt
  rm -rf ${INSTALL}/usr/include
  rm -rf ${INSTALL}/usr/lib/pkgconfig
  find ${INSTALL}/usr/lib -name "*.a" -delete
  find ${INSTALL}/usr/lib -name "*.la" -delete
  rm -rf ${INSTALL}/usr/share/locale

  mkdir -p ${INSTALL}/etc/NetworkManager/conf.d
  cp -P ${PKG_DIR}/config/NetworkManager.conf ${INSTALL}/etc/NetworkManager/NetworkManager.conf

  mkdir -p ${INSTALL}/etc/dbus-1/system.d
  cp -P ${PKG_DIR}/dbus.d/org.freedesktop.NetworkManager.conf ${INSTALL}/etc/dbus-1/system.d/

  mkdir -p ${INSTALL}/usr/lib/tmpfiles.d
  cp -P ${PKG_DIR}/tmpfiles.d/z_02_networkmanager.conf ${INSTALL}/usr/lib/tmpfiles.d/
}

post_install() {
  enable_service NetworkManager.service
  enable_service network-online.service
}
