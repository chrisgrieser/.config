-- SOURCE https://mattias.arrelid.com/ramblings/a-better-way-to-get-alfred-to-use-ghostty-as-its-terminal/
--------------------------------------------------------------------------------

on alfred_script(shellCmd)
	-- `cd` -> do not trigger post-cd-hook (`-q`) and `clear` afterwards
	if (text 1 thru 3 of shellCmd) is "cd " then
		set arg to text 4 thru -1 of shellCmd
		-- leading space to suppress saving in shell history
		-- `-q` to suppress post-cd-hook output
		set shellCmd to " cd -q " & arg & " && clear"
	end if

	-- run the shortcut
	tell application "Shortcuts" to run shortcut named "ghostty-input" with input shellCmd
end alfred_script
