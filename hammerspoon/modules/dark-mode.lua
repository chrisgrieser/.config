local M = {}

local console = require("modules.console")
local env = require("modules.environment-vars")
local u = require("modules.utils")
local visuals = require("modules.visuals")
--------------------------------------------------------------------------------

-- INFO done manually to include app-specific toggling for:
-- * System
-- * Neovim
-- * Sketchybar
-- * Highlights PDF appearance
-- * Hammerspoon Console
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
	local nvimLuaCmd = [[<cmd>lua require('config.theme-customization').updateColorscheme()<CR>]]
	local shellCmd = ("nvim --server '/tmp/nvim_server.pipe' --remote-send %q"):format(nvimLuaCmd)
	hs.execute(u.exportPath .. shellCmd)

	-- Highlights PDF background
	if u.appRunning("Highlights") then
		local pdfBg = toMode == "light" and "Default" or "Night"
		u.app("Highlights"):selectMenuItem { "View", "PDF Appearance", pdfBg }
	end

	-- hammerspoon itself
	console.setConsoleColors(toMode)
	visuals.updateHoleCover()
end

-- MANUAL TOGGLING OF DARK MODE
-- `del` -> `f13` (Keychrone Keyboard) via Karabiner
hs.hotkey.bind({}, "f13", function() M.setDarkMode("toggle") end)

--------------------------------------------------------------------------------

-- autoswitch dark mode and light mode
-- If device has brightness sensor, uses a threshold to determine whether to
-- change. Otherwise, changes based on the time of day.
function M.autoSwitch()
	if env.isProjector() then return end
	local ambient = hs.brightness.ambient()
	local hasBrightnessSensor = ambient > -1
	local targetMode
	local lightThreshold = 85 -- CONFIG

	if hasBrightnessSensor then
		local ambientRounded = string.format("%.1f", ambient) -- round to 1 decimal
		print(("💡 auto-switch: ambient %s, threshold %s"):format(ambientRounded, lightThreshold))
		targetMode = ambient > lightThreshold and "light" or "dark"
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
