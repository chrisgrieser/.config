local M = {}
--------------------------------------------------------------------------------

local function endSplit()
	-- un-fullscreening the split windows effectively stops the split
	local splitWins = M.wf_vsplit:getWindows()
	for _, win in pairs(splitWins) do
		win:setFullScreen(false)
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
		local msg
		if frontApp:findMenuItem { "Window", "Move Window to Right Side of Screen" } then
			msg = {
				"Tiling not available with the current settings.",
				"Enable them via:",
				"",
				"1. System Settings → Desktop & Dock → Mission Control",
				'2. Enable "Displays have separate Spaces"',
				"3. Log out and log in again",
			}
		else
			msg = {
				frontApp:name() .. "does not support window options.",
				"",
				"Start the split from the other app.",
			}
		end
		hs.alert(table.concat(msg, "\n"), 3)
		return
	end

	-- START SPLIT
	-- unhide all windows, so they are displayed as selection for the second window
	for _, win in pairs(hs.window.allWindows()) do
		local app = win:application()
		if app and app:isHidden() then app:unhide() end
	end

	M.delay_timer = hs.timer
		.doAfter(0.2, function() -- wait for unhiding
			frontApp:selectMenuItem { "Window", "Tile Window to Right of Screen" }
		end)
		:start()

	M.splitActive = true

	-- end split when one of the two windows is destroyed/unfullscreened
	M.wf_vsplit = hs.window.filter
		.new(true)
		:setOverrideFilter({ currentSpace = true, fullscreen = true })
		:subscribe(hs.window.filter.windowDestroyed, endSplit)
		:subscribe(hs.window.filter.windowUnfullscreened, endSplit)
end

--------------------------------------------------------------------------------

hs.hotkey.bind(require("lua.utils").hyper, "V", verticalSplit)

return M -- save this after requiring to persist from garbage collector
