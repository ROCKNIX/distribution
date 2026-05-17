PKG_NAME="liburing"
PKG_VERSION="2.14"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/axboe/liburing"
PKG_URL="https://github.com/axboe/liburing/archive/refs/tags/liburing-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="make"

make_target() {
  make -C "${PKG_BUILD}" prefix=/usr
}

makeinstall_target() {
  make -C "${PKG_BUILD}" install prefix=/usr DESTDIR="${SYSROOT_PREFIX}"
  make -C "${PKG_BUILD}" install prefix=/usr DESTDIR="${INSTALL}"
}
