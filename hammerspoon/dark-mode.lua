require("utils")

function toggleDarkMode ()
	local targetMode = "dark"
	if isDarkMode() then targetMode = "light" end
	local prevApp = frontapp()

	hs.execute("zsh toggle-marta-darkmode.sh "..targetMode)

	hs.osascript.applescript([[
		if application "Brave Browser" is not running then
			launch
			delay 3
		end if
		set openBlank to false
		tell application "Brave Browser"
			if ((count of window) is 0) then
				set openBlank to true
			else
				if ((URL of active tab of front window) starts with "chrome://") then set openBlank to true
			end if
			if (openBlank)
				open location "https://www.blank.org/"
				delay 0.5
			end if
		end tell

		# toggle dark mode
		tell application "System Events"
			tell appearance preferences to set dark mode to not dark mode
		end tell

		if (openBlank)
			delay 0.2
			tell application "Brave Browser" to close active tab of front window
		end if

		# Make Highlights.app get the same mode as the OS mode (if running)
		tell application "System Events"
			tell appearance preferences to set isDark to dark mode
			if (isDark is false) then
				set targetView to "Default"
			else
				set targetView to "Night"
			end if

			set highlightsRunning to ((name of processes) contains "Highlights")
			if (highlightsRunning is true) then
				tell process "Highlights"
					set frontmost to true
					click menu item targetView of menu of menu item "PDF Appearance" of menu "View" of menu bar 1
				end tell
			end if
		end tell
	]])

	hs.application(prevApp):activate()
	menubarLine() ---@diagnostic disable-line: undefined-global
end

function isDarkMode()
	local _, isDark = hs.osascript.applescript('tell application "System Events" to return dark mode of appearance preferences')
	return isDark
end

function setDarkmode (toDark)
	if not(isDarkMode()) and toDark then toggleDarkMode() end
	if isDarkMode() and not(toDark) then toggleDarkMode() end
	log("🌒 Dark Mode: "..(tostring(isDarkMode())).." ("..deviceName()..")", "./logs/some.log")
end

function manualToggleDarkmode()
	toggleDarkMode()
	log ("🌒 Manual Toggle Darkmode ("..deviceName()..")", "./logs/some.log")
end

-- `hammerspoon://toggle-darkmode` for toggling via Shortcuts
hs.urlevent.bind("toggle-darkmode", function()
	manualToggleDarkmode()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
end)

-- del mapped to f13 (so ⇧+⌫ can still be used for forward-deleting)
hotkey({}, "f13", manualToggleDarkmode)
hotkey({}, "f5", manualToggleDarkmode) -- for Apple Keyboards
