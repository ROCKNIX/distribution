# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2018-present 5schatten (https://github.com/5schatten)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="SDL3"
PKG_VERSION="3.4.2"
PKG_LICENSE="Zlib"
PKG_SITE="https://www.libsdl.org/"
PKG_URL="https://www.libsdl.org/release/SDL3-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain alsa-lib systemd dbus pulseaudio pipewire libdrm libusb"
PKG_LONGDESC="Simple DirectMedia Layer is a cross-platform development library designed to provide low level access to audio, keyboard, mouse, joystick, and graphics hardware."
PKG_DEPENDS_HOST="toolchain:host distutilscross:host"

PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_HOST="
  -DBUILD_SHARED_LIBS=ON \
  -DSDL_SHARED=ON \
  -DSDL_STATIC=OFF \
  -DSDL_TEST_LIBRARY=OFF \
  -DSDL_TESTS=OFF \
  -DSDL_INSTALL_TESTS=OFF \
  -DSDL_EXAMPLES=OFF \
  -DSDL_ALSA=OFF \
  -DSDL_JACK=OFF \
  -DSDL_PIPEWIRE=OFF \
  -DSDL_PULSEAUDIO=OFF \
  -DSDL_SNDIO=OFF \
  -DSDL_OSS=OFF \
  -DSDL_WAYLAND=OFF \
  -DSDL_X11=OFF \
  -DSDL_KMSDRM=OFF \
  -DSDL_OPENGL=OFF \
  -DSDL_OPENGLES=OFF \
  -DSDL_VULKAN=OFF \
  -DSDL_HIDAPI_LIBUSB=OFF \
  -DSDL_LIBUDEV=OFF \
  -DSDL_DBUS=OFF \
  -DSDL_HIDAPI=OFF \
  -DSDL_RPATH=OFF \
  -DSDL_UNIX_CONSOLE_BUILD=ON"

if [ ! "${OPENGL_SUPPORT}" = "no" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu"
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGL=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGL=OFF"
fi

if [ "${OPENGLES_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGLES}"
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGLES=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_OPENGLES=OFF"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${VULKAN}"
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_VULKAN=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_VULKAN=OFF"
fi

if [ "${DISPLAYSERVER}" = "wl" ]; then
  PKG_DEPENDS_TARGET+=" wayland"
  case ${ARCH} in
    arm)
      true
      ;;
    *)
      PKG_DEPENDS_TARGET+=" ${WINDOWMANAGER}"
      ;;
  esac
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_WAYLAND=ON \
                           -DSDL_WAYLAND_SHARED=ON"
else
  PKG_CMAKE_OPTS_TARGET+=" -DSDL_WAYLAND=OFF \
                           -DSDL_WAYLAND_SHARED=OFF"
fi

case ${DEVICE} in
  RK*)
    PKG_DEPENDS_TARGET+=" librga"
    PKG_PATCH_DIRS_TARGET+="${DEVICE}"
    PKG_CMAKE_OPTS_TARGET+=" -DSDL_ROCKCHIP=ON"
  ;;
esac

pre_configure_target() {
  if [ -n "${PKG_PATCH_DIRS_TARGET}" ]; then
    if [ -d "${PKG_DIR}/patches/${PKG_PATCH_DIRS_TARGET}" ]; then
      cd $(get_build_dir SDL3)
      for PATCH in ${PKG_DIR}/patches/${PKG_PATCH_DIRS_TARGET}/*; do
        patch -p1 <${PATCH}
      done
      cd -
    fi
  fi

  export LDFLAGS="${LDFLAGS} -ludev"

  PKG_CMAKE_OPTS_TARGET+=" -DBUILD_SHARED_LIBS=ON \
                           -DSDL_SHARED=ON \
                           -DSDL_STATIC=OFF \
                           -DSDL_TEST_LIBRARY=OFF \
                           -DSDL_INSTALL_TESTS=OFF \
                           -DSDL_OSS=OFF \
                           -DSDL_ALSA=ON \
                           -DSDL_ALSA_SHARED=ON \
                           -DSDL_JACK=OFF \
                           -DSDL_JACK_SHARED=OFF \
                           -DSDL_SNDIO=OFF \
                           -DSDL_DISKAUDIO=OFF \
                           -DSDL_DUMMYAUDIO=OFF \
                           -DSDL_X11=OFF \
                           -DSDL_COCOA=OFF \
                           -DSDL_VIVANTE=OFF \
                           -DSDL_HIDAPI=ON \
                           -DSDL_HIDAPI_JOYSTICK=ON \
                           -DSDL_PTHREADS=ON \
                           -DSDL_PTHREADS_SEM=ON \
                           -DSDL_RPATH=OFF \
                           -DSDL_PIPEWIRE=ON \
                           -DSDL_PULSEAUDIO=ON \
                           -DSDL_LIBC=ON \
                           -DSDL_GCC_ATOMICS=ON \
                           -DSDL_KMSDRM=ON \
                           -DSDL_TESTS=OFF \
                           -DSDL_EXAMPLES=OFF"
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/bin
}