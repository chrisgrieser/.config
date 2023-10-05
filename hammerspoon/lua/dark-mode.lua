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
local function toggleDarkMode()
	local toMode = u.isDarkMode() and "light" or "dark"

	-- neovim
	-- stylua: ignore
	local nvimLuaCmd = ([[<cmd>lua require('config.theme-customization').setThemeMode('%s')<CR>]]):format(toMode)
	local shellCmd = ([[nvim --server "/tmp/nvim_server.pipe" --remote-send "%s"]]):format(nvimLuaCmd)
	hs.execute(u.exportPath .. shellCmd)

	-- Highlights PDF background
	if u.appRunning("Highlights") then
		local pdfBg = u.isDarkMode() and "Default" or "Night"
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
	hs.execute(u.exportPath .. "sketchybar --reload")
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
	if ((u.isDarkMode()) and toDark) or (not u.isDarkMode() and not toDark) then return end
	toggleDarkMode()
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
