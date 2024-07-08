#!/bin/bash

KEY_GUIDE_NONE=$(echo $KEY_GUIDE_NONE)
KEY_GUIDE_1=$(echo $KEY_GUIDE_1)
KEY_GUIDE_2=$(echo $KEY_GUIDE_2)
KEY_GUIDE_3=$(echo $KEY_GUIDE_3)

FN_A_PRESSED_FILE="/tmp/FN_A_PRESSED.state"
FN_B_PRESSED_FILE="/tmp/FN_B_PRESSED.state"
FN_A_PRESSED=$(cat "$FN_A_PRESSED_FILE")
FN_B_PRESSED=$(cat "$FN_B_PRESSED_FILE")

if [ "$FN_A_PRESSED" = "true" ] && [ "$FN_B_PRESSED" = "false" ]; then
    echo "{\"text\":\"$KEY_GUIDE_1\", \"class\":\"key-guide-1\"}"
elif [ "$FN_A_PRESSED" = "false" ] && [ "$FN_B_PRESSED" = "true" ]; then
    echo "{\"text\":\"$KEY_GUIDE_2\", \"class\":\"key-guide-2\"}"
elif [ "$FN_A_PRESSED" = "true" ] && [ "$FN_B_PRESSED" = "true" ]; then
    echo "{\"text\":\"$KEY_GUIDE_3\", \"class\":\"key-guide-3\"}"
else
    echo "{\"text\":\"$KEY_GUIDE_NONE\", \"class\":\"key-guide-none\"}"
fi
