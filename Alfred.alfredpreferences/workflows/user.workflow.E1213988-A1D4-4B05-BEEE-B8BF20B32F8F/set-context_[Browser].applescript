#!/usr/bin/env osascript

--get variables
set zoom_url to do shell script ("echo " & quoted form of (system attribute "zoom_url") & " | iconv -f UTF-8-MAC -t MACROMAN")
set notes to (system attribute "notes")

--open Zoom meeting
tell application "zoom.us" to open location "zoom_url"

--volume & music
set volume output volume 70
tell application id "com.runningwithcrayons.Alfred" to run trigger "pause" in workflow "com.vdesabou.spotify.mini.player" with argument ""

-- OPEN DRAFTS FOR NOTE-TAKING
if (notes is "drafts") then
	-- open Drafts
	tell application "Drafts" to open location "drafts://x-callback-url/runaction?&action=Workspace-Basic%20(note-taking)"
	repeat until (application "Drafts" is running)
		delay 0.2
	end repeat

	-- wait till Zoom meeting has started
	set nameList to ""
	repeat until nameList contains "Zoom Meeting"
		tell application "System Events" to set nameList to name of windows of (processes whose name is "zoom.us")
		set nameList to item 1 of nameList
		delay 0.2
	end repeat
	delay 0.5

	-- put the unneeded window into the background
	tell application "System Events"
		tell process "zoom.us"
			set frontmost to true
			perform action "AXRaise" of (first window whose name is "Zoom")
		end tell
	end tell

	display notification "" with title "📝 Note Mode ready"
end if

-- MAXIMIZE ZOOM WHEN NOT A SPECIAL CONTEXT
if (notes is "none") then

	-- wait till Zoom meeting has started
	set nameList to ""
	repeat until nameList contains "Zoom Meeting"
		tell application "System Events" to set nameList to name of windows of (processes whose name is "zoom.us")
		set nameList to item 1 of nameList
		delay 0.2
	end repeat
	delay 0.5

	-- maximize Zoom
	tell application "System Events"
		tell process "zoom.us"
			set frontmost to true
			click menu item "Zoom" of menu "Window" of menu bar 1
		end tell
	end tell
end if

-- SEMINAR PREPARATION
if (notes contains "obsidian") then

	-- open Obsidian notes
	tell application "Obsidian"
		open location notes
		repeat until application "Obsidian" is running
			delay 0.2
		end repeat
		delay 0.1
	end tell

	-- Quit apps
	tell application "Twitterrific" to if it is running then quit
	tell application "Drafts" to if it is running then quit
	tell application "BusyCal" to if it is running then quit
	tell application "Discord" to if it is running then quit
	tell application "Slack" to if it is running then quit
	tell application "Mimestream" to if it is running then quit

	-- Pause
	repeat until (application "Mimestream" is not running)
		delay 0.2
	end repeat
	delay 0.1

	-- wait till Zoom meeting has started
	set meetingWindow to ""
	repeat until meetingWindow contains "Zoom Meeting"
		tell application "System Events" to set nameList to name of windows of (processes whose name is "zoom.us")
		set meetingWindow to item 1 of nameList
		delay 0.2
	end repeat
	delay 0.5

	-- put the unneeded window into the background
	tell application "System Events"
		tell process "zoom.us"
			set frontmost to true
			perform action "AXRaise" of (first window whose name is "Zoom")
		end tell
	end tell

	tell application "Excalidraw" to activate

end if
