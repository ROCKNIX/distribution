#!/bin/sh

dd if="/dev/block/by-name/abl_a" of="/sdcard/openabl/abl_a.img" bs=1M
dd if="/dev/block/by-name/abl_b" of="/sdcard/openabl/abl_b.img" bs=1M
