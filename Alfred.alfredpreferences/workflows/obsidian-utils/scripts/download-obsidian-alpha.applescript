#!/usr/bin/env osascript

# open #alpha-testing channel
open location "discord://discord.com/channels/686053708261228577/989603365606531104"
delay 0.3

tell application "System Events" 
	-- open pinned messages
	keystroke "p" using {command down}

	-- 3x tab -> goto latest alpha
	key code 48
	key code 48
	key code 48

	-- not confirming, since the above is not 100% reliable
end tell

