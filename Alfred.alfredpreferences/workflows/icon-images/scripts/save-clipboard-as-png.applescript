#!/usr/bin/env osascript

-- target folder: frontwin or desktop
try 
	tell application "Finder" to set targetFolder to POSIX path of (insertion location as alias)
on error
	set targetFolder to POSIX path of (path to desktop)
end try
--------------------------------------------------------------------------------

-- build filepath
set timeStamp to do shell script "date +%Y-%m-%d_%H-%M-%S"
set filepath to targetFolder & "Clipboard_" & timeStamp & ".png"

-- save clipboard PNG
try
	set theImage to the clipboard as «class PNGf» -- typos: ignore-line
on error
	return "not an image" -- notification via Alfred
end try

set outFile to open for access (POSIX file filepath) with write permission
try
    set eof outFile to 0
    write theImage to outFile
end try
close access outFile

-- reveal in Finder
tell application "Finder"
	activate
	reveal ((POSIX file filepath) as alias)
end tell
return "" # return must be explicitly set to empty, otherwise return last var
