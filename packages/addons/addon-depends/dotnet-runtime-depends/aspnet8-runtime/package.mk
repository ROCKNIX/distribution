# SPDX-License-Identifier: GPL-2.0-only
# Copyright (C) 2023-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="aspnet8-runtime"
PKG_VERSION="8.0.19"
PKG_LICENSE="MIT"
PKG_SITE="https://dotnet.microsoft.com/"
PKG_DEPENDS_TARGET="toolchain"
PKG_LONGDESC="ASP.NET Core Runtime enables you to run existing web/server applications."
PKG_TOOLCHAIN="manual"

case "${ARCH}" in
  "aarch64")
    PKG_SHA256="bf72039478ca501546ed0e252289677cdbd96b9c7342b3c83d398ac332424b52"
    PKG_URL="https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.19/aspnetcore-runtime-8.0.19-linux-arm64.tar.gz"
    ;;
  "arm")
    PKG_SHA256="5d8ae9e0b2bf4d3482367b251d8d58d966cc93e8a2c3a3e933a2de2d2ca6a38b"
    PKG_URL="https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.19/aspnetcore-runtime-8.0.19-linux-arm.tar.gz"
    ;;
  "x86_64")
    PKG_SHA256="b004aaf0a463dfb6c9c0c2510c842dce56d0b50b04bdc8dad34e86bb8b4b06ea"
    PKG_URL="https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/8.0.19/aspnetcore-runtime-8.0.19-linux-x64.tar.gz"
    ;;
esac
PKG_SOURCE_NAME="aspnetcore-runtime_${PKG_VERSION}_${ARCH}.tar.gz"
