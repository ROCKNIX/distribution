PKG_NAME="joystick"
PKG_VERSION="008430b6c6cbc8028bea57a7b4f89514db4d19db"
PKG_LICENSE="GNU"
PKG_SITE="https://salsa.debian.org/debian"
PKG_URL="${PKG_SITE}/joystick.git"
PKG_DEPENDS_TARGET="toolchain SDL2"
PKG_TOOLCHAIN="make"
PKG_LONGDESC="joystick utilities for the Linux joystick driver"

makeinstall_target() {
  echo ${INSTALL}
  mkdir -p ${INSTALL}/usr/bin
  cp utils/evdev-joystick ${INSTALL}/usr/bin/
  cp utils/jscal ${INSTALL}/usr/bin/
  cp utils/jscal-store ${INSTALL}/usr/bin/
  cp utils/jscal-restore ${INSTALL}/usr/bin/
  cp utils/jstest ${INSTALL}/usr/bin/
}

pre_make_target() {
  make clean
}
