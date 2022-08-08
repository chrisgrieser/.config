#!/usr/bin/env osascript
use framework "AppKit"

delay 0.3
set allFrames to (current application's NSScreen's screens()'s valueForKey:"frame") as list
set screenWidth to item 1 of item 2 of item 1 of allFrames

set x to screenWidth - 50
set y to 60

tell application "System Events" to click at {x, y} -- click "Call" on the notice

do shell script "STATUS=$(spt playback --status --format=%s) ; [[ \"$STATUS\" != \"⏸\" ]] && spt playback --toggle"
