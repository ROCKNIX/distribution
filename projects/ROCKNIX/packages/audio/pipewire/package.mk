# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="pipewire"
PKG_VERSION="1.6.8"
PKG_SHA256="8181172a1d95131f6af8bbc0b98f90b2a33349b042b84c3ce57dd5d11348cc58"
PKG_LICENSE="MIT"
PKG_SITE="https://pipewire.org"
PKG_URL="https://github.com/PipeWire/pipewire/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain libpthread-stubs dbus glib ncurses alsa-lib pulseaudio systemd libsndfile libusb"
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
  PKG_DEPENDS_TARGET+=" vulkan-loader vulkan-headers"
  PKG_PIPEWIRE_VULKAN="-Dvulkan=enabled"
else
  PKG_PIPEWIRE_VULKAN="-Dvulkan=disabled"
fi

PKG_MESON_OPTS_TARGET="-Ddocs=disabled \
                       -Dexamples=disabled \
                       -Dman=disabled \
                       -Dtests=disabled \
                       -Dinstalled_tests=disabled \
                       -Dgstreamer=disabled \
                       -Dgstreamer-device-provider=disabled \
                       -Dlibsystemd=enabled \
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
                       -Dx11=disabled \
                       -Dx11-xfixes=disabled \
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

# Latency floors. The devices below cannot keep up with the stock 32-frame
# quantum, so they were carrying near-identical copies of the same two
# patches against upstream's shipped configuration; both files support
# drop-ins, which is where per-device policy belongs.
case ${DEVICE} in
  SM6115|SM8550|SM8650|SM8750)
    PKG_PIPEWIRE_QUANTUM="960"
    PKG_PIPEWIRE_PULSE_QUANTUM="960"
    ;;
  SM8250)
    PKG_PIPEWIRE_PULSE_QUANTUM="1024"
    # was a patch setting rt.prio in the module-rt args; module-rt defaults
    # rt.prio to RTPRIO_CLIENT, so the build option reaches the same place.
    PKG_MESON_OPTS_TARGET+=" -Drtprio-client=99"
    ;;
esac

pre_configure_target() {
  export TARGET_CFLAGS="${TARGET_CFLAGS} -Wno-error=float-conversion"
  export TARGET_LDFLAGS="${TARGET_LDFLAGS} -lncursesw -ltinfow"
}

post_makeinstall_target() {
  # 1.6 started installing pipewire-pulse.service and pipewire-pulse.socket.
  # scripts/install copies system.d/ first and then untars the package on top,
  # so upstream's units would win and pipewire-pulse would come up as the
  # pipewire user with no XDG_RUNTIME_DIR or HOME. Install ours from here,
  # where they are part of the package and cannot be overwritten.
  cp ${PKG_DIR}/system.d/pipewire-pulse.service ${PKG_DIR}/system.d/pipewire-pulse.socket \
     ${INSTALL}/usr/lib/systemd/system

  # Latency floors, per device. Drop-ins are merged key by key onto the
  # shipped configuration, so only the values we care about are named.
  if [ -n "${PKG_PIPEWIRE_QUANTUM}" ]; then
    mkdir -p ${INSTALL}/usr/share/pipewire/pipewire.conf.d
    cat >${INSTALL}/usr/share/pipewire/pipewire.conf.d/50-rocknix-latency.conf <<EOF
context.properties = {
    default.clock.min-quantum = ${PKG_PIPEWIRE_QUANTUM}
}
EOF
  fi

  if [ -n "${PKG_PIPEWIRE_PULSE_QUANTUM}" ]; then
    mkdir -p ${INSTALL}/usr/share/pipewire/pipewire-pulse.conf.d
    cat >${INSTALL}/usr/share/pipewire/pipewire-pulse.conf.d/50-rocknix-latency.conf <<EOF
pulse.properties = {
    pulse.min.req     = ${PKG_PIPEWIRE_PULSE_QUANTUM}/48000
    pulse.min.frag    = ${PKG_PIPEWIRE_PULSE_QUANTUM}/48000
    pulse.min.quantum = ${PKG_PIPEWIRE_PULSE_QUANTUM}/48000
}
EOF
  fi
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
