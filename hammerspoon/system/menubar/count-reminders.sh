#!/usr/bin/env zsh

# BUG https://github.com/Hammerspoon/hammerspoon/issues/3870
osascript -e '
	tell application id "com.runningwithcrayons.Alfred" to run trigger "count-reminders" in workflow "de.chris-grieser.hs-bridge"
' &> /dev/null

sleep 1
cat "/tmp/reminder-count"
