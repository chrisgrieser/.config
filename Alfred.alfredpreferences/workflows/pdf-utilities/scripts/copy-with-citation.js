#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	
}


	if (frontApp is "Highlights") then
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

		# find PDF in folder
		set pdfFolder to (system attribute "pdf_folder")
		set current_file to do shell script ("find " & (quoted form of pdfFolder) & " -type f -name " & (quoted form of filename))

		if current_file = "" then return "not-in-pdf-folder"
	end if
