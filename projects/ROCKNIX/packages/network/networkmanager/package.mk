# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="networkmanager"
PKG_VERSION="1.51.4"
PKG_LICENSE="GPL"
PKG_SITE="https://gitlab.freedesktop.org/NetworkManager/NetworkManager"
PKG_URL="https://download.gnome.org/sources/NetworkManager/1.51/NetworkManager-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain glib dbus libndp"
PKG_LONGDESC="Network connection manager"

PKG_MESON_OPTS_TARGET="
  -Dsystemdsystemunitdir=no
  -Dudev_dir=no
  -Ddbus_conf_dir=${INSTALL}/etc/dbus-1/system.d

  -Dsession_tracking_consolekit=false
  -Dsession_tracking=no
  -Dsuspend_resume=auto
  -Dpolkit=false
  -Dselinux=false
  -Dsystemd_journal=false
  -Dlibaudit=no
  -Dlibpsl=false
  -Dwifi=false
  -Dwext=false
  -Diwd=false
  -Dppp=false
  -Dmodem_manager=false
  -Dofono=false
  -Dconcheck=false
  -Dteamdctl=false
  -Dovs=false
  -Dnmcli=false
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
  -Dreadline=none
  -Dconfig_plugins_default=keyfile
  -Dcrypto=null
"

post_makeinstall_target() {
  rm -rf ${INSTALL}/home
  rm -rf ${INSTALL}/mnt
  rm -rf ${INSTALL}/usr/bin
  rm -rf ${INSTALL}/usr/sbin
  rm -rf ${INSTALL}/usr/share
  rm -rf ${INSTALL}/usr/include
  rm -rf ${INSTALL}/usr/lib/pkgconfig
  rm -rf ${INSTALL}/usr/lib/nm*
  rm -rf ${INSTALL}/usr/lib/NetworkManager

}
