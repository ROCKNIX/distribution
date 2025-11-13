#!/bin/bash

# Backup abl_a and abl_b

dd if=/dev/block/by-name/abl_a of="/sdcard/rocknix_abl/abl_a.img" bs=1M
dd if=/dev/block/by-name/abl_b of="/sdcard/rocknix_abl/abl_b.img" bs=1M
