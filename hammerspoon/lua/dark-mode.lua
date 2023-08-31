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
	local toMode, pdfBg, sidenotesTheme 

	if u.isDarkMode() then
		toMode = "light"
		pdfBg = "Default"
		sidenotesTheme = "Marshmallow"
	else
		toMode = "dark"
		pdfBg = "Night"
		sidenotesTheme = "Grapes and Berries"
	end

	-- neovim
	-- stylua: ignore
	local nvimLuaCmd = ([[<cmd>lua require('config.theme-customization').setThemeMode('%s')<CR>]]):format(toMode)
	local shellCmd1 = ([[nvim --server "/tmp/nvim_server.pipe" --remote-send "%s"]]):format(nvimLuaCmd)
	hs.execute(u.exportPath .. shellCmd1)

	-- Highlights PDF background
	if u.appRunning("Highlights") then
		u.app("Highlights"):selectMenuItem { "View", "PDF Appearance", pdfBg }
	end

	-- System
	u.applescript(
		'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode'
	)
	visuals.holeCover() -- must come after OS color change

	-- hammerspoon console
	console.setConsoleColors() -- must come after OS color change

	-- sketchybar
	-- stylua: ignore
	hs.execute(u.exportPath .. 'sketchybar --reload')

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
	local shellCmd2 = ([[osascript -l JavaScript -e '%s']]):format(jxaCmd)
	hs.execute(shellCmd2)
end

-- MANUAL TOGGLING OF DARK MODE
-- `del` key on Keychron Keyboard
u.hotkey({}, "f13", function()
	toggleDarkMode()
	local brightness = math.floor(hs.brightness.ambient())
	local hasBrightnessSensor = brightness > -1
	if hasBrightnessSensor then u.notify("☀️ Brightness:", tostring(brightness)) end
end)

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
