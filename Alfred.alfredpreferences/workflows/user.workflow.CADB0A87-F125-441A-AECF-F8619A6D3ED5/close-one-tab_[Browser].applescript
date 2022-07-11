#!/usr/bin/env osascript

tell application "Brave Browser"
	set isLastTab to false
	set noWindow to false

	if ((count of window) is 0)
		set noWindow to true
	else
		if ((count of window) is 1)
			if ((count of tab of front window) is 1)
				set isLastTab to true
			end if
		end if
		close active tab of front window
	end if
end tell

# Hide (to lose focus)
if (isLastTab is true) or (noWindow is true)
	tell application "System Events" to tell process "Brave Browser" to set visible to false
end if
