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
	local sketchyfont, sketchybg

	-- neovim & highlights & hammerspoon
	if isDarkMode() then
		if appIsRunning("Highlights") then
			app("Highlights"):selectMenuItem { "View", "PDF Appearance", "Default" }
		end
		hs.execute([[echo "setThemeMode('light')" > /tmp/nvim-automation]]) -- requires setup in ~/.config/nvim/lua/file-watcher.lua
		setConsoleColors("light")
		sketchybg = "0xffcdcdcd"
		sketchyfont = "0xff000000"
	else
		if appIsRunning("Highlights") then
			app("Highlights"):selectMenuItem { "View", "PDF Appearance", "Night" }
		end
		hs.execute([[echo "setThemeMode('dark')" > /tmp/nvim-automation]])
		setConsoleColors("dark")
		sketchybg = "0xff333333"
		sketchyfont = "0xffffffff"
	end

	-- sketchybar
	hs.execute( 'BG_COLOR="'..sketchybg..'" ; FONT_COLOR="'..sketchyfont..'" ; '..
	[[sketchybar --bar color="$BG_COLOR" \
		--set drafts icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set sync-indicator icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set clock icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set weather icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set covid-stats icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--update
	]])

	-- Brave & System
	applescript([[
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
	]])

	app(prevApp):activate()
	holeCover() -- redraw hole-covers in proper color
end

---@return boolean
function isDarkMode()
	-- reading this via shell rather than applescript is less laggy
	local isDark = hs.execute([[defaults read -g AppleInterfaceStyle]]) == "Dark\n"
	return isDark
end

---@param toDark boolean true = dark, false = light
function setDarkmode(toDark)
	if (not (isDarkMode()) and toDark) or (isDarkMode() and not toDark) then toggleDarkMode() end
end

-- `del` mapped to f13 (so ⇧+⌫ can still be used for forward-deleting)
hotkey({}, "f13", toggleDarkMode)
hotkey({}, "f5", toggleDarkMode) -- for Apple Keyboards
