#!/usr/bin/env osascript

-- also works with YouTube Progressive Web App
-- return first youtube link it can find, useful because the YouTube PWA
-- sometimes isn't treat as the first window & first tab, even if frontmost
tell application "Brave Browser"
		set window_list to every window
		repeat with the_window in window_list
			set tab_list to every tab in the_window
			repeat with the_tab in tab_list
				set the_url to the URL of the_tab
				if (the_url contains "youtu") -- also matches youtu.be short URLs
					return the_url
					exit
				end if
			end repeat
		end repeat
end tell
