#!/usr/bin/env osascript

-- CONFIG 
set theDestCalendar to "Academia" 
 
tell application "Calendar" 
	reload calendars 
	 
	set today to (current date) 
	set tomorrow to (today) + 1 * days 
	set theEvents to events of calendar theDestCalendar whose start date is greater than today and start date is less than tomorrow 

	set acc to "" 
	repeat with theEvent in theEvents 
		set theTime to text 1 thru 5 of (time string of ((start date of theEvent) as date)) 
		set theTitle to summary of theEvent 
		set acc to acc & theTime & " " & theTitle & linefeed 
	end repeat 

	quit 
end tell 
 
acc -- direct return
