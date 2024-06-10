-- prevent accidentally triggering this when not on Projector 
tell application "Image Events" 
	launch 
	set countDisplays to count displays 
	quit 
end tell 
if countDisplays > 1 then 
	tell application "Shortcuts" to run shortcut "Virtual Keyboard" 
end if 
