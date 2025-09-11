#!/usr/bin/env osascript
on run argv
  set screenshot_file to POSIX file (item 1 of argv)
  tell application "Finder" to set the clipboard to (screenshot_file)
end run
