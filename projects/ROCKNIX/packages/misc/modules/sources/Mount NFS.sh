#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2026-present Joel Wirāmu Pauling <aenertia@aenertia.net>
# Copyright (C) 2026-present ROCKNIX (https://rocknix.org)

. /etc/profile

CONFIG_FILE="/storage/.nfs-mount"
MOUNT_POINT_NFS="/storage/games-external"
MOUNT_POINT_ROM="/storage/roms"
LOWER="external"
UPPER="internal"

# Updated to match runemu.sh convention
LOG_FILE="/var/log/mount_nfs.log"

# --- 1. Logging & Process Setup ---

# Ensure log directory exists
if [ ! -d "$(dirname "$LOG_FILE")" ]; then
    mkdir -p "$(dirname "$LOG_FILE")"
fi

# Redirect stdout and stderr to the log file, while also printing to console (tee)
exec > >(tee -a "$LOG_FILE") 2>&1

log_msg() {
    echo "[NFS-MOUNT] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Ensure we cleanup background processes on exit
cleanup() {
    # Restore cursor
    tput cnorm > /dev/tty 2>/dev/null
}
trap cleanup EXIT

# Inform system of running process
if command -v set_kill >/dev/null 2>&1; then
    set_kill set "foot"
fi

# --- 2. UI Helper Function ---
# Uses direct TTY access and journal monitoring for input.
show_ui_message() {
    local title="$1"
    local msg="$2"
    local pid_monitor=""
      
    # Hide Cursor for cleaner UI
    tput civis > /dev/tty 2>/dev/null

    # Force a sane terminal type
    if [[ -z "$TERM" || "$TERM" == "dumb" ]]; then
        export TERM=linux
    fi

    # Force detection of screen size from raw TTY
    local dims=$(stty size < /dev/tty 2>/dev/null)
    local rows=$(echo "$dims" | cut -d' ' -f1)
    local cols=$(echo "$dims" | cut -d' ' -f2)

    # Defaults if stty fails
    if [ -z "$rows" ] || [ "$rows" -eq 0 ]; then rows=20; fi
    if [ -z "$cols" ] || [ "$cols" -eq 0 ]; then cols=60; fi
      
    # Margins
    rows=$((rows - 2))
    cols=$((cols - 4))

    # --- JOURNAL INPUT MONITOR ---
    # Watch the journal for ANY button activity ("Pressed" or "Released") from input_sense.
    (
        # -n 0: Start reading from NOW
        # -f: Follow new entries
        # -t input_sense: Only look at logs from the input_sense process
        # grep -m 1: Quit after the first match
        journalctl -n 0 -f -t input_sense | grep -m 1 -E "Pressed|Released" >/dev/null 2>&1
          
        # If grep exits, it found an event. Kill dialog to break the wait.
        killall dialog >/dev/null 2>&1
    ) &
    pid_monitor=$!

    if command -v dialog >/dev/null 2>&1; then
        # Run Dialog with a hard timeout (30s) as a fallback
        # Redirect I/O to /dev/tty to bypass log pipes
        dialog --title "$title" --timeout 30 --msgbox "$msg" $rows $cols < /dev/tty > /dev/tty 2> /dev/tty
          
        # Clear screen immediately after
        clear > /dev/tty
    else
        # Fallback text
        echo "---------------------------------------------------"
        echo "$title"
        echo "---------------------------------------------------"
        echo "$msg"
        echo "---------------------------------------------------"
        sleep 10
    fi
      
    # Clean up the monitor if dialog timed out naturally
    kill $pid_monitor >/dev/null 2>&1
      
    tput cnorm > /dev/tty 2>/dev/null
}

# --- 3. Configuration & Connectivity Checks ---

# NFS Options Breakdown:
# soft: Returns I/O errors on timeout instead of hanging kernel (CRITICAL for portables).
# proto=tcp: Mandatory for v4, reliability over Wi-Fi.
# timeo=50: 5.0s timeout.
# retrans=2: Retry twice.
# noatime,nodiratime: Performance.
# rsize/wsize: 1MB blocks.
# actimeo=60: Cache attributes for 60s (Speeds up listing large ROM sets).
# nocto: No Close-to-Open (Assume single client writing, huge read speed boost).
# bg: Background mount if first attempt fails.
NFS_OPTS="soft,proto=tcp,timeo=50,retrans=2,noatime,nodiratime,rsize=1048576,wsize=1048576,actimeo=60,nocto,bg"

# Check if Config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    log_msg "ERROR: Configuration file not found at $CONFIG_FILE"
      
    MSG="ATTENTION: NFS Configuration Missing!

To use NFS, create the following file:
$CONFIG_FILE

Add a single line pointing to your NFS share.
IMPORTANT: The share MUST contain a 'roms' folder!

Examples:
NFS_PATH=192.168.1.5:/volume1/retro_games
   OR
NFS_PATH=my-nas.local:/volume1/retro_games

(Press any button to exit, or wait 30s)"

    show_ui_message "NFS MOUNT SETUP REQUIRED" "$MSG"
    exit 1
fi

source "$CONFIG_FILE"

# Sanity Check for Empty Variable
if [ -z "$NFS_PATH" ]; then
    log_msg "ERROR: NFS_PATH not defined in $CONFIG_FILE"
    show_ui_message "CONFIGURATION ERROR" "The 'NFS_PATH' variable is missing inside $CONFIG_FILE"
    exit 1
fi

# Quick Network Check
SERVER_IP=$(echo $NFS_PATH | cut -d':' -f1)
log_msg "Checking connectivity to $SERVER_IP..."

if ping -c 1 -W 2 "$SERVER_IP" > /dev/null 2>&1; then
    log_msg "Server is reachable. Proceeding..."
else
    log_msg "Server $SERVER_IP unreachable. Assuming offline mode."
    exit 0
fi

# --- 4. Mount Operations ---

# Prepare NFS Mount Point
if [ ! -d "$MOUNT_POINT_NFS" ]; then
    mkdir -p "$MOUNT_POINT_NFS"
fi

# Attempt NFS Mount
log_msg "Mounting $NFS_PATH to $MOUNT_POINT_NFS"
mount -t nfs -o "$NFS_OPTS" "$NFS_PATH" "$MOUNT_POINT_NFS"

# Verify Mount
if ! mountpoint -q "$MOUNT_POINT_NFS"; then
    log_msg "ERROR: NFS mount failed."
    show_ui_message "MOUNT ERROR" "Failed to mount NFS share.\nCheck network permissions and IP address."
    exit 1
fi

log_msg "NFS mounted successfully."

# Prepare Overlay Directories
WORK_DIR="/storage/games-${UPPER}/.tmp/games-workdir"
UPPER_DIR="/storage/games-${UPPER}/roms"
LOWER_DIR="/storage/games-${LOWER}/roms"

mkdir -p "$WORK_DIR"
mkdir -p "$UPPER_DIR"

# Mount Overlay
log_msg "Creating merged storage (OverlayFS)..."
mount -t overlay overlay -o lowerdir="$LOWER_DIR",upperdir="$UPPER_DIR",workdir="$WORK_DIR" "$MOUNT_POINT_ROM"

if [ $? -eq 0 ]; then
    log_msg "Overlay success. Restarting UI..."
      
    if [ -n "${UI_SERVICE}" ]; then
        systemctl restart ${UI_SERVICE}
    else
        if systemctl is-active --quiet emulationstation; then
             systemctl restart emulationstation
        elif systemctl is-active --quiet retroarch; then
             systemctl restart retroarch
        else
             log_msg "WARNING: UI_SERVICE not set. Restart UI manually."
        fi
    fi
else
    log_msg "ERROR: Overlay mount failed."
    umount -l "$MOUNT_POINT_NFS"
    exit 1
fi
