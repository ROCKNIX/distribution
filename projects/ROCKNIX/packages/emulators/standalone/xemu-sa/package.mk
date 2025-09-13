# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)

PKG_NAME="xemu-sa"
PKG_VERSION="c67843384031e0edaab3db91ec496464b931789b"
PKG_LICENSE="GPLv3"
PKG_SITE="https://github.com/xemu-project/xemu"
PKG_URL="${PKG_SITE}.git"
PKG_DEPENDS_TARGET="toolchain libthai gtk3 libsamplerate libpcap atk SDL2 Python3 zlib pixman bzip2 openssl xwayland libslirp"
PKG_LONGDESC="Xemu - A free and open-source application that emulates the original Microsoft Xbox game console."
PKG_TOOLCHAIN="make"
PKG_PATCH_DIRS+="${DEVICE}"

# Open source xbox hdd image
PKG_HDD_IMAGE="https://github.com/xqemu/xqemu-hdd-image/releases/download/v1.0/xbox_hdd.qcow2.zip"

if [ "${OPENGL_SUPPORT}" = "yes" ]; then
  PKG_DEPENDS_TARGET+=" ${OPENGL} glu libglvnd"
fi

if [ "${VULKAN_SUPPORT}" = "yes" ]
then
  PKG_DEPENDS_TARGET+=" ${VULKAN} glslang"
fi

pre_configure_target() {
  # xemu does not build with NDEBUG
  export TARGET_CFLAGS=$(echo ${TARGET_CFLAGS} | sed -e "s|-DNDEBUG||g")
  export TARGET_CXXFLAGS=$(echo ${TARGET_CXXFLAGS} | sed -e "s|-DNDEBUG||g")
  export CFLAGS=$(echo ${CFLAGS} | sed -e "s|-DNDEBUG||g")
  export CXXFLAGS=$(echo ${CXXFLAGS} | sed -e "s|-DNDEBUG||g")
  export DONT_BUILD_LEGACY_PYC=1

  # Download Sub Modules
  ### xxHash
  mkdir -p ${PKG_BUILD}/subprojects/
  curl -Lo ${PKG_BUILD}/subprojects/xxhash.tar.gz http://github.com/mesonbuild/wrapdb/releases/download/xxhash_0.8.3-1/xxHash-0.8.3.tar.gz
  tar -xvf ${PKG_BUILD}/subprojects/xxhash.tar.gz -C ${PKG_BUILD}/subprojects/
  curl -Lo ${PKG_BUILD}/subprojects/xxhash_0.8.3-1_patch.zip https://wrapdb.mesonbuild.com/v2/xxhash_0.8.3-1/get_patch
  unzip -o ${PKG_BUILD}/subprojects/xxhash_0.8.3-1_patch.zip -d ${PKG_BUILD}/subprojects
  rm -rf ${PKG_BUILD}/subprojects/xxhash.tar.gz
  rm -rf ${PKG_BUILD}/subprojects/xxhash_0.8.3-1_patch.zip
}

make_target() {
  cd ${PKG_BUILD}
 ./build.sh --target-list=i386-softmmu \
            --cross-prefix="${TARGET_PREFIX}" \
            --host="${TARGET_NAME}" \
            --enable-sdl \
            --enable-opengl \
            --enable-trace-backends="nop" \
            --disable-kvm \
            --disable-xen \
            --disable-werror \
            --disable-curl \
            --disable-vnc \
            --disable-vnc-sasl \
            --disable-docs \
            --disable-tools \
            --disable-guest-agent \
            --disable-tpm \
            --disable-rdma \
            --disable-replication \
            --disable-capstone \
            --disable-libiscsi \
            --disable-spice \
            --disable-user \
            --disable-stack-protector \
            --disable-glusterfs \
            --disable-curses \
            --disable-gnutls \
            --disable-nettle \
            --disable-gcrypt \
            --disable-crypto-afalg \
            --disable-virglrenderer \
            --disable-vhost-net \
            --disable-vhost-crypto \
            --disable-vhost-user \
            --disable-virtfs \
            --disable-snappy \
            --disable-bzip2 \
            --disable-vde \
            --disable-seccomp \
            --disable-numa \
            --disable-lzo \
            --disable-smartcard \
            --disable-usb-redir \
            --disable-bochs \
            --disable-cloop \
            --disable-dmg \
            --disable-vdi \
            --disable-vvfat \
            --disable-qcow1 \
            --disable-qed \
            --disable-parallels \
            --disable-hvf \
            --disable-whpx \
            --with-default-devices
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -p ${PKG_BUILD}/dist/xemu ${INSTALL}/usr/bin
  cp -rf ${PKG_DIR}/scripts/start_xemu.sh ${INSTALL}/usr/bin
  chmod 755 ${INSTALL}/usr/bin/*

  mkdir -p ${INSTALL}/usr/config/xemu
  cp -rf ${PKG_DIR}/config/${DEVICE}/xemu.toml ${INSTALL}/usr/config/xemu

  #Download HDD IMAGE
  curl -Lo ${INSTALL}/usr/config/xemu/hdd.zip ${PKG_HDD_IMAGE}
}
