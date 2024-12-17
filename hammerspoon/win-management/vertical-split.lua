-- INFO
-- This module uses macOS' builtin full-screen tiling functionality and its
-- spacing functionality to quickly create a vertical split of two paired apps
-- apps via one hotkey.

--------------------------------------------------------------------------------

local M = {}
--------------------------------------------------------------------------------

---@return integer
local function fullScreenWinCount()
	local fullScreenWins = hs.fnutils.filter(
		hs.window.allWindows(),
		function(win) return win:isFullScreen() end
	)
	return #fullScreenWins
end

local function endSplit()
	-- un-fullscreening the split windows effectively stops the split
	local splitWins = M.vsplitWins:getWindows()
	for _, win in pairs(splitWins) do
		if win:isFullScreen() then win:setFullScreen(false) end
	end
	M.vsplitWins:unsubscribeAll()
	M.vsplitWins = nil
end

local function startSplit()
	-- 1. GUARD Tiling disabled or not available for the app
	local frontApp = hs.application.frontmostApplication()
	if not frontApp:findMenuItem { "Window", "Full Screen Tile", "Right of Screen" } then
		local msg = frontApp:name()
			.. " does not support window options.\n"
			.. "Ensure 'Displays have separate Spaces' in Docks settings is enabled.\n"
			.. "If so, you need to start the split from the other app."
		hs.alert(msg, 4)
		return
	end

	-- 2. unhide & unfullscreen all wins, so they are available as selection for the 2nd win
	for _, win in pairs(hs.window.allWindows()) do
		local app = win:application()
		if app and app:isHidden() then app:unhide() end
		if win:isFullScreen() then win:setFullScreen(false) end
	end

	-- 3. start mission control selection
	M.delay_timer = hs.timer
		.doAfter(0.2, function() -- wait for unhiding/unfullscreen
			frontApp:selectMenuItem { "Window", "Full Screen Tile", "Right of Screen" }
		end)
		:start()

	-- 4. wait until user made decision on 2nd window, then setup SplitWinFilter
	local function userDecision()
		-- during the Mission-control-like selection, only 1 win is fullscreen
		local fullScreenWins = fullScreenWinCount()
		local aborted = fullScreenWins == 0
		local secondWinSelected = fullScreenWins == 2
		return aborted or secondWinSelected
	end
	local function setupSplitWinFilter()
		if fullScreenWinCount() ~= 2 then return end -- aborted by user
		-- end split when one of the two windows is destroyed/unfullscreened
		M.vsplitWins = hs.window.filter
			.new(true)
			:setOverrideFilter({ currentSpace = true, fullscreen = true })
			:subscribe(hs.window.filter.windowDestroyed, endSplit)
			:subscribe(hs.window.filter.windowUnfullscreened, endSplit)
	end
	M.waitForDecision = hs.timer.waitUntil(userDecision, setupSplitWinFilter):start()
end

--------------------------------------------------------------------------------

hs.hotkey.bind(require("meta.utils").hyper, "V", function()
	if M.vsplitWins then
		endSplit()
	else
		startSplit()
	end
end)

return M -- save this after requiring to persist from garbage collector
