#!/usr/bin/python3

import sys
import ravel

gbus = ravel.system_bus()

# Get all iwd objects at once
iwd_iface = gbus.get_proxy_object("net.connman.iwd", "/").get_interface("org.freedesktop.DBus.ObjectManager")
objects = iwd_iface.GetManagedObjects()[0]

# Find the first station's path using a generator expression
station_path = next(k for k in objects.keys() if "net.connman.iwd.Station" in objects[k])

# Get the station interface
station = gbus.get_proxy_object("net.connman.iwd", station_path).get_interface("net.connman.iwd.Station")

# Get the sorted network list and print the SSID for each one
for path, _ in station.GetOrderedNetworks()[0]:
    print(objects[path]['net.connman.iwd.Network']['Name'][1])
