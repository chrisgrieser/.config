local M = {}

local u = require("meta.utils")

---METHODS----------------------------------------------------------------------

---@param msg string
---@param threshold? number
local function logBrightness(msg, threshold)
	local ambientText = ("ambient: %.1f"):format(hs.brightness.ambient()) -- `%.1f` = round to 1 decimal
	local info = threshold and ("(threshold: %d, %s)"):format(threshold, ambientText)
		or ("(%s)"):format(ambientText)
	print(("🌗 %s %s"):format(msg, info))
end

function M.autoSetBrightness()
	local ambient = hs.brightness.ambient()
	local noBrightnessSensor = ambient == -1
	if noBrightnessSensor then return end

	local target = ambient > 90 and 1
		or ambient > 50 and 0.9
		or ambient > 30 and 0.8
		or ambient > 15 and 0.7
		or ambient > 1 and 0.6
		or 0.5

	print(("💡 ambient brightness: %.1f -> setting brightness to %s"):format(ambient, target))
	local iMacDisplay = require("win-management.window-utils").iMacDisplay
	iMacDisplay:setBrightness(target)
end

-- INFO done manually to include app-specific toggling for:
-- * System
-- * Sketchybar
-- * PDF appearance
-- * Hammerspoon Console
---@param toMode "dark"|"light"
function M.setDarkMode(toMode)
	-- System
	local applescript = 'tell application "System Events" to tell appearance preferences to set dark mode to '
		.. (toMode == "light" and "false" or "true")
	hs.osascript.applescript(applescript)

	-- sketchybar
	-- delay so sketchybar picks up on system mode change
	u.defer(2, function() hs.execute(u.exportPath .. "sketchybar --reload") end)

	-- PDF background
	if u.appRunning("Highlights") then
		local pdfBg = toMode == "light" and "Default" or "Night"
		u.app("Highlights"):selectMenuItem { "View", "PDF Appearance", pdfBg }
	end
	if u.appRunning("PDF Expert") then
		local pdfBg = toMode == "light" and "Day" or "Night"
		u.app("PDF Expert"):selectMenuItem { "View", "Theme", pdfBg }
	end

	-- hammerspoon itself
	require("appearance.console").setConsoleColors(toMode)
	require("appearance.hole-cover").update()
end

---MANUALLY TOGGLE DARK MODE----------------------------------------------------
-- forward-delete = light-bulb-key on my Keychron keyboard
hs.hotkey.bind({}, "forwarddelete", function()
	local toMode = u.isDarkMode() and "light" or "dark"
	M.setDarkMode(toMode)
	logBrightness(("Manually toggled %s mode"):format(toMode))
end)

---AUTO-SWITCH DARK MODE--------------------------------------------------------

-- autoswitch dark mode and light mode
-- If device has brightness sensor, uses a threshold to determine whether to
-- change. Otherwise, changes based on the time of day.
function M.autoSwitch()
	local lightThreshold = 60 -- CONFIG
	local ambient = hs.brightness.ambient()
	local hasBrightnessSensor = ambient > -1

	local targetMode = hasBrightnessSensor and (ambient > lightThreshold and "light" or "dark")
		or (u.betweenTime(7, 20) and "light" or "dark")

	if targetMode == "light" and u.isDarkMode() then
		logBrightness("Auto-switch to light.", lightThreshold)
		M.setDarkMode("light")
	elseif targetMode == "dark" and not (u.isDarkMode()) then
		logBrightness("Auto-switch to dark.", lightThreshold)
		M.setDarkMode("dark")
	else
		logBrightness("Auto-switch skipped.", lightThreshold)
	end
end

--------------------------------------------------------------------------------
return M
