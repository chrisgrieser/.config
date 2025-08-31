local M = {}

local u = require("meta.utils")
local wf = hs.window.filter
local aw = hs.application.watcher
--------------------------------------------------------------------------------

local config = {
	fallthrough = {
		whenNoWin = { "Finder", "Brave Browser", "Obsidian" },
		always = { "Ivory", "Transmission" },
	},
}

--------------------------------------------------------------------------------

local function fallthrough()
	u.defer(0.2, function() -- deferring to ensure windows are already switched/created
		local frontApp = hs.application.frontmostApplication()
		local name = frontApp:name()
		local noWin = #(frontApp:allWindows()) == 0
		local fallthroughWhenNoWin = noWin and hs.fnutils.contains(config.fallthrough.whenNoWin, name)
		local fallThroughAlways = hs.fnutils.contains(config.fallthrough.always, name)
		if not fallthroughWhenNoWin and not fallThroughAlways then return end

		local nextWin = hs.fnutils.find(
			hs.window:orderedWindows(), -- all visible windows in order
			function(win)
				if not win:application() or not win:isStandard() then return false end
				local appName = win:application():name()
				local fromFallThroughApp = hs.fnutils.contains(config.fallthrough.always, appName)
				return not fromFallThroughApp
			end
		)
		if not nextWin then return end

		print("⤵️ fallthrough to " .. nextWin:application():name())
		nextWin:focus()
	end)
end

--------------------------------------------------------------------------------
-- TRIGGERS
M.wf_windowDestroyed = wf
	.new(true) -- `true` = any app
	:setOverrideFilter({ allowRoles = "AXStandardWindow", rejectTitles = { "^Login$", "^$" } })
	:subscribe(wf.windowDestroyed, fallthrough)

-- HACK since `windowDestroyed` often does not fire, we also watch for manual
-- window closing
hs.hotkey.bind({ "cmd" }, "w", function()
	local frontApp = hs.application.frontmostApplication()
	hs.eventtap.keyStroke({ "cmd" }, "w", 1, frontApp) -- passthrough
	local fallthroughWhenNoWinApp = hs.fnutils.contains(config.fallthrough.whenNoWin, frontApp:name())
	print("🪚 frontApp: " .. hs.inspect(frontApp:name()))
	if fallthroughWhenNoWinApp then fallthrough() end
end)

M.aw_noWinActivated = aw.new(function(name, event, _app)
	if event == aw.activated and hs.fnutils.contains(config.fallthrough.whenNoWin, name) then
		fallthrough()
	end
end):start()

--------------------------------------------------------------------------------
return M
