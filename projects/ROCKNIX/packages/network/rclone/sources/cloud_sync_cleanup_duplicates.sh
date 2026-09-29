#!/bin/bash
# SPDX-License-Identifier: GPL-2.0
# Remove duplicate variable assignments from cloud_sync.conf, keeping only the first occurrence.
# Usage: ./cloud_sync_cleanup_duplicates.sh /path/to/cloud_sync.conf

CONF_FILE="${1:-/storage/.config/cloud_sync.conf}"
TMP_FILE="${CONF_FILE}.cleaned"

# A value continued with a trailing backslash (RCLONEOPTS is written that
# way) is one assignment over several lines: a repeated one is removed whole.
# Its first line alone used to go, and the lines that continued it stayed as
# bare lines -- a file that no longer parses, which every run after then
# refused or fell back from (found in the audit of the fixes to #307).
awk '
  skip { skip = ($0 ~ /\\$/); next }
  /^[[:space:]]*#/ { print; next }
  /^[[:space:]]*$/ { print; next }
  /^[A-Za-z0-9_]+=.*$/ {
    var=gensub(/=.*/, "", 1)
    if (!(var in seen)) {
      print
      seen[var]=1
    } else if ($0 ~ /\\$/) {
      skip = 1
    }
    next
  }
  { print }
' "$CONF_FILE" > "$TMP_FILE" && mv "$TMP_FILE" "$CONF_FILE" \
  && echo "Duplicate variable assignments removed from $CONF_FILE." \
  || { rm -f "$TMP_FILE"; echo "Could not clean $CONF_FILE; left as it was." >&2; exit 1; }
