#!/bin/sh

dd if="/sdcard/openabl/abl_a.img" of="/dev/block/by-name/abl_a" bs=1M
dd if="/sdcard/openabl/abl_b.img" of="/dev/block/by-name/abl_b" bs=1M
