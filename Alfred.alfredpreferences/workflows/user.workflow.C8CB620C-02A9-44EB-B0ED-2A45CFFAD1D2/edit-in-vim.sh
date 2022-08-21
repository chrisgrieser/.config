subl_cli="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"

osascript -e '
	tell application "System Events"
		keystroke "a" using {command down}
		keystroke "c" using {command down}
	end tell'

sleep 0.05
pbpaste | "$subl_cli" --wait --new-window | pbcopy
sleep 0.05

osascript -e 'tell application "System Events" to keystroke "v" using {command down}'
