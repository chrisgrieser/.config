#!/usr/bin/env osascript
set home to POSIX path of (path to home folder as string)

-- CONFIG
set wd to (home & "Library/Mobile Documents/com~apple~CloudDocs/File Hub/")
set dotfile_folder to (home & ".config/")

--------------------------------------------------------------------------------
-- INFO finder win instead of win ensures it's a regular window, not QuickLook or prompt 
tell application "Finder" 
	if not (front Finder window exists) then return 
	 
	set current_path to POSIX path of (target of front Finder window as alias) 
	 
	set toOpen to wd 
	if (current_path is wd) then set toOpen to dotfile_folder 
	 
	set target of front Finder window to (toOpen as POSIX file) 
end tell 
