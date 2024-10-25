#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later

. /etc/profile
. /etc/os-release

if [ -f "/storage/.nfs-mount" ]; then
        source /storage/.nfs-mount
        echo "Creating merged storage at /storage/roms with $NFS_PATH and games-internal/roms "
        mount $NFS_PATH /storage/games-external
        MS_PATH="/storage/roms"
        LOWER="external"
        UPPER="internal"

        if [ ! -d "/storage/games-${UPPER}/.tmp" ]; then
                        mkdir -p "/storage/games-${UPPER}/.tmp/games-workdir"
        fi

        mount overlay -t overlay -o lowerdir=/storage/games-${LOWER}/roms,upperdir=/storage/games-${UPPER}/roms,workdir=/storage/games-${
	systemctl restart ${UI_SERVICE}
else
        echo "
        ATTENSION!
        You need to create the .nfs-mount file on the root of the internal storage (/storage/.nfs-mount) the format of this file should b

               NFS_PATH=<valid NFS URI>

        Obviously you also need ot be connected to the appropriate network segment. The base URI should contain a roms subdirectory already to merge No attempt is made to deal with umounting existing external storage(2nd SD)"
fi

