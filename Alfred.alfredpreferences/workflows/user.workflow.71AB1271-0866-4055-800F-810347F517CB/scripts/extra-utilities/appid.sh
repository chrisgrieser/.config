#!/usr/bin/env zsh

appPath="$*"
appName=$(basename "$appPath")
appid=$(osascript -e "id of application \"$appName\"")

echo -n "$appid" | pbcopy
echo -n "$appid" # Alfred Notification
