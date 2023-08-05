#!/usr/bin/env osascript

tell application "System Events" to set frontApp to (name of first process where it is frontmost)

--------------------------------------------------------------------------------

# PDF EXPERT
# opens Finder, so the subsequent block can do it's work
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

--------------------------------------------------------------------------------

# FINDER
if (frontApp is "Finder" or frontApp is "PDF Expert") then
	tell application "Finder" to set sel to selection
	if ((count sel) = 0) then
		set current_file to "No file selected."
	else if ((count sel) = 1) then
		set current_file to POSIX path of (sel as text)
	else 
		set current_file to "More than one file selected."
	end if
end if

--------------------------------------------------------------------------------

# HIGHLIGHTS 
# HACK to get filepath
if (frontApp is "Highlights") then

	# resolved PDF Folder
	set pdfFolder to (system attribute "pdf_folder")
	set AppleScript's text item delimiters to "~/"
	set theTextItems to every text item of pdfFolder
	set AppleScript's text item delimiters to (POSIX path of (path to home folder as string))
	set pdfFolder to theTextItems as string

	# get file name
	tell application "System Events"
		tell process "Highlights"
			set frontmost to true
			click menu item "Save" of menu "File" of menu bar 1
			if (count of windows) > 0 then set frontWindow to name of front window
		end tell
	end tell
	set AppleScript's text item delimiters to " – "
	set filename to text item 1 of frontWindow

	# ensure ".pdf" is appended to the file name, if the user has hidden extensions
	set filename to do shell script ("filename=" & (quoted form of filename) & "; echo \"${filename%.pdf}.pdf\"")

	set current_file to do shell script ("find " & (quoted form of pdfFolder) & " -type f -name " & (quoted form of filename))
end if

--------------------------------------------------------------------------------

current_file # direct return

