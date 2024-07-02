# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="weston11"
PKG_VERSION="11.0.3"

PKG_LICENSE="MIT"
PKG_SITE="https://wayland.freedesktop.org/"
PKG_URL="https://gitlab.freedesktop.org/wayland/weston/-/archive/${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain wayland wayland-protocols libdrm libxkbcommon libxcb-cursor libinput pipewire cairo pango libjpeg-turbo dbus seatd glu mesa libX11 xwayland libXcursor xkbcomp setxkbmap cairo xterm"
PKG_LONGDESC="Reference implementation of a Wayland compositor"
PKG_PATCH_DIRS+="${DEVICE}"

PKG_MESON_OPTS_TARGET="-Dbackend-drm=true \
                       -Dbackend-drm-screencast-vaapi=false \
                       -Dbackend-headless=false \
                       -Dbackend-rdp=false \
                       -Dscreenshare=false \
                       -Dbackend-wayland=true \
                       -Dbackend-x11=false \
                       -Dbackend-default=drm \
                       -Drenderer-gl=true \
                       -Dxwayland=true \
                       -Dsystemd=true \
                       -Dremoting=false \
                       -Dpipewire=true \
                       -Dshell-desktop=true \
                       -Dshell-fullscreen=true \
                       -Dshell-ivi=false \
                       -Dshell-kiosk=true \
                       -Ddesktop-shell-client-default="weston-desktop-shell" \
                       -Dcolor-management-lcms=false \
                       -Dlauncher-libseat=true \
                       -Dimage-jpeg=true \
                       -Dimage-webp=false \
                       -Dtools=['terminal']
                       -Ddemo-clients=false \
                       -Dsimple-clients=[] \
                       -Dresize-pool=false \
                       -Dwcap-decode=true \
                       -Dtest-junit-xml=false \
                       -Dtest-skip-is-failure=false \
                       -Ddoc=false"

pre_configure_target() {
  # weston does not build with NDEBUG (requires assert for tests)
  export TARGET_CFLAGS=$(echo ${TARGET_CFLAGS} | sed -e "s|-DNDEBUG||g")
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/weston
    cp ${PKG_DIR}/scripts/weston-config ${INSTALL}/usr/lib/weston

  mkdir -p ${INSTALL}/usr/share/weston
    cp ${PKG_DIR}/config/*ini ${INSTALL}/usr/share/weston

  safe_remove ${INSTALL}/usr/share/wayland-sessions

  for configfile in weston.ini kiosk.ini
  do
    sed -i -e "s|@WESTONFONTSIZE@|${WESTONFONTSIZE}|g" ${INSTALL}/usr/share/weston/${configfile}
  done

  if [ "${EMULATION_DEVICE}" = "yes" ] && \
     [ ! "${BASE_ONLY}" == true ]
  then
    cat <<EOF >>${INSTALL}/usr/share/weston/weston.ini

[launcher]
path=/usr/bin/start_es.sh
icon=/usr/config/emulationstation/resources/window_icon_24.png
EOF
  fi

}
