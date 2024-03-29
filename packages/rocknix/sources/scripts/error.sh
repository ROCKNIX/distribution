#!/usr/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) 2021-present 351ELEC

. /etc/profile

clear
if [ -n "$1" ]
then
  text_viewer -w -e -t "BIOS ERROR" -m "$*"
else
  ERROR=$(tail -n 25 /var/log/es_launch_stderr.log)
  if [ !-z "${ERROR}" ];
  then
    text_viewer -w -e -t ERROR -m "${ERROR}"
  fi
fi

clear
