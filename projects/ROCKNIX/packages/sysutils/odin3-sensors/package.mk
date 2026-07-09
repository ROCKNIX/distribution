# SPDX-License-Identifier: GPL-2.0
# ROCKNIX (Anze / DUCKTALE) - AYN Odin 3 SSC accel+gyro bring-up

PKG_NAME="odin3-sensors"
PKG_VERSION="706071caca54b9a56d78793c30d04351de5fbd96"
PKG_SHA256="14aa4dbd0a69af319d7cca091a72316d68ecc36d4ff2906b75701ddcfd94b6b9"
PKG_LICENSE="MIT"
PKG_SITE="https://github.com/qualcomm/fastrpc"
PKG_URL="https://github.com/qualcomm/fastrpc/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain"
PKG_TOOLCHAIN="manual"
PKG_LONGDESC="AYN Odin 3 (SM8750) Snapdragon Sensor Core accel+gyro bring-up: fastrpc adsprpcd spawns the ADSP sensorspd PD + runs the reverse-RPC listener; snsfeed reads accel/gyro over QRTR (sns_client) and feeds the sns_iio kernel bridge via /dev/sns_iio_feed. Ships the Hexagon sensor registry (qcom-hexagon-fs)."

# Build flags to compile qualcomm/fastrpc for a non-Android glibc target:
#  -DLE_ENABLE   : "Linux Embedded" mode -> stubs the Android ATRACE/systrace
#  -DUSE_SYSLOG  : route FARF logs to syslog instead of <android/log.h>
# (do NOT define __LE_TVM__ - it pulls android/log.h). No libyaml/libbsd needed
# once fastrpc_config_parser.c is dropped and strlcpy/strlcat are shimmed.
FASTRPC_CFLAGS="-O2 -Iinc -Isrc -Isrc/dspqueue -DLE_ENABLE -DUSE_SYSLOG -fPIC -w"

# libdsprpc sources (minus the yaml config parser) + the default listener +
# our tiny daemon main and a strlcpy/strlcat shim.
FASTRPC_SRC="fastrpc_apps_user.c fastrpc_perf.c fastrpc_pm.c fastrpc_config.c \
  fastrpc_mem.c fastrpc_notif.c fastrpc_ioctl.c fastrpc_log.c fastrpc_procbuf.c \
  fastrpc_cap.c log_config.c dspsignal.c dspqueue/dspqueue_cpu.c \
  dspqueue/dspqueue_rpc_stub.c listener_android.c apps_std_imp.c apps_mem_imp.c \
  apps_mem_skel.c rpcmem_linux.c adspmsgd.c adspmsgd_printf.c std_path.c \
  std_dtoa.c BufBound.c platform_libs.c pl_list.c gpls.c remotectl_stub.c \
  remotectl1_stub.c adspmsgd_apps_skel.c adspmsgd_adsp_stub.c \
  adspmsgd_adsp1_stub.c apps_remotectl_skel.c adsp_current_process_stub.c \
  adsp_current_process1_stub.c adsp_listener_stub.c adsp_listener1_stub.c \
  apps_std_skel.c adsp_perf_stub.c adsp_perf1_stub.c mod_table.c \
  fastrpc_context.c adsp_default_listener.c adsp_default_listener_stub.c \
  adsp_default_listener1_stub.c"

make_target() {
  cp -f ${PKG_DIR}/sources/bsd_shim.c ${PKG_DIR}/sources/daemon_main.c \
        ${PKG_DIR}/sources/snsfeed.c src/

  local objs=""
  for s in ${FASTRPC_SRC} bsd_shim.c daemon_main.c; do
    local o="src/$(echo ${s} | tr '/' '_').o"
    ${CC} ${FASTRPC_CFLAGS} -c "src/${s}" -o "${o}"
    objs="${objs} ${o}"
  done
  ${CC} -O2 -o adsprpcd ${objs} -ldl -lm -lpthread

  ${CC} -O2 -o snsfeed src/snsfeed.c -lm
}

makeinstall_target() {
  mkdir -p ${INSTALL}/usr/bin
  cp -f adsprpcd snsfeed ${INSTALL}/usr/bin/
  cp -f ${PKG_DIR}/sources/odin3-sensors-start ${INSTALL}/usr/bin/
  chmod 0755 ${INSTALL}/usr/bin/odin3-sensors-start

  # Hexagon sensor registry (base + AYN Odin 3 overlay, merged)
  mkdir -p ${INSTALL}/usr/share/qcom-hexagon-fs
  cp -a ${PKG_DIR}/qcom-hexagon-fs/. ${INSTALL}/usr/share/qcom-hexagon-fs/

  mkdir -p ${INSTALL}/usr/lib/systemd/system
  cp -f ${PKG_DIR}/system.d/odin3-sensors.service \
        ${INSTALL}/usr/lib/systemd/system/
  enable_service odin3-sensors.service
}
