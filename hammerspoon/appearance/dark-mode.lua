local M = {}

local console = require("appearance.console")
local holeCover = require("appearance.hole-cover")
local u = require("meta.utils")

--------------------------------------------------------------------------------

---@param msg string
local function logBrightness(msg)
	local ambient = hs.brightness.ambient()
	print(("💡 %s (ambient %.1f)"):format(msg, ambient)) -- `%.1f` = round to 1 decimal
end

--------------------------------------------------------------------------------

-- INFO done manually to include app-specific toggling for:
-- * System
-- * Neovim
-- * Sketchybar
-- * Highlights PDF appearance
-- * Hammerspoon Console
---@param toMode "dark"|"light"
function M.setDarkMode(toMode)
	-- System
	local applescript = 'tell application "System Events" to tell appearance preferences to set dark mode to '
		.. (toMode == "light" and "false" or "true")
	hs.osascript.applescript(applescript)

	-- sketchybar
	hs.execute(u.exportPath .. "sketchybar --reload")

	-- neovim
	local nvimLuaCmd = [[<cmd>lua vim.g.setColorscheme()<CR>]]
	local shellCmd = ("nvim --server '/tmp/nvim_server.pipe' --remote-send %q"):format(nvimLuaCmd)
	hs.execute(u.exportPath .. shellCmd)

	-- Highlights PDF background
	if u.appRunning("Highlights") then
		local pdfBg = toMode == "light" and "Sepia" or "Night"
		u.app("Highlights"):selectMenuItem { "View", "PDF Appearance", pdfBg }
	end

	-- hammerspoon itself
	console.setConsoleColors(toMode)
	holeCover.update()
end

-- MANUAL TOGGLING OF DARK MODE
-- forward-delete = `󰛨` on my Keychron keyboard
hs.hotkey.bind({}, "forwarddelete", function()
	local toMode = u.isDarkMode() and "light" or "dark"
	M.setDarkMode(toMode)
	logBrightness(("Manually toggled %s mode"):format(toMode))
end)

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
		logBrightness("Auto-switch to light mode. Threshold: " .. tostring(lightThreshold))
		M.setDarkMode("light")
	elseif targetMode == "dark" and not (u.isDarkMode()) then
		logBrightness("Auto-switch to dark mode. Threshold: " .. tostring(lightThreshold))
		M.setDarkMode("dark")
	end
end

--------------------------------------------------------------------------------
return M
