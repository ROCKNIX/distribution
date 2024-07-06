#!/bin/bash

KEY_GUIDE_NONE=$(echo $KEY_GUIDE_NONE)
KEY_GUIDE_1=$(echo $KEY_GUIDE_1)
KEY_GUIDE_2=$(echo $KEY_GUIDE_2)
KEY_GUIDE_3=$(echo $KEY_GUIDE_3)

FN_A_PRESSED=$(echo $FN_A_PRESSED)
FN_B_PRESSED=$(echo $FN_B_PRESSED)

if [ "$FN_A_PRESSED" = "true" ] && [ "$FN_B_PRESSED" = "false" ]; then
    echo "{\"text\":\"$KEY_GUIDE_1\", \"class\":\"key-guide-1\"}"
elif [ "$FN_B_PRESSED" = "true" ] && [ "$FN_A_PRESSED" = "true" ]; then
    echo "{\"text\":\"$KEY_GUIDE_2\", \"class\":\"key-guide-2\"}"
elif [ "$FN_A_PRESSED" = "true" ] && [ "$FN_B_PRESSED" = "true" ]; then
    echo "{\"text\":\"$KEY_GUIDE_3\", \"class\":\"key-guide-3\"}"
else
    echo "{\"text\":\"$KEY_GUIDE_NONE\", \"class\":\"key-guide-none\"}"
fi
