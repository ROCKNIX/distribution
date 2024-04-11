#!/bin/sh

case "${1}" in
    "show")
	swaymsg -t get_seats | jq -r '.[] | .name' |
	    while read SEAT
	    do
		swaymsg seat "${SEAT}" hide_cursor when-typing disable || exit 1
	    done
    ;;
    "hide")
	swaymsg -t get_seats | jq -r '.[] | .name' |
	    while read SEAT
	    do
		swaymsg seat "${SEAT}" hide_cursor when-typing enable || exit 1
	    done
    ;;
    *)
	echo "${0} <show|hide>" >&2
	exit 1
esac
exit 0
