local M = {}

local console = require("appearance.console")
local holeCover = require("appearance.hole-cover")
local u = require("meta.utils")
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
	local applescript = 'tell application "System Events" to tell appearance preferences to set dark mode to '
		.. (toMode == "light" and "false" or "true")
	hs.osascript.applescript(applescript)

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
	holeCover.update()
end

-- MANUAL TOGGLING OF DARK MODE
-- forward-delete = `󰛨` on my keychron keyboard
hs.hotkey.bind({}, "forwarddelete", function() M.setDarkMode("toggle") end)

--------------------------------------------------------------------------------

-- autoswitch dark mode and light mode
-- If device has brightness sensor, uses a threshold to determine whether to
-- change. Otherwise, changes based on the time of day.
function M.autoSwitch()
	local lightThreshold = 70 -- CONFIG
	local ambient = hs.brightness.ambient()
	local hasBrightnessSensor = ambient > -1
	local targetMode

	if hasBrightnessSensor then
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
