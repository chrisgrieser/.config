#!/usr/bin/env osascript

# INFO use "Finder window" instead of "window" to target only regular
# windows https://www.reddit.com/r/applescript/comments/uz9axo/comment/iayjrn4/?context=3

on run argv
	set itemPath to item 1 of argv
	tell application "Finder"
    activate
    if (count Finder windows) = 0 then return "No Finder window open."

    set targetFolder to target of Finder window 1 as alias
    set sourceItem to POSIX file itemPath as alias -- "as alias" ensures iCloud download

    if not (exists sourceItem) then return "File not available (iCloud)"

    move sourceItem to targetFolder with replacing
	 return -- return nothing, so Alfred notification is not triggered
end tell
end run
