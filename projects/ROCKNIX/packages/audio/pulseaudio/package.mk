# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

. ${ROOT}/packages/audio/pulseaudio/package.mk

if [ "${AVAHI_DAEMON}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" avahi"
  PKG_PULSEAUDIO_AVAHI="-Davahi=enabled"
else
  PKG_PULSEAUDIO_AVAHI="-Davahi=disabled"
fi

PKG_MESON_OPTS_TARGET="-Ddaemon=false \
                       -Ddoxygen=false \
                       -Dgcov=false \
                       -Dman=false \
                       -Dtests=false \
                       -Dsystem_user=root \
                       -Dsystem_group=root \
                       -Daccess_group=root \
                       -Ddatabase=simple \
                       -Dlegacy-database-entry-format=false \
                       -Dstream-restore-clear-old-devices=false \
                       -Drunning-from-build-tree=false \
                       -Datomic-arm-linux-helpers=true \
                       -Datomic-arm-memory-barrier=false \
                       -Dmodlibexecdir=/usr/lib/pulse \
                       -Dudevrulesdir=/usr/lib/udev/rules.d \
                       -Dalsa=disabled \
                       -Dasyncns=disabled \
                       ${PKG_PULSEAUDIO_AVAHI} \
                       -Dbluez5=disabled
                       -Dbluez5-gstreamer=disabled \
                       -Ddbus=disabled \
                       -Delogind=disabled \
                       -Dfftw=disabled \
                       -Dglib=enabled \
                       -Dgsettings=disabled \
                       -Dgstreamer=disabled \
                       -Dgtk=disabled \
                       -Dhal-compat=false \
                       -Dipv6=true \
                       -Djack=disabled \
                       -Dlirc=disabled \
                       -Dopenssl=disabled \
                       -Dorc=disabled \
                       -Doss-output=disabled \
                       -Dsamplerate=disabled \
                       -Dsoxr=enabled \
                       -Dspeex=enabled \
                       -Dsystemd=disabled \
                       -Dtcpwrap=disabled \
                       -Dudev=disabled \
                       -Dvalgrind=disabled \
                       -Dx11=disabled \
                       -Dadrian-aec=true \
                       -Dwebrtc-aec=disabled"

pre_configure_target() {
  sed -e 's|; remixing-use-all-sink-channels = yes|; remixing-use-all-sink-channels = no|' \
      -i ${PKG_BUILD}/src/daemon/daemon.conf.in
}

post_makeinstall_target() {
  safe_remove ${INSTALL}/usr/include
  safe_remove ${INSTALL}/usr/lib/cmake
  safe_remove ${INSTALL}/usr/lib/pkgconfig
  safe_remove ${INSTALL}/usr/lib/systemd
  safe_remove ${INSTALL}/usr/share/vala
  safe_remove ${INSTALL}/usr/share/zsh
  safe_remove ${INSTALL}/usr/share/bash-completion

  cp ${PKG_DIR}/config/system.pa ${INSTALL}/etc/pulse/
}

post_install() {
  :
}
