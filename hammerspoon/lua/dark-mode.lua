require("lua.utils")
--------------------------------------------------------------------------------

local function brightnessNotify()
	local brightness = math.floor(hs.brightness.ambient())
	notify("Brightness: ", tostring(brightness))	
end

-- notify with ambient brightness for Alfred
uriScheme("ambient-brightness", function ()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
	brightnessNotify()
end)

-- done manually to include app-specific toggling for:
-- - Brave Browser (fixing Dark Reader Bug)
-- - Neovim
-- - Highlights PDF appearance
-- - Sketchybar
-- - Hammerspoon Console
local function toggleDarkMode()
	brightnessNotify()
	local prevApp = frontAppName()
	local sketchyfont, sketchybg, toMode, pdfbg

	if IsDarkMode() then
		pdfbg = "Default"
		toMode = "light"
		sketchybg = "0xffcdcdcd"
		sketchyfont = "0xff000000"
	else
		pdfbg = "Night"
		toMode = "dark"
		sketchybg = "0xff333333"
		sketchyfont = "0xffffffff"
	end

	-- neovim (requires setup in ~/.config/nvim/lua/file-watcher.lua)
	hs.execute([[echo "SetThemeMode(']] .. toMode .. [[')" > /tmp/nvim-automation]]) 

	-- hammerspoon console
	SetConsoleColors(toMode)

	-- Highlights PDF background
	if appIsRunning("Highlights") then
		app("Highlights"):selectMenuItem { "View", "PDF Appearance", pdfbg }
	end

	-- System & Brave (Workaround for Dark Reader)
	applescript([[
		tell application "Brave Browser"
			set openBlank to false
			if ((count of window) is 0) then
				set openBlank to true
			else if ((URL of active tab of front window) starts with "chrome://") then
				set openBlank to true
			end if
		end tell
		if (openBlank) then
			open location "https://www.blank.org/"
			delay 0.4
			tell application "System Events" to tell appearance preferences to set dark mode to not dark mode
			delay 0.2
			tell application "Brave Browser" to close active tab of front window
		else
			tell application "System Events" to tell appearance preferences to set dark mode to not dark mode
		end if
	]])

	-- sketchybar
	-- stylua: ignore
	hs.execute( 'BG_COLOR="'..sketchybg..'" ; FONT_COLOR="'..sketchyfont..'" ; '..
	[[sketchybar --bar color="$BG_COLOR" \
		--set drafts icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set sync-indicator icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set clock icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set weather icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set covid-stats icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--update
	]])

	app(prevApp):activate()
	HoleCover() -- redraw hole-covers in proper color
end

---@return boolean
function IsDarkMode()
	-- reading this via shell rather than applescript is less laggy
	local isDark = hs.execute([[defaults read -g AppleInterfaceStyle]]) == "Dark\n"
	return isDark
end

---@param toDark boolean true = dark, false = light
function SetDarkmode(toDark)
	if (not (IsDarkMode()) and toDark) or (IsDarkMode() and not toDark) then toggleDarkMode() end
end

-- `del` mapped to f13 (so ⇧+⌫ can still be used for forward-deleting)
hotkey({}, "f13", toggleDarkMode)
hotkey({}, "f5", toggleDarkMode) -- for Apple Keyboards
