#!/usr/bin/env osascript
# shows all url+titles of Chrome along with front window+tab url+title
# https://gist.github.com/samyk/65c12468686707b388ec43710430a421
# https://gist.github.com/NoahCardoza/fa060f434a7eda2fc040619a25a8f136

set output to ""
tell application "Brave Browser"
	set tab_list to (every tab in front window)
	repeat with the_tab in tab_list
		set the_url to the URL of the_tab
		set the_title to the title of the_tab
		set output to output & "- [" & the_title & "](" & the_url & ")\n"
	end repeat
end tell
set the clipboard to output

count of tab_list -- return for notification
