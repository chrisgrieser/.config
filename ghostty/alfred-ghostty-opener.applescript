-- AlfredGhostty Script v1.3.0
-- Latest version: https://github.com/zeitlings/alfred-ghostty-script

-- tab : t | window: n | split: d | quick terminal: qt
property open_new : "t"
property run_cmd : true
property reuse_tab : true
property timeout_seconds : 3
property shell_load_delay : 0.03 -- Delay for session to load
property switch_delay : 0.35 -- Delay when switching windows

on isRunning()
	application "Ghostty" is running
end isRunning

on summon()
	tell application "Ghostty" to activate
end summon

on hasWindows()
	if not isRunning() then return false
	tell application "System Events"
		return exists window 1 of process "Ghostty"
	end tell
end hasWindows

on waitForWindow(timeout_s)
	set end_time to (current date) + timeout_s
	repeat until hasWindows() or ((current date) > end_time)
		delay 0.05
	end repeat
	return hasWindows()
end waitForWindow

on handleWindow(just_activated)
	if just_activated then
		return
	end if
	-- if `open_new` is `n`, i.e. signals to open a new window then open it 
	-- on the active desktop space rather than switching to an existing instance
	-- Scrapped. This is currently not possible.
	-- delay switch_delay -- we might be switching to the existing window
	set has_windows to hasWindows()
	set needs_window to not has_windows
	set override_reuse to (reuse_tab and not has_windows)
	tell application "System Events"
		if needs_window or override_reuse then
			keystroke "n" using command down -- New window
			return
		end if
		if not reuse_tab then
			if open_new is "d" and has_windows then
				keystroke "d" using command down -- New split right
			else
				keystroke open_new using command down -- New window or tab
			end if
		end if
	end tell
end handleWindow

on log_(a_prefix, a_message)
	do shell script "echo \"[$(date +%Y%m%d-%H%M%S)]\"  '" & quoted form of a_prefix & quoted form of a_message & "' >> /tmp/alfred_ghostty/debug.log"
end log_

on send(a_command, just_activated)
	if not just_activated then
		delay switch_delay -- we might be switching to an existing window
	end if
	set had_windows to hasWindows()
	handleWindow(just_activated)

	if (text 1 thru 3 of a_command) is "cd " then
		set arg to text 4 thru -1 of a_command
		-- leading space to suppress saving in shell history
		-- `-q` to suppress post-cd-hook output
		set a_command to " cd -q " & arg & " && clear"
	end if
	
	-- Only wait for shell load if:
	-- 1. We just activated Ghostty, or
	-- 2. We created a new window/tab/split (i.e., not reusing)
	-- 3. There was no window to reuse (had_windows was false)
	--if just_activated or (not reuse_tab and not had_windows) then
	if just_activated or not reuse_tab or (reuse_tab and not had_windows) then
		delay shell_load_delay
	end if
	if not waitForWindow(1) then -- Additional fail-safe
		display dialog "Failed to verify window exists"
		return
	end if
	
	-- I've been experiencing unsolicited capitalization of commands.
	-- The convoluted workaround below attempts to make sure the
	--  'Open Terminal Here' Universal Action is also handled properly.
	do shell script "mkdir -p /tmp/alfred_ghostty"
	set cmd_file to "/tmp/alfred_ghostty/cmd.txt"
	do shell script "echo " & quoted form of a_command & " | iconv -t utf-8 > " & cmd_file -- Write command to file with explicit UTF-8 encoding
	
	try
		-- Works with editor, always fails with Alfred
		set backup to the clipboard as text
		delay 0.1
	on error errorMessage as text
		-- Ignore and sacrifice the clipboard contents
		--log_("Error backing up clipboard: ", errorMessage)
	end try
	
	-- Debug: Log the command content
	--log_("Command passed: ", a_command)
	--log_("File content: ", "$(cat " & cmd_file & ")")
	
	do shell script "cat " & cmd_file & " | tr -d '\\n' | pbcopy" -- Copy file contents to clipboard
	delay 0.1
	
	tell application "System Events"
		tell process "Ghostty"
			keystroke "v" using command down
			if run_cmd then
				delay 0.1
				keystroke return
			end if
		end tell
	end tell
	
	-- TODO: Could be improved by checking if the clipboard contains other formats such as files.
	-- Maybe restoring them as POSIX paths or aliases could restore those again.
	-- However, currently even plain text recovery fails when going through Alfred.
	try
		tell application "System Events"
			set the clipboard to backup & (delay 0.1)
		end tell
		log {"Success. Backup has been restored to: ", backup as text}
	on error errorMessage
		-- Ignore the failed recovery
		-- log "Failure. Unable to restore backup: " & errorMessage as text 
		-- log_ {"Failure: ", "Unable to restore backup"} -- ignore
	end try
	-- do shell script "rm " & cmd_file
	
end send

on send_quick_terminal(a_command, needs_wakeup)
	if needs_wakeup then
		summon()
	end if
	
	do shell script "mkdir -p /tmp/alfred_ghostty"
	set cmd_file to "/tmp/alfred_ghostty/cmd.txt"
	do shell script "echo " & quoted form of a_command & " | iconv -t utf-8 > " & cmd_file
	do shell script "cat " & cmd_file & " | tr -d '\\n' | pbcopy" -- Copy file contents to clipboard
	delay 0.1
	
	tell application "System Events"
		tell process "Ghostty"
			set viewMenu to menu 1 of menu bar item "View" of menu bar 1
			set quickTermItem to menu item "Quick Terminal" of viewMenu
			click quickTermItem
			--delay 0.1
			keystroke "v" using command down
			if run_cmd then
				delay 0.1
				keystroke return
			end if
		end tell
	end tell
	
end send_quick_terminal

on alfred_script(query)
	
	if open_new is "qt" then
		send_quick_terminal(query, not isRunning())
	else
		set just_activated to not isRunning()
		summon()
		if just_activated then
			if not waitForWindow(timeout_seconds) then
				display dialog "Failed to create initial window"
				return
			end if
		end if
		send(query, just_activated)
	end if
end alfred_script
