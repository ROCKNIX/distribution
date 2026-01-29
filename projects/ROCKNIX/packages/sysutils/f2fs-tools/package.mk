PKG_NAME="f2fs-tools"
PKG_VERSION="1.16.0"
PKG_SHA256="208c7a07e95383fbd7b466b5681590789dcb41f41bf197369c41a95383b57c5e"
PKG_LICENSE="GPL"
PKG_SITE="https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git"
PKG_URL="https://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git/snapshot/${PKG_NAME}-${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain util-linux:target lz4:target lzo:target"
PKG_TOOLCHAIN="autotools"

PKG_LONGDESC="Tools for Flash-Friendly File System (F2FS)"
PKG_CONFIGURE_OPTS_TARGET="--prefix=/usr \
                           --bindir=/usr/bin \
                           --sbindir=/usr/sbin \
                           --enable-shared \
                           --disable-static \
                           --without-selinux \
                           --with-blkid \
                           --with-lzo2 \
                           --with-lz4"

makeinstall_target() {
  make install DESTDIR=${INSTALL}
}

post_makeinstall_target() {
  rm -rf ${INSTALL}/usr/include
  rm -rf ${INSTALL}/usr/share
  rm -rf ${INSTALL}/usr/lib/pkgconfig
  rm -f  ${INSTALL}/usr/lib/*.la
  rm -f ${INSTALL}/usr/sbin/sload.f2fs
  rm -f ${INSTALL}/usr/sbin/f2fs_io
  rm -f ${INSTALL}/usr/sbin/parse.f2fs
  rm -f ${INSTALL}/usr/sbin/defrag.f2fs
  rm -f ${INSTALL}/usr/sbin/dump.f2fs
  rm -f ${INSTALL}/usr/sbin/fibmap.f2fs
  rm -f ${INSTALL}/usr/sbin/f2fslabel
}

makeinstall_init() {
  mkdir -p ${INSTALL}/usr/sbin
  cp ${PKG_BUILD}/fsck/fsck.f2fs ${INSTALL}/usr/sbin/

  if [ "${INITRAMFS_PARTED_SUPPORT}" = "yes" ]; then
    cp ${PKG_BUILD}/mkfs/mkfs.f2fs ${INSTALL}/usr/sbin/
  fi
  
  ln -sf fsck.f2fs ${INSTALL}/usr/sbin/resize.f2fs
}
