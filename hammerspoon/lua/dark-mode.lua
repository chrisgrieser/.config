local M = {}

local console = require("lua.console")
local u = require("lua.utils")
local visuals = require("lua.visuals")
--------------------------------------------------------------------------------

-- done manually to include app-specific toggling for:
-- - Neovim
-- - Highlights PDF appearance
-- - Sketchybar
-- - Hammerspoon Console
-- - SideNotes
local function toggleDarkMode()
	local sidenotesDark = "City Lights"
	local sidenotesLight = "Monterey"

	local sketchyfont, sketchybg, toMode, pdfbg, sidenotesTheme

	if u.isDarkMode() then
		toMode = "light"
		pdfbg = "Default"
		sketchybg = "0xffcdcdcd"
		sketchyfont = "0xff000000"
		sidenotesTheme = sidenotesLight
	else
		toMode = "dark"
		pdfbg = "Night"
		sketchybg = "0xff333333"
		sketchyfont = "0xffffffff"
		sidenotesTheme = sidenotesDark
	end

	-- neovim
	local nvimLuaCmd = ([[require('config.theme-config').setThemeMode('%s')]]):format(toMode)
	hs.execute(([[nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>lua %s<CR>"]]):format(nvimLuaCmd))

	-- Highlights PDF background
	if u.appRunning("Highlights") then
		u.app("Highlights"):selectMenuItem { "View", "PDF Appearance", pdfbg }
	end

	-- System
	u.applescript([[
		tell application "System Events" to tell appearance preferences to set dark mode to not dark mode
	]])
	visuals.holeCover() -- must come after OS color change

	-- hammerspoon console
	console.setConsoleColors() -- must come after OS color change

	-- sketchybar
	-- stylua: ignore
	hs.execute(([[
		export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
		BG_COLOR='%s'
		FONT_COLOR='%s'
		sketchybar --bar color="$BG_COLOR" \
		--set sync-indicator icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set sidenotes-count icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set clock icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set weather icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--set covid-stats icon.color="$FONT_COLOR" label.color="$FONT_COLOR" \
		--update
	]]):format(sketchybg, sketchyfont))

	-- SideNotes
	-- stylua: ignore
	local themePath = os.getenv("HOME") .. "/Library/Application Support/com.apptorium.SideNotes-paddle/themes"
	local builtInThemes = { "Classic", "Retro", "Dark Blue", "Graphite Gray", "Default" }
	if u.tbl_contains(builtInThemes, sidenotesTheme) then
		themePath = "/Applications/SideNotes.app/Contents/Resources"
	end
	local jxaCmd = ([[Application("SideNotes").setTheme("%s/%s.sntheme")]]):format(
		themePath,
		sidenotesTheme
	)
	local shellCmd = ([[osascript -l JavaScript -e '%s']]):format(jxaCmd)
	hs.execute(shellCmd)
end

u.hotkey({}, "f13", toggleDarkMode) -- `del` key on Keychron Keyboard

--------------------------------------------------------------------------------

---@param toDark boolean true = dark, false = light
function M.set(toDark)
	if (not (u.isDarkMode()) and toDark) or (u.isDarkMode() and not toDark) then toggleDarkMode() end
end

-- autoswitch dark mode and light mode
-- If device has brightness sensor, uses a threshold to determine whether to
-- change. Otherwise, changes based on the time of day.
function M.AutoSwitch()
	local brightness = hs.brightness.ambient()
	local hasBrightnessSensor = brightness > -1
	local targetMode
	local brightnessThreshhold = 90

	if hasBrightnessSensor then
		targetMode = brightness > brightnessThreshhold and "light" or "dark"
	else
		targetMode = u.betweenTime(7, 20) and "light" or "dark"
	end

	if targetMode == "light" and u.isDarkMode() then
		M.set(false)
		print("☀️ Auto-switching to Light Mode")
	elseif targetMode == "dark" and not (u.isDarkMode()) then
		M.set(true)
		print("🌔 Auto-switching to Dark Mode")
	end
end

--------------------------------------------------------------------------------
return M
