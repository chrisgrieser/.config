#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

appPath="$*"
appName=$(basename -s ".app" "$appPath")
appid=$(osascript -e "id of application \"$appName\"")

echo -n "$appid" | pbcopy
echo -n "$appid" # Alfred Notification
