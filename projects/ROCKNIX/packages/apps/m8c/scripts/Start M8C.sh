#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present 351ELEC

source /etc/profile

set_kill set "-9 m8c"

M8C_DIR="/storage/.local/share/m8c"
M8C_CONF_DIR="/usr/config/m8c"

if [ ! -d ${M8C_DIR} ]; then
  mkdir -p ${M8C_DIR}
fi

if [ ! -f "${M8C_DIR}/config.ini" ]; then
    if [ -f "${M8C_CONF_DIR}/${QUIRK_DEVICE}.ini" ]; then
        cp "${M8C_CONF_DIR}/${QUIRK_DEVICE}.ini" "${M8C_DIR}/config.ini"
    else
        if [ -f "${M8C_CONF_DIR}/config.ini" ]; then
            cp "${M8C_CONF_DIR}/config.ini" "${M8C_DIR}/config.ini"
        fi
    fi
fi

modprobe cdc-acm
modprobe snd-hwdep
modprobe snd-usbmidi-lib
modprobe snd-usb-audio

# Arrays to store connections for cleanup
MIDI_CONNECTIONS=()

#Connect all MIDI ports to Dirtywave in both directions
M8_ID=$(aconnect -iol | awk '/client [0-9]+: .*M8/ {print $2}' | tr -d ':')
M8_PORT="$M8_ID:0"

DEVICE_IDS=$(aconnect -iol | awk '/client [0-9]+:/ {print $2}' | tr -d ':' | grep -vE "^(0|$M8_ID)$")

for DEVICE_ID in $DEVICE_IDS; do
    DEVICE_PORT="$DEVICE_ID:0"
    # Store connections for later cleanup
    MIDI_CONNECTIONS+=("$DEVICE_PORT:$M8_PORT")
    MIDI_CONNECTIONS+=("$M8_PORT:$DEVICE_PORT")
    aconnect "$DEVICE_PORT" "$M8_PORT"
    aconnect "$M8_PORT" "$DEVICE_PORT"
done

#Capture M8 USB Source and Play it out the default audio sink
M8_AUDIO_SOURCE=$(pactl list sources | awk '/Name: alsa_input\.usb-[Dd]irty[Ww]ave/{print $2}')
pw-loopback -C $M8_AUDIO_SOURCE &

#Connect each BT Source and Play it to the M8 Sink
BT_SOURCES=$(pactl list | awk -F. '/Name: bluez_card/{print $2}')
M8_AUDIO_SINK=$(pactl list sinks | awk '/Name: alsa_output\.usb-[Dd]irty[Ww]ave/{print $2}')
for BT_SOURCE in $BT_SOURCES; do
	pw-loopback -C bluez_input.$BT_SOURCE.2 -P $M8_AUDIO_SINK &
done

# Connect each audio source to the M8 Sink, excluding the M8 device itself

# Get the M8 Audio Sink (your specific USB sink)
M8_AUDIO_SINK=$(pactl list sinks short | awk '/alsa_output\.usb-[Dd]irty[Ww]ave/{print $2}')

# List all audio sources, excluding monitor sources
ALL_SOURCES=$(pactl list sources short | awk '$2 !~ /\.monitor/ {print $2}')

# Loop over each source and connect it to the sink, but skip the M8 device's own source
for SRC in $ALL_SOURCES; do
    if [[ "$SRC" == *"usb-"[Dd]"irty"[Ww]"ave"* ]]; then
        continue
    fi
    pw-loopback -C "$SRC" -P "$M8_AUDIO_SINK" &
done

# Function to cleanup MIDI connections and audio routing
cleanup() {
    echo "Cleaning up MIDI connections and audio routing..."
    
    # Kill all pw-loopback processes
    echo "Terminating PipeWire loopback processes..."
    kill $(jobs -p) 2>/dev/null
    
    # Wait a moment for processes to terminate
    sleep 1
    
    # Force kill any remaining pw-loopback processes
    pkill -f pw-loopback 2>/dev/null
    
    # Disconnect MIDI connections
    echo "Disconnecting MIDI connections..."
    for connection in "${MIDI_CONNECTIONS[@]}"; do
        if [[ "$connection" == *":"* ]]; then
            src_port="${connection%:*}"
            dst_port="${connection#*:}"
            aconnect -d "$src_port" "$dst_port" 2>/dev/null || true
        fi
    done
    
    echo "Cleanup completed."
}

# Set up trap to cleanup on script exit
trap cleanup EXIT

sway_fullscreen "m8c" &

/usr/bin/m8c
