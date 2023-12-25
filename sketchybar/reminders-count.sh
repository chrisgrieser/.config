#!/usr/bin/env zsh
# GUARD don't check while using projector
if system_profiler SPDisplaysDataType | grep -q "ViewSonic PJ"; then
	sketchybar --set "$NAME" label="" icon="" icon.padding_right=0
	return 0
fi

#───────────────────────────────────────────────────────────────────────────────

# https://leancrew.com/all-this/2017/08/my-jxa-problem/
# https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html#//apple_ref/doc/uid/TP40014508-CH109-SW10
remindersToday=$(osascript -l JavaScript -e '
	const rem = Application("Reminders");
	const remindersToday = rem.defaultList().reminders.whose({
		dueDate: { _lessThan: new Date() },
		completed: false,
	});
	remindersToday.length;
')

if [[ $remindersToday -eq 0 ]]; then
	remindersToday=""
	icon=""
	padding=0
else
	icon=" "
	padding=3
fi
sketchybar --set "$NAME" label="$remindersToday" icon="$icon" icon.padding_right=$padding

#───────────────────────────────────────────────────────────────────────────────
sleep 1

# kill Reminders if it's not frontmost (prevents quitting remindders when using it)
front_app=$(osascript -e 'tell application "System Events" to return (name of first process where it is frontmost)')
[[ "$front_app" != "Reminders" ]] && killall "Reminders"
