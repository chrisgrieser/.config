#!/usr/bin/env zsh

echo "🕓 Uptime"
echo "──────────────────"
uptime | cut -d "," -f 1,2 | cut -c 11-
echo 
echo 
echo "🆙 Last 10 Reboots"
echo "──────────────────"
last reboot | head -n 10 | cut -c 37-
