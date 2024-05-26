# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pulseaudio"
PKG_VERSION="17.0"
PKG_LICENSE="GPL"
PKG_SITE="http://pulseaudio.org/"
PKG_URL="http://www.freedesktop.org/software/pulseaudio/releases/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_TARGET="toolchain libcap libsndfile libtool soxr speexdsp glib:host glib"
PKG_LONGDESC="PulseAudio is a sound system for POSIX OSes, meaning that it is a proxy for your sound applications."

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
  safe_remove ${INSTALL}/usr/share/vala
  safe_remove ${INSTALL}/usr/share/zsh
  safe_remove ${INSTALL}/usr/share/bash-completion

  cp ${PKG_DIR}/config/system.pa ${INSTALL}/etc/pulse/

  # Sometimes apps cannot load `libpulsecommon`. It is located in ${libdir}/pulseaudio and is not intended to be loaded directly.
  # Application loads `libpulse.so.0`, `libpulse` has `libpulsecommon` as a dep and RPATH set to ${libdir}/pulseaudio
  # So, if there is error loading `libpulsecommon`, check RPATH of `libpulse` and `libpulse-simple`
  # Adding pulseaudio subdir to `/etc/ld.so.conf.d/*.conf` may be a working hack for that, but please check/fix RPATH first
}

# Deprecated by pipewire
#post_install() {
#  enable_service pulseaudio.service
#}
