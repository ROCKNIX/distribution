# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2016-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="grub"
PKG_VERSION="2.14"
PKG_SHA256="6dcd64c4c5163870dd4cd89d460d1aa8f59b150e721a1e2b493f88433bc79ca9"
PKG_LICENSE="GPLv3"
PKG_SITE="https://www.gnu.org/software/grub/index.html"
# grub development moved off Savannah, whose cgit snapshots are gone. The
# tag carries the project prefix, so the ref is grub-${PKG_VERSION}; the
# archive's own top directory is stripped by scripts/extract.
PKG_URL="https://gitlab.freedesktop.org/gnu-grub/grub/-/archive/${PKG_NAME}-${PKG_VERSION}/${PKG_NAME}-${PKG_VERSION}.tar.gz"
# 2.14 configure.ac m4_fatal()s without AX_CHECK_LINK_FLAG, so ./bootstrap
# needs autoconf-archive; 2.14-rc1 did not. Both phases bootstrap.
PKG_DEPENDS_HOST="toolchain:host autoconf-archive:host"
PKG_DEPENDS_TARGET="toolchain flex freetype:host gettext:host grub:host autoconf-archive:host"
PKG_DEPENDS_UNPACK="gnulib"
PKG_LONGDESC="GRUB is a Multiboot boot loader."
PKG_TOOLCHAIN="configure"

PKG_NEED_UNPACK="${PROJECT_DIR}/${PROJECT}/bootloader ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/bootloader"
PKG_NEED_UNPACK+=" ${PROJECT_DIR}/${PROJECT}/options ${PROJECT_DIR}/${PROJECT}/devices/${DEVICE}/options"

pre_configure_host() {
  unset CFLAGS
  unset CPPFLAGS
  unset CXXFLAGS
  unset LDFLAGS
  unset CPP

  # autoconf-archive installs its macros into the sysroot, which is not on
  # aclocal's default search path, so bootstrap cannot see AX_CHECK_LINK_FLAG.
  export ACLOCAL_PATH="${SYSROOT_PREFIX}/usr/share/aclocal"

  cd ${PKG_BUILD}
    # keep grub synced with gnulib
    ./bootstrap --gnulib-srcdir=$(get_build_dir gnulib) --copy --no-git --no-bootstrap-sync --skip-po

  mkdir -p .${HOST_NAME}
    cd .${HOST_NAME}

  # GCC 15+ warns of character assignment that omits the terminal null
  # character.  This flag disables the warning.  GCC<15 should be unaffected.
  export CFLAGS="${CFLAGS} -Wno-unterminated-string-initialization"
}

pre_configure_target() {
  PKG_CONFIGURE_OPTS_TARGET="--target=arm64-pc-linux \
                             --disable-nls \
                             --with-platform=efi"

  unset CFLAGS
  unset CPPFLAGS
  unset CXXFLAGS
  unset LDFLAGS
  unset CPP

  # autoconf-archive installs its macros into the sysroot, which is not on
  # aclocal's default search path, so bootstrap cannot see AX_CHECK_LINK_FLAG.
  export ACLOCAL_PATH="${SYSROOT_PREFIX}/usr/share/aclocal"

  cd ${PKG_BUILD}
    # keep grub synced with gnulib
    ./bootstrap --gnulib-srcdir=$(get_build_dir gnulib) --copy --no-git --no-bootstrap-sync --skip-po

  mkdir -p .${TARGET_NAME}
    cd .${TARGET_NAME}

  # configure requires explicit TARGET_PREFIX binaries when cross compiling.
  export TARGET_CC="${TARGET_PREFIX}gcc"
  export TARGET_OBJCOPY="${TARGET_PREFIX}objcopy"
  export TARGET_STRIP="${TARGET_PREFIX}strip"
  export TARGET_NM="${TARGET_PREFIX}nm"
  export TARGET_RANLIB="${TARGET_PREFIX}ranlib"
}

make_target() {
  # glibc 2.44 makes strchr and friends C23 const-generic, so given a
  # "const char *" they now return "const char *". util/resolve.c assigns
  # that to a plain "char *" and grub builds -Werror. The result is only
  # tested for NULL there, so losing the qualifier changes nothing, and
  # upstream still carries the same line.
  make CC=${CC} \
       AR=${AR} \
       RANLIB=${RANLIB} \
       CFLAGS="-I${SYSROOT_PREFIX}/usr/include -fomit-frame-pointer -D_FILE_OFFSET_BITS=64 -Wno-error=discarded-qualifiers" \
       LDFLAGS="-L${SYSROOT_PREFIX}/usr/lib"
}

makeinstall_target() {
  ${PKG_BUILD}/.${HOST_NAME}/grub-mkimage -d grub-core -o bootaa64.efi -O arm64-efi -p /boot/grub \
    boot linux ext2 fat squash4 part_msdos part_gpt normal search search_fs_file search_fs_uuid \
    search_label chain reboot loadenv test gfxterm efi_gop

  mkdir -p ${INSTALL}/usr/share/bootloader/boot/grub
    cp -av ${PKG_DIR}/config/* ${INSTALL}/usr/share/bootloader/boot/grub

  mkdir -p ${INSTALL}/usr/share/bootloader/EFI/BOOT
    cp -av bootaa64.efi ${INSTALL}/usr/share/bootloader/EFI/BOOT

  # Create grub configuration
  generate_grub_cfg_body > "${INSTALL}/usr/share/bootloader/boot/grub/grub.cfg"

}
