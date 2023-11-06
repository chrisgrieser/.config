local M = {}
M.splitActive = false -- initialize
--------------------------------------------------------------------------------

local function endSplit()
	-- un-fullscreening the split windows effectively stops the split
	for _, win in pairs(hs.window.allWindows()) do
		if win:isFullScreen() then win:setFullScreen(false) end
	end
	M.wf_vsplit:unsubscribeAll()
	M.wf_vsplit = nil
	M.splitActive = false
end

local function verticalSplit()
	-- END SPLIT
	if M.splitActive then
		endSplit()
		return
	end

	-- GUARD
	local frontApp = hs.application.frontmostApplication()
	if not frontApp:findMenuItem { "Window", "Tile Window to Right of Screen" } then
		local msg = frontApp:name()
			.. " does not support window options. \n\nStart the split from the other app."
		hs.alert.show(msg, nil, nil, 4)
		return
	end

	-- START SPLIT
	-- unhide all windows, so they are displayed as selection for the second window
	for _, win in pairs(hs.window.allWindows()) do
		local app = win:application()
		if app and app:isHidden() then app:unhide() end
	end

	M.delay_timer = hs.timer
		.doAfter(0.1, function() -- wait for unhiding
			frontApp:selectMenuItem { "Window", "Tile Window to Right of Screen" }
		end)
		:start()

	M.splitActive = true

	-- end split when one of the two windows is destroyed
	M.wf_vsplit = hs.window.filter
		.new(true)
		:setOverrideFilter({ currentSpace = true, fullscreen = true })
		:subscribe(hs.window.filter.windowDestroyed, endSplit)
end

--------------------------------------------------------------------------------
hs.hotkey.bind({ "cmd", "alt", "ctrl", "shift" }, "V", verticalSplit)

return M -- catch this after requiring to persist from garbage collector
