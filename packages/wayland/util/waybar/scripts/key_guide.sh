#!/bin/bash
source /storage/.config/waybar/hotkeys/current-hotkeys

KEY_GUIDE_NONE=$(echo $KEY_GUIDE_NONE)
KEY_GUIDE_1=$(echo $KEY_GUIDE_1)
KEY_GUIDE_2=$(echo $KEY_GUIDE_2)
KEY_GUIDE_3=$(echo $KEY_GUIDE_3)

FN_A_PRESSED_FILE="/tmp/FN_A_PRESSED.state"
FN_B_PRESSED_FILE="/tmp/FN_B_PRESSED.state"

read_state() {
  local file="$1"
  local state=$(cat "$file" 2>/dev/null || echo "false")
  local mtime=$(stat -c %Y "$file" 2>/dev/null || echo 0)
  local current_time=$(date +%s)

  if [ $((current_time - mtime)) -gt 10 ]; then  # 10 seconds timeout
    echo "false"
  else
    echo "$state"
  fi
}

FN_A_PRESSED=$(read_state "$FN_A_PRESSED_FILE")
FN_B_PRESSED=$(read_state "$FN_B_PRESSED_FILE")

if [ "$FN_A_PRESSED" = "true" ] && [ "$FN_B_PRESSED" = "false" ]; then
    echo "{\"text\": \"$KEY_GUIDE_1\", \"class\": \"key-guide-1\"}"
elif [ "$FN_A_PRESSED" = "false" ] && [ "$FN_B_PRESSED" = "true" ]; then
    echo "{\"text\": \"$KEY_GUIDE_2\", \"class\": \"key-guide-2\"}"
elif [ "$FN_A_PRESSED" = "true" ] && [ "$FN_B_PRESSED" = "true" ]; then
    echo "{\"text\": \"$KEY_GUIDE_3\", \"class\": \"key-guide-3\"}"
else
    echo "{\"text\": \"$KEY_GUIDE_NONE\", \"class\": \"key-guide-none\"}"
fi
