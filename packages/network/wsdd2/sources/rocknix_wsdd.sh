#!/bin/sh

SERIAL=$(cat /etc/machine-id)
HOSTNAME=$(/usr/bin/hostname)

# Setting vendor/model/serial seems to help Windows trust this announce
# Appending .local to hostname makes Windows use mDNS which fixes access when router has internal DNS
exec /usr/sbin/wsdd2 -b "vendor:ROCKNIX,model:${QUIRK_DEVICE},serial:${SERIAL}" -N "${HOSTNAME}.local"
