#!/usr/bin/env osascript
set basePath to POSIX path of (path to desktop)
set baseName to "output"
set ext to ".png"

-- build initial filepath
set n to 0
repeat
	set suffix to ""
	if n > 0 then set suffix to "-" & n
	set filepath to basePath & baseName & suffix & ext
	try
		-- check if file exists
		alias filepath
		set n to n + 1
	on error
		exit repeat
	end try
end repeat

-- save clipboard PNG

set theImage to the clipboard as «class PNGf»
set thePath to POSIX file ((path to desktop folder as text) & "output.png") -- proper AppleScript path
set outFile to open for access thePath with write permission
try
    set eof outFile to 0
    write theImage to outFile
end try
close access outFile
set theImage to the clipboard as «class PNGf» -- typos: ignore-line
set outFile to open for access file filepath with write permission
set eof outFile to 0
write theImage to outFile
close access outFile
