# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2018-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="util-linux"
PKG_VERSION="2.41"
PKG_SHA256="81ee93b3cfdfeb7d7c4090cedeba1d7bbce9141fd0b501b686b3fe475ddca4c6"
PKG_LICENSE="GPL"
PKG_URL="https://www.kernel.org/pub/linux/utils/util-linux/v$(get_pkg_version_maj_min)/${PKG_NAME}-${PKG_VERSION}.tar.xz"
PKG_DEPENDS_HOST="ccache:host autoconf:host automake:host intltool:host libtool:host pkg-config:host"
PKG_DEPENDS_TARGET="autotools:host gcc:host"
PKG_DEPENDS_INIT="autotools:host gcc:host"
PKG_LONGDESC="A large variety of low-level system utilities that are necessary for a Linux system to function."
PKG_TOOLCHAIN="autotools"
PKG_BUILD_FLAGS="+pic:host"

UTILLINUX_CONFIG_DEFAULT="--disable-gtk-doc \
                          --disable-nls \
                          --disable-rpath \
                          --enable-tls \
                          --enable-chsh-only-listed \
                          --disable-bash-completion \
                          --disable-colors-default \
                          --disable-pylibmount \
                          --disable-pg-bell \
                          --disable-use-tty-group \
                          --disable-makeinstall-chown \
                          --disable-makeinstall-setuid \
                          --with-gnu-ld \
                          --without-selinux \
                          --without-audit \
                          --without-udev \
                          --without-ncurses \
                          --without-ncursesw \
                          --without-readline \
                          --without-slang \
                          --without-tinfo \
                          --without-utempter \
                          --without-util \
                          --without-libz \
                          --without-user \
                          --without-systemd \
                          --without-smack \
                          --without-python \
                          --without-systemdsystemunitdir"

PKG_CONFIGURE_OPTS_TARGET="${UTILLINUX_CONFIG_DEFAULT} \
                           --disable-all-programs \
                           --enable-libuuid \
                           --enable-libblkid \
                           --enable-libmount \
                           --enable-libsmartcols \
                           --enable-losetup \
                           --enable-fsck \
                           --enable-fstrim \
                           --enable-blkid \
                           --enable-lscpu \
                           --enable-findmnt \
                           --enable-libsmartcols \
                           --enable-fallocate \
                           --enable-lsfd \
                           --enable-mount \
                           --enable-nologin"

if [ "${LOCAL_LOGIN}" = "yes" ]; then
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-agetty"
fi

if [ "${SWAP_SUPPORT}" = "yes" ]; then
  PKG_CONFIGURE_OPTS_TARGET+=" --enable-swapon"
fi

PKG_CONFIGURE_OPTS_HOST="--enable-static \
                         --disable-shared \
                         --enable-all-programs \
                         ${UTILLINUX_CONFIG_DEFAULT} \
                         --enable-uuidgen \
                         --enable-libuuid"

PKG_CONFIGURE_OPTS_INIT="${UTILLINUX_CONFIG_DEFAULT} \
                         --disable-all-programs \
                         --enable-libblkid \
                         --enable-libmount \
                         --enable-fsck"

if [ "${INITRAMFS_PARTED_SUPPORT}" = "yes" ]; then
  PKG_CONFIGURE_OPTS_INIT+=" --enable-mkfs --enable-libuuid"
fi

post_makeinstall_target() {
  if [ "${SWAP_SUPPORT}" = "yes" ]; then
    mkdir -p ${INSTALL}/usr/lib/rocknix
      cp -PR ${PKG_DIR}/scripts/mount-swap ${INSTALL}/usr/lib/rocknix

    mkdir -p ${INSTALL}/etc
      cat ${PKG_DIR}/config/swap.conf |
        sed -e "s,@SWAPFILESIZE@,${SWAPFILESIZE},g" \
            -e "s,@SWAP_ENABLED_DEFAULT@,${SWAP_ENABLED_DEFAULT},g" \
                -e "s,@SWAPSIZE@,${SWAPSIZE},g" \
                -e "s,@SWAP_DUAL@,${SWAP_DUAL},g" \
                -e "s,@USE_RESUME@,${USE_RESUME},g" \
                -e "s,@ENABLE_KSM@,${ENABLE_KSM},g" \
                -e "s,@ZRAM_COMPRESSION_ALGO@,${ZRAM_COMPRESSION_ALGO},g" \
                -e "s,@KSM_SCAN_PAGES@,${KSM_SCAN_PAGES},g" \
                -e "s,@KSM_SLEEP_MS@,${KSM_SLEEP_MS},g" \
            >${INSTALL}/etc/swap.conf
  fi
}

post_install()  {
  if [ "${SWAP_SUPPORT}" = "yes" ]; then
    enable_service swap.service
  fi
}
