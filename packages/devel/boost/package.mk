# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2009-2016 Stephan Raue (stephan@openelec.tv)
# Copyright (C) 2019-present Team LibreELEC (https://libreelec.tv)
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

PKG_NAME="boost"
PKG_VERSION="1.86.0"
PKG_LICENSE="OSS"
PKG_SITE="http://www.boost.org/"
PKG_URL="https://archives.boost.io/release/${PKG_VERSION}/source/${PKG_NAME}_${PKG_VERSION//./_}.tar.bz2"
PKG_DEPENDS_HOST="toolchain:host"
PKG_DEPENDS_TARGET="toolchain boost:host Python3 zlib bzip2"
PKG_LONGDESC="boost: Peer-reviewed STL style libraries for C++"
PKG_TOOLCHAIN="manual"
PKG_BUILD_FLAGS="+pic"
PKG_B2_PARAM=" binary-format=elf link=static threading=multi toolset=gcc "
if [ "${TARGET_ARCH}" = "aarch64" ]; then
	PKG_B2_PARAM+=" abi=aapcs address-model=64 architecture=arm "
fi

make_host() {
  cd tools/build/src/engine
    sh build.sh
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
    cp b2 ${TOOLCHAIN}/bin
}

pre_configure_target() {
  export CFLAGS="${CFLAGS} -I${SYSROOT_PREFIX}/usr/include/${PKG_PYTHON_VERSION}"
  export CXXFLAGS="${CXXFLAGS} -I${SYSROOT_PREFIX}/usr/include/${PKG_PYTHON_VERSION}"
}

configure_target() {
  sh bootstrap.sh --prefix=/usr \
                  --with-bjam=${TOOLCHAIN}/bin/b2 \
                  --with-python=${TOOLCHAIN}/bin/python \
                  --with-python-root=${SYSROOT_PREFIX}/usr

  echo "using gcc : $(${CC} -v 2>&1  | tail -n 1 |awk '{print $3}') : ${CXX}  : <compileflags>\"${CFLAGS}\" <linkflags>\"${LDFLAGS}\" ;" \
    > tools/build/src/user-config.jam
  echo "using python : ${PKG_PYTHON_VERSION/#python} : ${TOOLCHAIN} : ${SYSROOT_PREFIX}/usr/include : ${SYSROOT_PREFIX}/usr/lib ;" \
    >> tools/build/src/user-config.jam
}
makeinstall_target() {
  ln -sf ${TOOLCHAIN}/bin/b2 ${TOOLCHAIN}/bin/bjam
  ${TOOLCHAIN}/bin/bjam -d2 --ignore-site-config \
                          ${PKG_B2_PARAM} \
                          --layout=system \
                          --prefix=${SYSROOT_PREFIX}/usr \
                          --with-chrono \
                          --with-date_time \
                          --with-filesystem \
                          --with-iostreams \
                          --with-program_options \
                          --with-python \
                          --with-locale \
                          --with-random \
                          --with-regex -sICU_PATH="${SYSROOT_PREFIX}/usr" \
                          --with-serialization \
                          --with-system \
                          --with-thread \
                          --with-nowide \
			  --with-context \
                          install
}
