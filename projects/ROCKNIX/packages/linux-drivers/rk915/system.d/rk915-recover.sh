#!/bin/sh
# rk915 watchdog.
#
# The driver detects its own firmware faults and asks mac80211 to restart the
# hardware, but the firmware re-download that follows always fails
# ("N/48056 bytes differ, first at 0x0"), so mac80211 gives up and shuts the
# interface down and the link never comes back. Reloading the module does
# restore it, reliably. Watch for that signature and do exactly that.
#
# This is a mitigation, not a fix: the underlying fault is unresolved, and it
# cannot help the variant where the tx thread spins in the SDIO busy-wait,
# because modprobe -r hangs there.
# The driver has more than one fatal face and they are not interchangeable:
#
#   fw_bring_up: rk915_download_firmware failed   the firmware re-download that
#                                                 follows a runtime fw error
#   rpu_core_init: wait_for_reset_complete failed the chip never comes out of
#                  / RPUWIFI-80211IF: umac init failed   reset - this is the
#                                                 boot race losing earlier, and
#                                                 it never reaches a download,
#                                                 so matching only the line
#                                                 above misses it entirely and
#                                                 the link stays down for good
DEAD='fw_bring_up: rk915_download_firmware failed|rpu_core_init: wait_for_reset_complete failed|RPUWIFI-80211IF: umac init failed'
COOLDOWN=60
POLL=5

reload_driver() {
        logger -t rk915-recover "link is dead - reloading rk915"
        modprobe -r rk915
        sleep 3
        modprobe cfg80211 2>/dev/null
        modprobe mac80211 2>/dev/null
        modprobe rk915
        sleep 10
        systemctl restart iwd
        sleep 20
        if ip route | grep -q '^default'; then
                logger -t rk915-recover "recovered"
        else
                logger -t rk915-recover "still down after reload"
        fi
}

# The driver ships for the whole RK3326 family but only a few boards carry the
# chip. Give it a chance to probe, then stand down where it never appears: there
# is nothing to watch, and the poll loop below would otherwise run a dmesg every
# five seconds forever on every other handheld in the family.
waited=0
while [ ! -d /sys/module/rk915 ]; do
        waited=$((waited + 1))
        if [ "$waited" -ge 30 ]; then
                logger -t rk915-recover "no rk915 module here - nothing to watch"
                exit 0
        fi
        sleep 1
done

# Boot-time check: the driver can lose the same race while the system is busy
# starting up.
sleep 30
seen=$(dmesg | grep -cE "$DEAD")
if [ "$seen" -gt 0 ] && ! ip route | grep -q '^default'; then
        # A fault was logged during boot AND the link is not working. The
        # route check is only a second condition here, never the trigger on
        # its own: with wifi unconfigured or out of range there is no route
        # and no fault either, and reloading then would churn the driver and
        # restart iwd underneath the user for nothing.
        reload_driver
        seen=$(dmesg | grep -cE "$DEAD")
fi

while true; do
        sleep $POLL
        now=$(dmesg | grep -cE "$DEAD")
        if [ "$now" -gt "$seen" ]; then
                reload_driver
                seen=$(dmesg | grep -cE "$DEAD")
                sleep $COOLDOWN
        elif [ "$now" -lt "$seen" ]; then
                seen=$now          # ring buffer wrapped
        fi
done
