local M = {}

local console = require("lua.console")
local env = require("lua.environment-vars")
local u = require("lua.utils")
local visuals = require("lua.visuals")
--------------------------------------------------------------------------------

-- INFO done manually to include app-specific toggling for:
-- - Neovim
-- - Highlights PDF appearance
-- - Sketchybar
-- - Hammerspoon Console
---@param toMode "dark"|"light"|"toggle"
function M.setDarkMode(toMode)
	if toMode == "toggle" then toMode = u.isDarkMode() and "light" or "dark" end
	---@cast toMode "dark"|"light"

	-- System
	local bool = toMode == "light" and "false" or "true"
	hs.osascript.applescript(
		'tell application "System Events" to tell appearance preferences to set dark mode to ' .. bool
	)

	-- sketchybar
	hs.execute(u.exportPath .. "sketchybar --reload")

	-- neovim
	-- stylua: ignore
	local nvimLuaCmd = [[<cmd>lua require('config.theme-customization').updateTheme()<CR>]]
	hs.execute(
		u.exportPath
			.. ([[nvim --server "/tmp/nvim_server.pipe" --remote-send %q]]):format(nvimLuaCmd)
	)

	-- Highlights PDF background
	if u.appRunning("Highlights") then
		local pdfBg = toMode == "light" and "Default" or "Night"
		u.app("Highlights"):selectMenuItem { "View", "PDF Appearance", pdfBg }
	end

	-- hammerspoon
	console.setConsoleColors(toMode)
	visuals.updateHoleCover()
end

-- MANUAL TOGGLING OF DARK MODE
-- `del` key on Keychron Keyboard
hs.hotkey.bind({}, "f13", function()
	M.setDarkMode("toggle")

	-- notify on brightness level
	local brightness = math.floor(hs.brightness.ambient())
	local hasBrightnessSensor = brightness > -1
	if not hasBrightnessSensor then return end
	u.notify("☀️ Brightness: " .. brightness)
end)

--------------------------------------------------------------------------------

-- autoswitch dark mode and light mode
-- If device has brightness sensor, uses a threshold to determine whether to
-- change. Otherwise, changes based on the time of day.
function M.autoSwitch()
	if env.isProjector() then return end
	local brightness = hs.brightness.ambient()
	local hasBrightnessSensor = brightness > -1
	local targetMode
	local brightnessThreshold = 90

	if hasBrightnessSensor then
		targetMode = brightness > brightnessThreshold and "light" or "dark"
	else
		targetMode = u.betweenTime(7, 20) and "light" or "dark"
	end

	if targetMode == "light" and u.isDarkMode() then
		M.setDarkMode("light")
		print("☀️ Auto-switching to Light Mode")
	elseif targetMode == "dark" and not (u.isDarkMode()) then
		M.setDarkMode("dark")
		print("🌔 Auto-switching to Dark Mode")
	end
end

--------------------------------------------------------------------------------
return M
