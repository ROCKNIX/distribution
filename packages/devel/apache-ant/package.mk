# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2019-present Peter Vicman (peter.vicman@gmail.com)
# Copyright (C) 2020-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="apache-ant"
PKG_VERSION="1.10.14"
PKG_LICENSE="Apache License 2.0"
PKG_SITE="https://ant.apache.org/"
PKG_URL="https://mirror.lyrahosting.com/apache/ant/source/${PKG_NAME}-${PKG_VERSION}-src.tar.xz"
PKG_DEPENDS_HOST="jdk-zulu:host"
PKG_LONGDESC="Apache Ant is a Java library and command-line tool that help building software."
PKG_TOOLCHAIN="manual"

make_host() {
  (
  export JAVA_HOME=$(get_build_dir jdk-zulu)

  ### Work around for down/missing ftp server.
  TMPCACHE="${ROOT}/.ant/tempcache"
  if [ ! -d "${TMPCACHE}" ]
  then
    mkdir -p ${TMPCACHE}
  fi

  ### Force Maven repository to be in ${ROOT}
  M2_REPOSITORY="${ROOT}/.ant/.m2"
  if [ ! -d "${M2_REPOSITORY}" ]
  then
    mkdir -p ${M2_REPOSITORY}/repository
  fi

  if [ ! -e "${TMPCACHE}/NetRexx.zip" ]
  then
    curl -Lo ${TMPCACHE}/NetRexx.zip https://public.dhe.ibm.com/software/awdtools/netrexx/NetRexx.zip
  fi

  ./bootstrap.sh
  ./bootstrap/bin/ant -f fetch.xml -Ddest=optional -Dtemp.dir=${TMPCACHE} -Dmaven.repo.local=${M2_REPOSITORY}
  ./build.sh -Ddist.dir=${PKG_BUILD}/binary dist
  )
}

makeinstall_host() {
  mkdir -p ${TOOLCHAIN}/bin
  cp binary/bin/ant ${TOOLCHAIN}/bin
  cp -r binary/lib ${TOOLCHAIN}
}
