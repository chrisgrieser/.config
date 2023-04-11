require("lua.utils")
--------------------------------------------------------------------------------

local function brightnessNotify()
	local brightness = math.floor(hs.brightness.ambient())
	if brightness > -1 then u.notify("☀️ Brightness:", tostring(brightness)) end
end

-- done manually to include app-specific toggling for:
-- - Neovim
-- - Highlights PDF appearance
-- - Sketchybar
-- - Hammerspoon Console
local function toggleDarkMode()
	brightnessNotify()
	local sketchyfont, sketchybg, toMode, pdfbg

	if u.isDarkMode() then
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
	hs.execute(string.format([[echo "SetThemeMode('%s')" > /tmp/nvim-automation]], toMode))

	-- Highlights PDF background
	if u.appRunning("Highlights") then
		u.app("Highlights"):selectMenuItem { "View", "PDF Appearance", pdfbg }
	end

	-- System
	u.applescript([[
		tell application "System Events" to tell appearance preferences to set dark mode to not dark mode
	]])
	HoleCover() -- must come after OS color change

	-- hammerspoon console
	SetConsoleColors() -- must come after OS color change

	-- sketchybar
	-- stylua: ignore
	hs.execute( 'BG_COLOR="'..sketchybg..'" ; FONT_COLOR="'..sketchyfont..'" ; '..
	[[sketchybar --bar color="$BG_COLOR" \
		--set sync-indicator icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set sidenotes-count icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set clock icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set weather icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set covid-stats icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--update
	]])
end

---@param toDark boolean true = dark, false = light
function SetDarkmode(toDark)
	if (not (u.isDarkMode()) and toDark) or (u.isDarkMode() and not toDark) then toggleDarkMode() end
end

-- autoswitch dark mode and light mode
-- If device has brightness sensor, uses a threshold to determine whether to
-- change. Otherwise, changes based on the time of day.
function AutoSwitchDarkmode()
	local brightness = hs.brightness.ambient()
	local hasBrightnessSensor = brightness > -1
	local targetMode
	local brightnessThreshhold = 90

	if hasBrightnessSensor then
		targetMode = brightness > brightnessThreshhold and "light" or "dark"
	else
		targetMode = u.betweenTime(7, 18) and "light" or "dark"
	end

	if targetMode == "light" and u.isDarkMode() then
		SetDarkmode(false)
		print("☀️ Auto-switching to Light Mode")
	elseif targetMode == "dark" and not (u.isDarkMode()) then
		SetDarkmode(true)
		print("🌔 Auto-switching to Dark Mode")
	end
end

--------------------------------------------------------------------------------

u.hotkey({}, "f13", toggleDarkMode) -- del key on Keychron Keyboard
