use framework "AppKit"
set allFrames to (current application's NSScreen's screens()'s valueForKey:"frame") as list
set max_x to item 1 of item 2 of item 1 of allFrames
set max_y to item 2 of item 2 of item 1 of allFrames

set x to 0.2 * max_x
set y to 0.1 * max_y
set w to 0.6 * max_x
set h to 0.8 * max_y
tell application "Finder" to set bounds of window 1 to {x, y, x + w, y + h}
