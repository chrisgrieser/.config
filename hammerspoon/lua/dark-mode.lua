require("lua.utils")
--------------------------------------------------------------------------------

-- done manually to include app-specific toggling for:
-- - Brave Browser (fixing Dark Reader Bug)
-- - Neovim
-- - Highlights PDF appearance
-- - Sketchybar
-- - Hammerspoon Console
function toggleDarkMode()
	local prevApp = frontAppName()

	-- neovim & highlights & hammerspoon
	if isDarkMode() then
		if appIsRunning("Highlights") then
			app("Highlights"):selectMenuItem {"View", "PDF Appearance", "Default"}
		end
		hs.execute [[echo "setLightTheme()" > /tmp/nvim-automation]] -- requires setup in ~/.config/nvim/lua/file-watcher.lua
		setConsoleColors(false)
	else
		if appIsRunning("Highlights") then
			app("Highlights"):selectMenuItem {"View", "PDF Appearance", "Night"}
		end
		hs.execute [[echo "setDarkTheme()" > /tmp/nvim-automation]]
		setConsoleColors(true)
	end


	-- Brave & System
	applescript [[
		set openBlank to false
		tell application "Brave Browser"
			if ((count of window) is 0) then
				set openBlank to true
			else
				if ((URL of active tab of front window) starts with "chrome://") then set openBlank to true
			end if
			if (openBlank)
				open location "https://www.blank.org/"
				delay 0.4
			end if
		end tell

		tell application "System Events" to tell appearance preferences to set dark mode to not dark mode

		if (openBlank)
			delay 0.2
			tell application "Brave Browser" to close active tab of front window
		end if
	]]

	-- sketchybar
	hs.execute("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; brew services restart sketchybar")

	app(prevApp):activate()
	holeCover() -- redraw hole-covers in proper color

end

---@return boolean
function isDarkMode()
	-- reading this via shell rather than applescript is less laggy
	local isDark = hs.execute[[defaults read -g AppleInterfaceStyle]] == "Dark\n"
	return isDark
end

---@param toDark boolean true = dark, false = light
function setDarkmode(toDark)
	if (not (isDarkMode()) and toDark) or (isDarkMode() and not (toDark)) then
		toggleDarkMode()
	end
end

-- `del` mapped to f13 (so ⇧+⌫ can still be used for forward-deleting)
hotkey({}, "f13", toggleDarkMode)
hotkey({}, "f5", toggleDarkMode) -- for Apple Keyboards
