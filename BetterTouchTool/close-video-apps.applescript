#!/usr/bin/env osascript

-- this also closes all PWAs
tell application "Brave Browser" to close (every tab in every window)

tell application "Finder" to close every window
tell application "IINA" to quit
