local M = {}

local wf = hs.window.filter
local aw = hs.application.watcher
--------------------------------------------------------------------------------

-- prevent keeping focus when closing a window
local fallthroughApps = { "Finder", "Brave Browser", "Obsidian" }

local function fallthrough()
	local frontApp = hs.application.frontmostApplication()
	local isFront = hs.fnutils.contains(fallthroughApps, frontApp:name())
	local noWins = #(frontApp:allWindows()) == 0
	if isFront and noWins then
		local allWins = hs.window.orderedWindows() -- all visible windows in order
		for _, win in ipairs(allWins) do
			local winFromFallThroughApp =
				hs.fnutils.contains(fallthroughApps, win:application():name()) ---@diagnostic disable-line: undefined-field
			if win:isStandard() and not winFromFallThroughApp then
				win:focus() -- hiding fallthrough-app does not work, must focus next win
				return
			end
		end
	end
end

M.wf_fallthrough = wf
	.new(true) -- `true` = any app
	:setOverrideFilter({ fullscreen = false, rejectTitles = { "^Login$" } })
	:subscribe(wf.windowDestroyed, fallthrough)

M.aw_fallthrough = aw.new(function(name, event, _app)
	-- deactivation of an app
	if event == aw.deactivated or event == aw.terminated then fallthrough() end

	-- activation of an fallthrough app
	if event == aw.activated and hs.fnutils.contains(fallthroughApps, name) then fallthrough() end
end):start()

--------------------------------------------------------------------------------
return M
