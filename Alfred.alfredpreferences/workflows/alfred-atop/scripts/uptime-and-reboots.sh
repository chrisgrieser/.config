#!/usr/bin/env zsh

echo "🕓 Uptime"
echo "──────────────────"
uptime | cut -d "," -f 1,2 | cut -c 11-
echo 
echo 
echo "🆙 Last 10 Reboots"
echo "──────────────────"
last reboot | head -n10 | tr -s " " | cut -d" " -f3-
