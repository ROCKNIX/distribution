#!/bin/bash

url="https://rocknix.org/devices/unbranded/game-console-r35s-r36s/"

# Download the HTML content
html=$(curl -s "$url")

# Extract the <tr> elements and process them
echo "$html" | xmlstarlet fo --html --recover 2>/dev/null | xmlstarlet sel -t -m '//tr' -v 'normalize-space(td[1])' -o ' ' -v 'normalize-space(td[2])' -n

#NRWIP place generic headers