require("lua.utils")
--------------------------------------------------------------------------------

-- CONFIG
local brightnessThreshhold = 90

--------------------------------------------------------------------------------

local function brightnessNotify()
	local brightness = math.floor(hs.brightness.ambient())
	Notify("☀️ Brightness:", tostring(brightness))
end

-- notify with ambient brightness for Alfred
UriScheme("ambient-brightness", function()
	hs.application("Hammerspoon"):hide() -- so the previous app does not loose focus
	print("🌔 Manual Dark Mode Switch")
	brightnessNotify()
end)

-- done manually to include app-specific toggling for:
-- - Neovim
-- - Highlights PDF appearance
-- - Sketchybar
-- - Hammerspoon Console
local function toggleDarkMode()
	brightnessNotify()
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
	if AppIsRunning("Highlights") then
		App("Highlights"):selectMenuItem { "View", "PDF Appearance", pdfbg }
	end

	-- System
	Applescript([[
		tell application "System Events" to tell appearance preferences to set dark mode to not dark mode
	]])
	HoleCover() -- redraw hole-covers in proper color

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
end

---@return boolean
function IsDarkMode()
	-- reading this via shell rather than applescript is less laggy
	return hs.execute([[defaults read -g AppleInterfaceStyle]]) == "Dark\n"
end

---@param toDark boolean true = dark, false = light
function SetDarkmode(toDark)
	if (not (IsDarkMode()) and toDark) or (IsDarkMode() and not toDark) then toggleDarkMode() end
end

-- autoswitch dark mode and light mode depending on brightness
function AutoSwitchDarkmode()
	local brightness = hs.brightness.ambient()
	local hasBrightnessSensor = brightness > -1
	if not hasBrightnessSensor then return end

	if brightness > brightnessThreshhold and IsDarkMode() then
		SetDarkmode(false)
		print("🌔 Autoswitching to Dark Mode")
	elseif brightness < brightnessThreshhold and not (IsDarkMode()) then
		SetDarkmode(true)
		print("☀️ Autoswitching to Light Mode")
	end
end

--------------------------------------------------------------------------------

-- `del` mapped to f13 (so ⇧+⌫ can still be used for forward-deleting)
Hotkey({}, "f13", toggleDarkMode)
Hotkey({}, "f5", toggleDarkMode) -- for Apple Keyboards
