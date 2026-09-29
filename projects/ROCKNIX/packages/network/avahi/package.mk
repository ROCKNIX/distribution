# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="avahi"
PKG_VERSION="0.8"
PKG_SHA256="c15e750ef7c6df595fb5f2ce10cac0fee2353649600e6919ad08ae8871e4945f"
PKG_LICENSE="GPL"
PKG_SITE="http://avahi.org/"
PKG_URL="https://github.com/lathiat/avahi/archive/v${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="autotools:host gcc:host expat libdaemon dbus gettext"
PKG_LONGDESC="Service Discovery for Linux using mDNS/DNS-SD, compatible with Bonjour."
PKG_TOOLCHAIN="configure"

PKG_CONFIGURE_OPTS_TARGET="py_cv_mod_gtk_=yes \
                           py_cv_mod_dbus_=yes \
                           ac_cv_func_chroot=no \
                           --with-distro=none \
                           --disable-glib \
                           --disable-gobject \
                           --disable-qt3 \
                           --disable-qt4 \
                           --disable-qt5 \
                           --disable-gtk \
                           --disable-gtk3 \
                           --enable-dbus \
                           --disable-dbm \
                           --disable-gdbm \
                           --enable-libdaemon \
                           --disable-python \
                           --disable-python-dbus \
                           --disable-mono \
                           --disable-monodoc \
                           --disable-autoipd \
                           --disable-doxygen-doc \
                           --disable-doxygen-dot \
                           --disable-doxygen-man \
                           --disable-doxygen-rtf \
                           --disable-doxygen-xml \
                           --disable-doxygen-chm \
                           --disable-doxygen-chi \
                           --disable-doxygen-html \
                           --disable-doxygen-ps \
                           --disable-doxygen-pdf \
                           --disable-core-docs \
                           --disable-manpages \
                           --disable-xmltoman \
                           --disable-tests \
                           --disable-libevent \
                           --enable-compat-libdns_sd \
                           --disable-compat-howl \
                           --disable-rpath \
                           --with-xml=expat \
                           --with-avahi-user=avahi \
                           --with-avahi-group=avahi \
                           --disable-nls"

pre_configure_target() {
  NOCONFIGURE=1 ./autogen.sh
}

post_configure_target() {
  libtool_remove_rpath libtool
}

post_makeinstall_target() {
  # disable wide-area
  sed -e "s,^.*enable-wide-area=.*$,enable-wide-area=no,g" -i ${INSTALL}/etc/avahi/avahi-daemon.conf
  # publish-hinfo
  sed -e "s,^.*publish-hinfo=.*$,publish-hinfo=no,g" -i ${INSTALL}/etc/avahi/avahi-daemon.conf
  # publish-workstation
  sed -e "s,^.*publish-workstation=.*$,publish-workstation=no,g" -i ${INSTALL}/etc/avahi/avahi-daemon.conf
  # browse domains?
  sed -e "s,^.*browse-domains=.*$,# browse-domains=,g" -i ${INSTALL}/etc/avahi/avahi-daemon.conf
  # set root user as default
  sed -e "s,<port>22</port>,<port>22</port>\n    <txt-record>path=/storage</txt-record>\n    <txt-record>u=root</txt-record>,g" -i ${INSTALL}/etc/avahi/services/sftp-ssh.service

  rm -rf ${INSTALL}/etc/avahi/avahi-dnsconfd.action
  if [ ! ${SFTP_SERVER} = "yes" ]; then
    rm -rf ${INSTALL}/etc/avahi/services/ssh.service
    rm -rf ${INSTALL}/etc/avahi/services/sftp-ssh.service
  fi
  # avahi's own units go, as in the generic recipe: scripts/install copies
  # this package's system.d/ into the image first and extracts the package's
  # make-install tree over it, so with these left in place the stock
  # avahi-daemon.service (socket-activated, no ordering, no off-switch)
  # replaced the fork's and the daemon published whatever the kernel was
  # called when the socket woke it -- ROCKNIX.local on a device named
  # GENERIC-X64-0964 (#151 PL-01). This line was the one the override lacked.
  rm -rf ${INSTALL}/usr/lib/systemd
  rm -f ${INSTALL}/usr/share/dbus-1/system-services/org.freedesktop.Avahi.service
  rm -f ${INSTALL}/usr/sbin/avahi-dnsconfd
  rm -f ${INSTALL}/usr/bin/avahi-bookmarks
  rm -f ${INSTALL}/usr/bin/avahi-publish*
  rm -f ${INSTALL}/usr/bin/avahi-resolve*
  rm -f ${INSTALL}/usr/lib/libdns_sd*

  mkdir -p ${INSTALL}/usr/share/services
    cp -P ${PKG_DIR}/default.d/*.conf ${INSTALL}/usr/share/services
}

post_install() {
  add_user avahi x 70 70 "avahi-daemon" "/var/run/avahi-daemon" "/bin/sh"
  add_group avahi 70

  enable_service avahi-defaults.service
  # The responder is on (fork #50, D-NET-003, the maintainer's call of
  # 2026-09-13): with it off since the first ROCKNIX commit a device could
  # resolve other .local names (nss-mdns) but never answer for its own, and
  # two same-family units on one network were addressable by neither name
  # nor lease. It publishes the kernel hostname, which network-base-setup
  # has made this unit's own by the time the daemon starts (the unit orders
  # after it, and network-base-setup tells a daemon that is somehow already
  # up). Off is two files: remove /storage/.cache/services/avahi.conf and
  # create avahi.disabled beside it -- the unit conditions on the conf, and
  # avahi-defaults.service (pulled in by Requires=, no [Install] of its own)
  # re-creates the conf at the next start unless .disabled is there.
  enable_service avahi-daemon.service
}
