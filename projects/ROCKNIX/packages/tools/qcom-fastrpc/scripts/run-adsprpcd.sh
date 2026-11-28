#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026 ROCKNIX (https://github.com/ROCKNIX)

. /etc/profile

# The sensor data structure works like this:
# /usr/share/qcom/base
# /usr/share/qcom/overlays/<DEVICE NAME>

MOUNT_OUTPUT_DIR="/tmp/qcom-hexagon-fs"

SENSOR_DATA_BASE_DIR="/usr/share/qcom/base"
SENSOR_DATA_OVERLAY_DIR="/usr/share/qcom/overlays/${QUIRK_DEVICE}"
SENSOR_DATA_USER_DIR="/storage/.config/qcom-hexagon-fs"
SENSOR_DATA_WORK_DIR="/storage/.tmp/qcom-hexagon-fs-workdir"

# If the base dir doesn't exist, there's nothing we can do
if [ ! -d "$SENSOR_DATA_BASE_DIR" ]; then
    echo "Sensor data base directory for chip ${HW_DEVICE} not found at ${SENSOR_DATA_BASE_DIR}"
    exit 1
fi

# Create our user dir if it doesn't exist
mkdir -p "$SENSOR_DATA_USER_DIR"

# (Re)mount the sensor data using an overlayfs
mkdir -p "$MOUNT_OUTPUT_DIR"
umount "$MOUNT_OUTPUT_DIR" 2>/dev/null || true

mkdir -p "$SENSOR_DATA_WORK_DIR"

if [ -d "$SENSOR_DATA_OVERLAY_DIR" ]; then
    echo "Mounting sensor data overlay (user dir, overlay dir, base dir)"
    mount -t overlay overlay -o lowerdir="${SENSOR_DATA_OVERLAY_DIR}:${SENSOR_DATA_BASE_DIR}",upperdir="${SENSOR_DATA_USER_DIR}",workdir="${SENSOR_DATA_WORK_DIR}" $MOUNT_OUTPUT_DIR
else
    echo "Mounting sensor data overlay (user dir, base dir)"
    mount -t overlay overlay -o lowerdir="${SENSOR_DATA_BASE_DIR}",upperdir="${SENSOR_DATA_USER_DIR}",workdir="${SENSOR_DATA_WORK_DIR}" $MOUNT_OUTPUT_DIR
fi

# FastRPC is odd and wants directories all over the place
mkdir -p "$MOUNT_OUTPUT_DIR"/mnt
mkdir -p "$MOUNT_OUTPUT_DIR"/mnt/vendor

if [ -d "$MOUNT_OUTPUT_DIR"/vendor ]; then
    # /vendor -> /mnt/vendor
    echo "Mounting sensor data subpath: /vendor -> /mnt/vendor"
    mount --rbind "$MOUNT_OUTPUT_DIR"/vendor "$MOUNT_OUTPUT_DIR"/mnt/vendor
fi

echo "Running adsprpcd! (sensor data dir = $MOUNT_OUTPUT_DIR)"
export ADSP_LIBRARY_PATH=$MOUNT_OUTPUT_DIR
adsprpcd sensorspd adsp