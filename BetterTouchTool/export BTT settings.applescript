#!/usr/bin/env osascript

set home to POSIX path of (path to home folder as string)
set exportPath to home & "/.config/BetterTouchTool/Base.bttpreset"

-- https://docs.folivora.ai/docs/1102_apple_script.html
tell application "BetterTouchTool"
	export_preset "Base" outputPath exportPath with includeSettings
end tell

tell application "Finder"
	activate
	reveal (exportPath as POSIX file)
end tell
