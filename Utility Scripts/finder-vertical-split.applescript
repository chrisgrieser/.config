-- this line has to appear before functions("on run")
use framework "AppKit"

on alfred_script(q)
	set allFrames to (current application's NSScreen's screens()'s valueForKey:"frame") as list
	set screenWidth to item 1 of item 2 of item 1 of allFrames
	set screenHeight to item 2 of item 2 of item 1 of allFrames

	set vsplit to {{0, 0, 0.5 * screenWidth, screenHeight}, {0.5 * screenWidth, 0, screenWidth, screenHeight} }

	tell application "Finder"

		if ((count windows) is 0) then return

		if ((count windows) is 1) then
			# duplicate current window, if there is only one
			set currentWindow to target of window 1 as alias
			make new Finder window to folder currentWindow
		end if

		set bounds of window 1 to item 2 of vsplit
		set bounds of window 2 to item 1 of vsplit

	end tell

end alfred_script
