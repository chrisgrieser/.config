-- this line has to appear before functions("on run")
use framework "AppKit"

on alfred_script(q)
	tell application "System Events" to set frontApp to (name of first process where it is frontmost)
	set dimension to q

	set allFrames to (current application's NSScreen's screens()'s valueForKey:"frame") as list
	set screenWidth to item 1 of item 2 of item 1 of allFrames
	set screenHeight to item 2 of item 2 of item 1 of allFrames

	if (dimension is "maximized") then
		set startX to 0
		set startY to 0
		set widePercent to 1
		set highPercent to 1
	else if (dimension is "pseudo-maximized") then
		set startX to 0
		set startY to 0
		set widePercent to 0.815
		set highPercent to 1
	else if (dimension is "centered") then
		set startX to 0.2
		set startY to 0.1
		set widePercent to 0.6
		set highPercent to 0.8
	else if (dimension is "left") then
		set startX to 0
		set startY to 0
		set widePercent to 0.5
		set highPercent to 1
	else if (dimension is "right") then
		set startX to 0.5
		set startY to 0
		set widePercent to 0.5
		set highPercent to 1
	else if (dimension is "down") then
		set startX to 0
		set startY to 0.5
		set widePercent to 1
		set highPercent to 0.5
	else if (dimension is "up") then
		set startX to 0
		set startY to 0
		set widePercent to 1
		set highPercent to 0.5
	end if

	set xPosition to (screenWidth * startX)
	set yPosition to (screenHeight * startY)
	set wide to (screenWidth * widePercent)
	set high to (screenHeight * highPercent)

	if ( ¬
		frontApp is "Finder" or ¬
		frontApp is "Brave Browser" or ¬
		frontApp is "Vivaldi" or ¬
		frontApp is "Google Chrome" or ¬
		frontApp is "Preview" or ¬
		frontApp is "Safari" or ¬
		frontApp is "BusyCal" ¬
	) then
		# applescript-capable apps work better with this
		tell application frontApp to set bounds of window 1 to {xPosition, yPosition, xPosition + wide, yPosition + high}
	else
		# non-scriptable apps need this
		tell application "System Events"
			tell process frontApp
				tell window 1
					set position to {xPosition, yPosition}
					set size to {wide, high}
				end tell
			end tell
		end tell
	end if

end alfred_script
