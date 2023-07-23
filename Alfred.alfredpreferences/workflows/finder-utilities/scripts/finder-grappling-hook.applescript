#!/usr/bin/env osascript

set home to POSIX path of (path to home folder as string)
set wd to (home & "Library/Mobile Documents/com~apple~CloudDocs/File Hub/")
set dotfile_folder to (home & ".config/")
set vault_path to (home & "main-vault/")

--------------------------------------------------------------------------------

tell application "Finder"
	if (front window exists) then
		set current_path to POSIX path of (target of front window as alias)

		set toOpen to wd
		if (current_path is wd) then set toOpen to dotfile_folder
		if (current_path is dotfile_folder) then set toOpen to vault_path
		if (current_path is vault_path) then set toOpen to wd

		set target of front Finder window to (toOpen as POSIX file)
	end if
end tell
