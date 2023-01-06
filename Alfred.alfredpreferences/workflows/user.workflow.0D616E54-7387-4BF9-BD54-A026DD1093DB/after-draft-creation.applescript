#!/usr/bin/env osascript
set prevApp to (system attribute "focusedapp")

if prevApp = "" then
	tell application "Neovide" to activate
else
	tell application (system attribute "focusedapp") to activate
end if

-- via shell to open in background
do shell script ("open -g 'hammerspoon://update-drafts-menubar'")
