local M = {}

local console = require("appearance.console")
local holeCover = require("appearance.hole-cover")
local u = require("meta.utils")

--------------------------------------------------------------------------------

---@param msg string
---@param threshold? number
local function logBrightness(msg, threshold)
	local ambientText = ("ambient: %.1f"):format(hs.brightness.ambient()) -- `%.1f` = round to 1 decimal
	local info = threshold and ("(threshold: %d, %s)"):format(threshold, ambientText)
		or ("(%s)"):format(ambientText)
	print(("💡 %s %s"):format(msg, info))
end

--------------------------------------------------------------------------------

-- INFO done manually to include app-specific toggling for:
-- * System
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
		logBrightness("Auto-switch to light mode.", lightThreshold)
		M.setDarkMode("light")
	elseif targetMode == "dark" and not (u.isDarkMode()) then
		logBrightness("Auto-switch to dark mode.", lightThreshold)
		M.setDarkMode("dark")
	else
		logBrightness("Auto-switch skipped.", lightThreshold)
	end
end

--------------------------------------------------------------------------------
return M
