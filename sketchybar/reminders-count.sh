#!/usr/bin/env zsh

# https://leancrew.com/all-this/2017/08/my-jxa-problem/
# https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html#//apple_ref/doc/uid/TP40014508-CH109-SW10
remindersToday=$(osascript -l JavaScript -e '
	const rem = Application("Reminders");
	const remindersToday = rem.defaultList().reminders.whose({
		dueDate: { _lessThan: new Date() },
		completed: false,
	});
	remindersToday.length; -- direct return
')

if [[ $remindersToday -eq 0 ]]; then
	remindersToday=""
	icon=""
else
	icon=" "
fi
sketchybar --set "$NAME" label="$remindersToday" icon="$icon" icon.padding_right=3

#───────────────────────────────────────────────────────────────────────────────

sleep 1
killall "Reminders"
