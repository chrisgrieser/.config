#!/usr/bin/env osascript

on run argv
	-- https://apple.stackexchange.com/a/15542
	set filepath to (text item 1 of argv)
	set the clipboard to (POSIX file filepath)

	-- https://apple.stackexchange.com/a/236600
	set filename to name of (info for filepath)
	return filename # for notification
end run
