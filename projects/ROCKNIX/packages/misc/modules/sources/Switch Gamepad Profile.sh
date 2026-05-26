#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2025 ROCKNIX (https://github.com/ROCKNIX)

# Toggle InputPlumber target device between DualSense (ds5) and Xbox Series (xbox-series).
# DualSense enables gyroscope support; Xbox Series improves compatibility with some games.
# Preference persists across reboots via the ROCKNIX settings system.

source /etc/profile

SETTING="inputplumber.profile"
OVERRIDE_YAML="/run/inputplumber-profile.yaml"

# Find the InputPlumber device config that matches this hardware.
# Configs live in /usr/share/inputplumber/devices/ and match via devicetree or DMI model name.
MODEL=$(tr -d '\0' < /sys/firmware/devicetree/base/model 2>/dev/null || \
        cat /sys/class/dmi/id/product_name 2>/dev/null)

DEVICE_YAML=""
if [ -n "$MODEL" ]; then
    DEVICE_YAML=$(grep -rl "value: ${MODEL}" /usr/share/inputplumber/devices/ 2>/dev/null | head -1)
fi

if [ -z "$DEVICE_YAML" ]; then
    zenity --error --timeout=4 \
        --text="No InputPlumber device config found for this hardware." 2>/dev/null || \
    notify-send "Gamepad Profile" "No InputPlumber device config found." 2>/dev/null
    exit 0
fi

# Read current preference (default: ds5, which is the ROCKNIX default for DualSense-capable devices)
CURRENT=$(get_setting "${SETTING}")
[ -z "$CURRENT" ] && CURRENT="ds5"

# Toggle between the two profiles
if [ "$CURRENT" = "ds5" ]; then
    NEW_TARGET="xbox-series"
    LABEL="Xbox Series"
else
    NEW_TARGET="ds5"
    LABEL="DualSense (PS5)"
fi

set_setting "${SETTING}" "${NEW_TARGET}"

# Remove any existing bind mount so we read the original file for the awk transform
grep -qF " ${DEVICE_YAML} " /proc/mounts && umount "${DEVICE_YAML}"

# Generate override YAML: replace only the target_devices block, keep everything else intact
awk -v target="${NEW_TARGET}" '
/^target_devices:/ {
    print "target_devices:"
    print "  - " target
    print "  - keyboard"
    in_targets = 1
    next
}
in_targets && /^  - / { next }
{ in_targets = 0; print }
' "${DEVICE_YAML}" > "${OVERRIDE_YAML}"

# Bind-mount the override over the read-only system file, then restart InputPlumber
systemctl stop inputplumber
mount --bind "${OVERRIDE_YAML}" "${DEVICE_YAML}"
systemctl start inputplumber

# Notify user of the new active profile
zenity --info --timeout=4 \
    --text="Gamepad profile switched to:\n<b>${LABEL}</b>" 2>/dev/null || \
notify-send "Gamepad Profile" "Switched to: ${LABEL}" 2>/dev/null || true
