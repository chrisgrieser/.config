require("lua.utils")
--------------------------------------------------------------------------------

function toggleDarkMode()
	local prevApp = frontApp()
	local targetMode
	local highlightsView
	if isDarkMode() then
		targetMode = "light"
		highlightsView = "Default"
	else
		targetMode = "dark"
		highlightsView = "Night"
	end

	hs.execute("zsh ./helpers/toggle-marta-darkmode.sh " .. targetMode)
	if appIsRunning("Highlights") then
		app("Highlights"):selectMenuItem {"View", "PDF Appearance", highlightsView}
	end

	applescript[[
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
	]]
	hs.execute("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; brew services restart sketchybar") -- restart instead of reload to load colors

	app(prevApp):activate()
	holeCover() ---@diagnostic disable-line: undefined-global
end

---@return boolean
function isDarkMode()
	local _, isDark = applescript('tell application "System Events" to return dark mode of appearance preferences')
	return isDark ---@diagnostic disable-line: return-type-mismatch
end

---@param toDark boolean true = dark, false = light
function setDarkmode(toDark)
	if (not (isDarkMode()) and toDark) or (isDarkMode() and not(toDark)) then
		toggleDarkMode()
	end
end

-- `hammerspoon://toggle-darkmode` for toggling via Shortcuts
uriScheme("toggle-darkmode", function()
	toggleDarkMode()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
end)

-- del mapped to f13 (so ⇧+⌫ can still be used for forward-deleting)
hotkey({}, "f13", toggleDarkMode)
hotkey({}, "f5", toggleDarkMode) -- for Apple Keyboards
