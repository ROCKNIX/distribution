# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pipewire"
PKG_VERSION="1.2.5"
PKG_LICENSE="LGPL"
PKG_SITE="https://pipewire.org"
PKG_URL="https://github.com/PipeWire/pipewire/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libpthread-stubs dbus ncurses alsa-lib pulseaudio systemd libsndfile libusb"
PKG_LONGDESC="PipeWire is a server and user space API to deal with multimedia pipeline"
PKG_PATCH_DIRS+=" ${DEVICE}"

if [ "${BLUETOOTH_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" bluez sbc ldacBT libfreeaptx fdk-aac"
  PKG_PIPEWIRE_BLUETOOTH="-Dbluez5=enabled \
                          -Dbluez5-backend-hsp-native=disabled \
                          -Dbluez5-backend-hfp-native=disabled \
                          -Dbluez5-backend-ofono=disabled \
                          -Dbluez5-backend-hsphfpd=disabled \
                          -Dbluez5-codec-aptx=enabled \
                          -Dbluez5-codec-lc3plus=disabled \
                          -Dbluez5-codec-ldac=enabled \
                          -Dbluez5-codec-aac=enabled"
else
  PKG_PIPEWIRE_BLUETOOTH="-Dbluez5=disabled"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_PIPEWIRE_VULKAN+="-Dvulkan=enabled \
                        -Dx11=disabled \
                        -Dx11-xfixes=disabled"
fi

PKG_MESON_OPTS_TARGET="-Ddocs=disabled \
                       -Dexamples=disabled \
                       -Dman=disabled \
                       -Dtests=disabled \
                       -Dinstalled_tests=disabled \
                       -Dgstreamer=disabled \
                       -Dgstreamer-device-provider=disabled \
                       -Dsystemd=enabled \
                       -Dsystemd-system-service=enabled \
                       -Dsystemd-user-service=disabled \
                       -Dpipewire-alsa=enabled \
                       -Dpipewire-jack=disabled \
                       -Dpipewire-v4l2=disabled \
                       -Djack-devel=false
                       -Dspa-plugins=enabled \
                       -Dalsa=enabled \
                       -Daudiomixer=enabled \
                       -Daudioconvert=enabled \
                       ${PKG_PIPEWIRE_BLUETOOTH} \
                       -Dcontrol=enabled \
                       -Daudiotestsrc=disabled \
                       -Dffmpeg=disabled \
                       -Djack=disabled \
                       -Dsupport=enabled \
                       -Devl=disabled \
                       -Dtest=disabled \
                       -Dv4l2=disabled \
                       -Ddbus=enabled \
                       -Dlibcamera=disabled \
                       -Dvideoconvert=disabled \
                       -Dvideotestsrc=disabled \
                       -Dvolume=enabled \
                       ${PKG_PIPEWIRE_VULKAN} \
                       -Dpw-cat=enabled \
                       -Dudev=enabled \
                       -Dudevrulesdir=/usr/lib/udev/rules.d \
                       -Dsdl2=disabled \
                       -Dsndfile=enabled \
                       -Dlibpulse=enabled \
                       -Droc=disabled \
                       -Davahi=disabled \
                       -Decho-cancel-webrtc=disabled \
                       -Dlibusb=enabled \
                       -Dsession-managers=[] \
                       -Draop=disabled \
                       -Dlv2=disabled \
                       -Dlibcanberra=disabled \
                       -Dlegacy-rtkit=false"

pre_configure_target() {
  export TARGET_CFLAGS="${TARGET_CFLAGS} -Wno-error=float-conversion"
  export TARGET_LDFLAGS="${TARGET_LDFLAGS} -lncursesw -ltinfow"
}

post_install() {
  add_user pipewire x 982 980 "pipewire-daemon" "/var/run/pipewire" "/bin/sh"
  add_group pipewire 980
  mkdir -p ${INSTALL}/etc/alsa/conf.d
  ln -sf /usr/share/alsa/alsa.conf.d/50-pipewire.conf ${INSTALL}/etc/alsa/conf.d/50-pipewire.conf
  ln -sf /usr/share/alsa/alsa.conf.d/99-pipewire-default.conf ${INSTALL}/etc/alsa/conf.d/99-pipewire-default.conf
  enable_service pipewire.socket
  enable_service pipewire.service
  enable_service pipewire-pulse.socket
  enable_service pipewire-pulse.service
}
