#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2023 JELOS (https://github.com/JustEnoughLinuxOS)

. /etc/profile

# Generate controller config
# Set controller guid, just take the first one mednafen lists
GUID1="$(mednafen --list-joysticks | grep ID | awk 'NR==1 {print $2}')"
sed -e "s/@GUID1@/${GUID1}/g" ${MEDNAFEN_CONFIG} >> $MEDNAFEN_HOME/mednafen.cfg

NAME="$(mednafen --list-joysticks | grep ID | awk 'NR==1 {print $5$6}')"
if [[ "$(mednafen --list-joysticks | grep ID | awk 'NR==1 {print $4}')" = "8BitDo" ]]
then
NAME="X-Box360"
fi

if [[ "${NAME}" = "X-Box360" ]]
then
export DEVICE_FUNC_KEYA_MODIFIER="BTN_THUMBL"
export DEVICE_FUNC_KEYB_MODIFIER="BTN_THUMBR"
fi

# Replace modifiers with actual buttons
for MOD in DEVICE_FUNC_KEYA_MODIFIER DEVICE_FUNC_KEYB_MODIFIER
do
    sed -i -e "s/${MOD}/DEVICE_${!MOD}/g" $MEDNAFEN_HOME/mednafen.cfg
done

# Controller config for 360 and GPIO handled separately
if [[ "${NAME}" = "X-Box360" ]]
then
for CONTROL in DEVICE_BTN_SOUTH DEVICE_BTN_EAST DEVICE_BTN_NORTH         \
               DEVICE_BTN_WEST DEVICE_BTN_TL DEVICE_BTN_TR               \
               DEVICE_BTN_SELECT DEVICE_BTN_START DEVICE_BTN_MODE        \
               DEVICE_BTN_THUMBL DEVICE_BTN_THUMBR 
do
    sed -i -e "s/@${CONTROL}@/button_${!CONTROL}/g" $MEDNAFEN_HOME/mednafen.cfg
done

# Naming differs to much just assign mednafen name here
DEVICE_BTN_DPAD_UP="abs_7-"
DEVICE_BTN_DPAD_DOWN="abs_7+"
DEVICE_BTN_DPAD_LEFT="abs_6-"
DEVICE_BTN_DPAD_RIGHT="abs_6+"
DEVICE_BTN_TL2="abs_2+"
DEVICE_BTN_TR2="abs_5+"

# These are the minus range of the analog triggers
DEVICE_BTN_TL2_MINUS="abs_2-"
DEVICE_BTN_TR2_MINUS="abs_5-"

# Left analog
DEVICE_BTN_AL_DOWN="abs_1+"
DEVICE_BTN_AL_UP="abs_1-"
DEVICE_BTN_AL_LEFT="abs_0-"
DEVICE_BTN_AL_RIGHT="abs_0+"

# Right analog
DEVICE_BTN_AR_DOWN="abs_3+"
DEVICE_BTN_AR_UP="abs_3-"
DEVICE_BTN_AR_LEFT="abs_2-"
DEVICE_BTN_AR_RIGHT="abs_2+"

for CONTROL in DEVICE_BTN_TL2 DEVICE_BTN_TR2 DEVICE_BTN_DPAD_UP         \
               DEVICE_BTN_DPAD_DOWN DEVICE_BTN_DPAD_LEFT                \
               DEVICE_BTN_DPAD_RIGHT DEVICE_BTN_TL2                     \
               DEVICE_BTN_TR2_MINUS DEVICE_BTN_AL_DOWN DEVICE_BTN_AL_UP \
               DEVICE_BTN_AL_LEFT DEVICE_BTN_AL_RIGHT                   \
               DEVICE_BTN_AR_DOWN DEVICE_BTN_AR_UP DEVICE_BTN_AR_LEFT   \
               DEVICE_BTN_TL2_MINUS DEVICE_BTN_TR2_MINUS
do
    sed -i -e "s/@${CONTROL}@/${!CONTROL}/g" $MEDNAFEN_HOME/mednafen.cfg
done

elif [[ "${NAME}" = "OSHPB" ]]
then
# This is 351P, maybe, hopefully also M and V.
# No 351 usb controller has analog triggers
DEVICE_BTN_TL2_MINUS=${DEVICE_BTN_TL2}
DEVICE_BTN_TR2_MINUS=${DEVICE_BTN_TR2}

# These are the inputs prefixed with button_
for CONTROL in DEVICE_BTN_SOUTH DEVICE_BTN_EAST DEVICE_BTN_NORTH         \
               DEVICE_BTN_WEST DEVICE_BTN_TL DEVICE_BTN_TR               \
               DEVICE_BTN_TL2 DEVICE_BTN_TR2 DEVICE_BTN_SELECT           \
               DEVICE_BTN_START DEVICE_BTN_MODE DEVICE_BTN_THUMBL        \
               DEVICE_BTN_THUMBR DEVICE_BTN_TL2_MINUS DEVICE_BTN_TR2_MINUS
do
    sed -i -e "s/@${CONTROL}@/button_${!CONTROL}/g" $MEDNAFEN_HOME/mednafen.cfg
done

