#!/usr/bin/env osascript

-- INFO backuped here, since changing PWA can make this script inaccessible from
-- BTT settings

-- go to home (assuming Vimium)
tell application "System Events"
	key code 53 -- leave fullscreen
	delay 0.06
	keystroke "g"
	keystroke "u"
end tell

--------------------------------------------------------------------------------

-- -- slower method, but more reliable and not requiring vimium
-- tell application "YouTube"
-- 	quit
-- 	delay 0.1
-- 	launch
-- end tell
