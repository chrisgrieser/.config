local M = {}

local env = require("meta.environment")

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

	print(("💡 ambient: %.1f -> setting brightness to %s"):format(ambient, target))
	local iMacDisplay = require("win-management.window-utils").iMacDisplay
	if iMacDisplay then iMacDisplay:setBrightness(target) end
end

function M.darkenImacDisplay()
	local iMacDisplay = require("win-management.window-utils").iMacDisplay
	if iMacDisplay then iMacDisplay:setBrightness(0) end
end

-- System, Neovim, Hammerspoon Console
---@param toMode "dark"|"light"
function M.setDarkMode(toMode)
	-- System
	local applescript = 'tell application "System Events" to tell appearance preferences to set dark mode to '
		.. (toMode == "light" and "false" or "true")
	hs.osascript.applescript(applescript)

	-- Neovim
	local nvimLuaCmd = ("<cmd>lua vim.g.setColorscheme(%q)<CR>"):format(toMode)
	local shellCmd = ("nvim --server '/tmp/nvim_server.pipe' --remote-send %q"):format(nvimLuaCmd)
	hs.execute(U.exportPath .. shellCmd)

	-- Hammerspoon itself
	require("appearance.console").setConsoleColors(toMode)
	require("appearance.hole-cover").update()
end

---CHANGING DARK MODE--------------------------------------------------------

-- AUTOMATIC
-- If device has brightness sensor, uses a threshold to determine whether to
-- change. Otherwise, changes based on the time of day.
function M.autoSwitch()
	local lightThreshold = 60 -- CONFIG
	local ambient = hs.brightness.ambient()
	local hasBrightnessSensor = ambient > -1

	local targetMode = hasBrightnessSensor and (ambient > lightThreshold and "light" or "dark")
		or (U.betweenTime(7, 18) and "light" or "dark")

	if targetMode == "light" and U.isDarkMode() then
		logBrightness("Auto-switch to light", lightThreshold)
		M.setDarkMode("light")
	elseif targetMode == "dark" and not (U.isDarkMode()) then
		logBrightness("Auto-switch to dark", lightThreshold)
		M.setDarkMode("dark")
	else
		logBrightness("No auto-switch", lightThreshold)
	end
end

-- MANUAL
-- `forward-delete` key = light-bulb-key on my Keychron keyboard
hs.hotkey.bind({}, "forwarddelete", function()
	local toMode = U.isDarkMode() and "light" or "dark"
	M.setDarkMode(toMode)
	logBrightness(("Manually toggled %s mode"):format(toMode))
end)

---WATCHERS FOR DARK MODE AND BRIGHTNESS----------------------------------------

local c = hs.caffeinate.watcher
M.caff = c.new(function(event)
	if env.isAtOffice then return end
	local screensaverAtNight = event == c.screensaverDidStart
		and U.betweenTime(22, 6)
		and not env.hasProjector()
	local wokeWithProjector = event == c.screensDidWake and env.hasProjector()

	if wokeWithProjector or screensaverAtNight then
		local reason = wokeWithProjector and "woke with projector" or "screensaver at night"
		print(("🖥️ Darkened screen (%s)"):format(reason))
		U.defer(1, M.darkenImacDisplay) -- wait for macOS turning brightness up
		U.defer(4, M.darkenImacDisplay) -- redundancy to ensure BetterDisplay is active for full darkness
	elseif event == c.screensDidWake and not env.hasProjector() then
		print("🖥️ Brightened screen after waking up")
		U.defer(0.5, M.autoSwitch) -- wait for display turning on
		U.defer(1, M.autoSetBrightness) -- wait for auto-switch
	end
end):start()

--------------------------------------------------------------------------------
return M
