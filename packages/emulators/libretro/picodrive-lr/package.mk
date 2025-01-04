PKG_NAME="picodrive-lr"
PKG_VERSION="bb4b7bcddb9f2f218e88971cccc66edf6c7669f0"
PKG_LICENSE="MAME"
PKG_SITE="https://github.com/libretro/picodrive"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="Libretro implementation of PicoDrive. (Sega Megadrive/Genesis/Sega Master System/Sega GameGear/Sega CD/32X)"
GET_HANDLER_SUPPORT="git"
PKG_BUILD_FLAGS="-gold"
PKG_TOOLCHAIN="make"

PKG_PATCH_DIRS="${PROJECT}"

pre_configure_target() {
export CFLAGS="${CFLAGS} -Wno-error=incompatible-pointer-types"
}

configure_target() {
  :
}

make_target() {
  cd ${PKG_BUILD}
#  ${PKG_BUILD}/configure --platform=generic
  make -f Makefile.libretro
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/libretro
  cp ${PKG_BUILD}/picodrive_libretro.so ${INSTALL}/usr/lib/libretro/
}
