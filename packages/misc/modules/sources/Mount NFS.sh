#!/bin/sh
# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2024-present ROCKNIX (https://github.com/ROCKNIX)


. /etc/profile

if [ -f "/storage/.nfs-mount" ]; then
        source /storage/.nfs-mount
        echo "Creating merged storage at /storage/roms with $NFS_PATH and games-internal/roms "
        mount -o soft,retrans=2,timeo=60 $NFS_PATH /storage/games-external
        MS_PATH="/storage/roms"
        LOWER="external"
        UPPER="internal"

        if [ ! -d "/storage/games-${UPPER}/.tmp" ]; then
                        mkdir -p "/storage/games-${UPPER}/.tmp/games-workdir"
        fi

        mount overlay -t overlay -o lowerdir=/storage/games-${LOWER}/roms,upperdir=/storage/games-${UPPER}/roms,workdir=/storage/games-${UPPER}/.tmp/games-workdir /storage/roms
	systemctl restart ${UI_SERVICE}
else
        echo "
ATTENSION!
You need to create the .nfs-mount file on the root of the internal storage (/storage/.nfs-mount) the format of this file should be:

               NFS_PATH=<valid NFS URI>
i.e:

NFS_PATH=nfs.example.com:/upper-path-containing-roms-subdir

Obviously you also need to be connected to the appropriate network segment. The base URI should contain a roms subdirectory already to merge. No attempt is made to deal with unmounting existing external storage(2nd SD) and it will result in the NFS mount being mounted over this location if it exists"

sleep 5
fi

