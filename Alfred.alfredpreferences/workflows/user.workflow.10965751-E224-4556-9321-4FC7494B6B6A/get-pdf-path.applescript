#!/usr/bin/env osascript

tell application "System Events" to set frontApp to (name of first process where it is frontmost)

# PDF Expert
# opens Finder and then lets the Finder part do its thing
if (frontApp is "PDF Expert") then
	tell application "System Events"
		tell process "PDF Expert"
			set frontmost to true
			click menu item "Save" of menu "File" of menu bar 1
			click menu item "Show in Finder" of menu "File" of menu bar 1
		end tell
	end tell
	delay 0.5
end if

# Highlights
# HACK to get filepath, requires "pdf_folder_highlights_app" being set
if (frontApp is "Highlights") then

	# resolved PDF Folder
	set pdfFolder to (system attribute "pdf_folder_highlights_app")
	set AppleScript's text item delimiters to "~/"
	set theTextItems to every text item of pdfFolder
	set AppleScript's text item delimiters to (POSIX path of (path to home folder as string))
	set pdfFolder to theTextItems as string

	# get File Name
	tell application "System Events"
		tell process "Highlights"
			set frontmost to true
			click menu item "Save" of menu "File" of menu bar 1
			if (count of windows) > 0 then set frontWindow to name of front window
		end tell
	end tell

	set AppleScript's text item delimiters to " – "
	set filename to text item 1 of frontWindow

	set current_file to do shell script ("find '" & pdfFolder & "' -type f -name '" & filename & "'")
end if

current_file # direct return

