#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present ROCKNIX (https://rocknix.org)

. /etc/profile

REPORT_DIR="/storage/roms/autotune"
REPORT="${REPORT_DIR}/autotune-${HW_DEVICE}-$(date +%Y%m%d-%H%M%S).txt"
TMP=$(mktemp -d)

mkdir -p "${REPORT_DIR}"

{
  echo "rocknix = ${OS_VERSION} ${BUILD_ID}"
  echo "model = ${QUIRK_DEVICE} (${HW_DEVICE})"
  echo "kernel = $(uname -r)"
  echo "tu_debug = ${TU_DEBUG}"
  for GPU in /sys/class/devfreq/*.gpu; do
    echo "gpu_governor = $(cat ${GPU}/governor)"
    echo "gpu_max_freq = $(cat ${GPU}/max_freq)"
  done

  # three runs to show run-to-run noise
  for RUN in 1 2 3; do
    TU_AUTOTUNE_CALIB="force,dump,export=${TMP}/calib-${RUN}.txt" vulkaninfo --summary >${TMP}/log-${RUN}.txt 2>&1
    echo
    echo "# run ${RUN}"
    if [ -f ${TMP}/calib-${RUN}.txt ]; then
      cat ${TMP}/calib-${RUN}.txt
      grep "autotune calib" ${TMP}/log-${RUN}.txt
    else
      tail -n 50 ${TMP}/log-${RUN}.txt
    fi
  done
} >"${REPORT}"

STATUS=$(grep -m1 "^status = " "${REPORT}")
rm -rf ${TMP}

text_viewer -w -t "Autotune Report" -m "${STATUS:-status = no calibration written}

Saved to ${REPORT}

Copy it from the games-roms network share or the roms/autotune folder on the games card."
