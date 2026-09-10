# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="box86"
PKG_VERSION="39d3ed203323000c11f47b780f7468fa24a7185d"
PKG_SHA256="0b01cfe0c7e1af14f52d8ebcc36fe8b47ff2d8d6a06cb423f3e4069ac4466f56"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/ptitSeb/box86"
PKG_URL="${PKG_SITE}/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain ncurses SDL2 libXdmcp libXft libXcomposite cups libogg"
PKG_LONGDESC="Box86 lets you run x86 Linux programs (such as games) on non-x86 Linux systems, like ARM."
PKG_TOOLCHAIN="cmake"

PKG_CMAKE_OPTS_TARGET="-DCMAKE_BUILD_TYPE=Release \
                       -DARM_DYNAREC=On \
                       -DCMAKE_C_FLAGS=\"-w\""

case ${TARGET_ARCH} in
  aarch64)
    PKG_DEPENDS_TARGET=""
    unpack() {
      true
    }
    configure_target() {
      true
    }
    make_target() {
      true
    }
    ;;
esac

case ${DEVICE} in
  RK3588)
    PKG_CMAKE_OPTS_TARGET+=" -DRK3588=On"
    ;;
  SM8250)
    PKG_CMAKE_OPTS_TARGET+=" -DSD865=On"
    ;;
  SM8550)
    PKG_CMAKE_OPTS_TARGET+=" -DSD8G2=On"
    ;;
  RK3399)
    PKG_CMAKE_OPTS_TARGET+=" -DRK3399=On"
    ;;
  RK3326)
    PKG_CMAKE_OPTS_TARGET+=" -DGOA_CLONE=On"
    ;;
  S922X|SM6115)
    PKG_CMAKE_OPTS_TARGET+=" -DODROIDN2=On"
    ;;
esac

makeinstall_target() {
  case ${TARGET_ARCH} in
    arm)
      mkdir -p ${INSTALL}/usr/share/box86/lib
        cp ${PKG_BUILD}/x86lib/* ${INSTALL}/usr/share/box86/lib

      mkdir -p ${INSTALL}/usr/bin
        cp ${PKG_BUILD}/.${TARGET_NAME}/box86 ${INSTALL}/usr/bin/
        cp ${PKG_BUILD}/tests/bash ${INSTALL}/usr/bin/bash-x86

      mkdir -p ${INSTALL}/etc/binfmt.d
      cp ${PKG_BUILD}/.${TARGET_NAME}/system/box86.conf ${INSTALL}/etc/binfmt.d
      ;;
    aarch64)
      mkdir -p ${INSTALL}/usr/share/box86/lib
        cp -vP ${ROOT}/build.${DISTRO}-${DEVICE}.arm/install_pkg/${PKG_NAME}-*/usr/share/box86/lib/* ${INSTALL}/usr/share/box86/lib

      mkdir -p ${INSTALL}/usr/bin
        cp -vP ${ROOT}/build.${DISTRO}-${DEVICE}.arm/install_pkg/${PKG_NAME}-*/usr/bin/* ${INSTALL}/usr/bin

      mkdir -p ${INSTALL}/usr/config
        cp -vP ${ROOT}/build.${DISTRO}-${DEVICE}.arm/install_pkg/${PKG_NAME}-*/usr/config/box86.box86rc ${INSTALL}/usr/config/box86.box86rc

      mkdir -p ${INSTALL}/etc/binfmt.d
        cp -vP ${ROOT}/build.${DISTRO}-${DEVICE}.arm/install_pkg/${PKG_NAME}-*/etc/binfmt.d/box86.conf ${INSTALL}/etc/binfmt.d
      ;;
  esac

  mkdir -p ${INSTALL}/usr/config
    cp ${ROOT}/build.${DISTRO}-${DEVICE}.arm/build/${PKG_NAME}-*/system/box86.box86rc ${INSTALL}/usr/config/box86.box86rc

  mkdir -p ${INSTALL}/etc
    ln -sf /storage/.config/box86.box86rc ${INSTALL}/etc/box86.box86rc
}

if [ ! "${ENABLE_32BIT}" == "true" ]; then
  makeinstall_target() {
    true
  }
fi