DEVICE_BTN_DPAD_UP="abs_6-"
DEVICE_BTN_DPAD_DOWN="abs_6+"
DEVICE_BTN_DPAD_LEFT="abs_5-"
DEVICE_BTN_DPAD_RIGHT="abs_5+"

# These inputs are probably prefixed with something else than button_
# Just null out the sticks until it is supported in the controller profile
# Left analog
DEVICE_BTN_AL_DOWN=""
DEVICE_BTN_AL_UP=""
DEVICE_BTN_AL_LEFT=""
DEVICE_BTN_AL_RIGHT=""

# Right analog
DEVICE_BTN_AR_DOWN=""
DEVICE_BTN_AR_UP=""
DEVICE_BTN_AR_LEFT=""
DEVICE_BTN_AR_RIGHT=""
for CONTROL in DEVICE_BTN_AL_DOWN DEVICE_BTN_AL_UP DEVICE_BTN_AL_LEFT    \
               DEVICE_BTN_AL_RIGHT DEVICE_BTN_AR_DOWN DEVICE_BTN_AR_UP   \
               DEVICE_BTN_AR_LEFT DEVICE_BTN_AR_RIGHT DEVICE_BTN_DPAD_UP \
               DEVICE_BTN_DPAD_DOWN DEVICE_BTN_DPAD_LEFT DEVICE_BTN_DPAD_RIGHT
do
    sed -i -e "s/@${CONTROL}@/${!CONTROL}/g" $MEDNAFEN_HOME/mednafen.cfg
done

else

# GameForce Ace has analog triggers, set them before mapping the rest of the GPIO controller
if [[ "${NAME}" = "ACEGamepad" ]]
then

DEVICE_BTN_TL2="abs_2-"
DEVICE_BTN_TR2="abs_5-"
# No other GPIO device has analog triggers (I think), Just set them to the same
DEVICE_BTN_TL2_MINUS=${DEVICE_BTN_TL2}
DEVICE_BTN_TR2_MINUS=${DEVICE_BTN_TR2}

# Left analog
DEVICE_BTN_AL_DOWN="abs_1+"
DEVICE_BTN_AL_UP="abs_1-"
DEVICE_BTN_AL_LEFT="abs_0-"
DEVICE_BTN_AL_RIGHT="abs_0+"

# Right analog
DEVICE_BTN_AR_DOWN="abs_4+"
DEVICE_BTN_AR_UP="abs_4-"
DEVICE_BTN_AR_LEFT="abs_3-"
DEVICE_BTN_AR_RIGHT="abs_3+"


for CONTROL in DEVICE_BTN_TL2 DEVICE_BTN_TR2    \
               DEVICE_BTN_TL2_MINUS DEVICE_BTN_TR2_MINUS \
               DEVICE_BTN_AL_DOWN DEVICE_BTN_AL_UP DEVICE_BTN_AL_LEFT    \
               DEVICE_BTN_AL_RIGHT DEVICE_BTN_AR_DOWN DEVICE_BTN_AR_UP   \
               DEVICE_BTN_AR_LEFT DEVICE_BTN_AR_RIGHT
do
    sed -i -e "s/@${CONTROL}@/${!CONTROL}/g" $MEDNAFEN_HOME/mednafen.cfg
done

fi

# These are the inputs prefixed with button_
for CONTROL in DEVICE_BTN_SOUTH DEVICE_BTN_EAST DEVICE_BTN_NORTH         \
               DEVICE_BTN_WEST DEVICE_BTN_TL DEVICE_BTN_TR               \
               DEVICE_BTN_TL2 DEVICE_BTN_TR2 DEVICE_BTN_SELECT           \
               DEVICE_BTN_START DEVICE_BTN_MODE DEVICE_BTN_THUMBL        \
               DEVICE_BTN_THUMBR DEVICE_BTN_DPAD_UP DEVICE_BTN_DPAD_DOWN \
               DEVICE_BTN_DPAD_LEFT DEVICE_BTN_DPAD_RIGHT                \
               DEVICE_BTN_TL2_MINUS DEVICE_BTN_TR2_MINUS
do
    sed -i -e "s/@${CONTROL}@/button_${!CONTROL}/g" $MEDNAFEN_HOME/mednafen.cfg
done

# These inputs are probably prefixed with something else than button_
# Just null out the sticks until it is supported in the controller profile
# Left analog
DEVICE_BTN_AL_DOWN=""
DEVICE_BTN_AL_UP=""
DEVICE_BTN_AL_LEFT=""
DEVICE_BTN_AL_RIGHT=""

# Right analog
DEVICE_BTN_AR_DOWN=""
DEVICE_BTN_AR_UP=""
DEVICE_BTN_AR_LEFT=""
DEVICE_BTN_AR_RIGHT=""
for CONTROL in DEVICE_BTN_AL_DOWN DEVICE_BTN_AL_UP DEVICE_BTN_AL_LEFT    \
               DEVICE_BTN_AL_RIGHT DEVICE_BTN_AR_DOWN DEVICE_BTN_AR_UP   \
               DEVICE_BTN_AR_LEFT
do
    sed -i -e "s/@${CONTROL}@//g" $MEDNAFEN_HOME/mednafen.cfg
done

fi


