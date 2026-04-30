#!/usr/bin/env zsh

osascript -e '
	tell application id "com.runningwithcrayons.Alfred" to run trigger "count-reminders" in workflow "de.chris-grieser.hs-bridge"
' &> /dev/null

sleep 1
cat "/tmp/reminder-count"
