#!/usr/bin/env zsh

# only trigger on deactivation of $TASK_APP
if [[ "$SENDER" = "front_app_switched" ]]; then
  [[ -f "/tmp/front_app" ]] && previous_front_app=$(</tmp/front_app)
  echo -n "$INFO" > /tmp/front_app
  [[ "$previous_front_app" != "$TASK_APP" ]] && return 0
fi
osascript -e 'beep'

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
