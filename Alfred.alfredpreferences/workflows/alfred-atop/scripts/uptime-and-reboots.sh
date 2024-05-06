#!/usr/bin/env zsh

echo "## Uptime"
uptime | cut -d "," -f 1,2 | cut -c 11-
echo
echo "## Last 10 Reboots"
last reboot | head -n10 | sed -e 's/^/- /' -e 's/ time/:/' | tr -s " "
