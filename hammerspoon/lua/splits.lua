require("lua.utils")
require("lua.window-management")
--------------------------------------------------------------------------------

-- helpers
---@return boolean whether a split is currently active
local function splitActive()
	if SPLIT_RIGHT and SPLIT_LEFT then return true end
	return false
end

---@return table list of apps that are running, formatted for hs.chooser
local function runningApps()
	local appsArr = {}
	for _, win in pairs(hs.window:allWindows()) do
		local appName = win:application():name()
		local isExcludedApp = { "Hammerspoon", "Gifox", "Twitterrific", "Notification Centre", frontAppName() }
		if not tableContains(isExcludedApp, appName) then table.insert(appsArr, { text = appName }) end
	end
	return appsArr
end

--------------------------------------------------------------------------------

---if one of the two is activated, also activate the other
---unsplit if one of the two windows has been closed
---@param mode string start|end of paired-activation
local function pairedActivation(mode)
	if mode == "stop" then
		if wf_pairedActivation then wf_pairedActivation:unsubscribeAll() end
		wf_pairedActivation = nil
		return
	end

	local app1 = SPLIT_LEFT:application():name()
	local app2 = SPLIT_RIGHT:application():name()

	wf_pairedActivation = wf.new({ app1, app2 })
		:subscribe(wf.windowFocused, function(focusedWin)
			-- not using :focus(), since that would cause infinite recursion
			-- raising needs small delay, so that focused window is already at front
			if focusedWin:id() == SPLIT_RIGHT:id() then
				runWithDelays(0.02, function() SPLIT_LEFT:raise() end)
			elseif focusedWin:id() == SPLIT_LEFT:id() then
				runWithDelays(0.02, function() SPLIT_RIGHT:raise() end)
			end
		end)
		:subscribe(wf.windowDestroyed, function(closedWin)
			if
				not SPLIT_LEFT
				or not SPLIT_RIGHT
				or (SPLIT_RIGHT:id() == closedWin:id())
				or (SPLIT_LEFT:id() == closedWin:id())
			then
				vsplitSetLayout("unsplit")
			end
		end)
end

---main split function
---@param mode string swap|unsplit|split, split will use the secondWin and the current win
---@param secondWin? hs.window required when using mode "split"
function vsplitSetLayout(mode, secondWin)
	if not (splitActive()) and (mode == "swap" or mode == "unsplit") then
		notify("no split active")
		return
	end

	-- define split windows
	if mode == "split" then
		SPLIT_LEFT = hs.window.focusedWindow()
		SPLIT_RIGHT = secondWin
	end

	-- ensure that SPLIT_RIGHT is really the right window
	if mode == "swap" and (SPLIT_RIGHT:frame().x > SPLIT_LEFT:frame().x) then
		local temp = SPLIT_RIGHT
		SPLIT_RIGHT = SPLIT_LEFT
		SPLIT_LEFT = temp
	end
	local f1 = SPLIT_RIGHT:frame()
	local f2 = SPLIT_LEFT:frame()

	if mode == "split" then
		pairedActivation("start")
		f1 = leftHalf
		f2 = rightHalf
	elseif mode == "unsplit" then
		f1 = baseLayout
		f2 = baseLayout
		pairedActivation("stop")
	elseif mode == "swap" then
		f1 = rightHalf
		f2 = leftHalf
	end

	moveResize(SPLIT_RIGHT, f1)
	moveResize(SPLIT_LEFT, f2)
	SPLIT_RIGHT:raise()
	SPLIT_LEFT:raise()
	runWithDelays(0.3, function()
		toggleWinSidebar(SPLIT_RIGHT)
		toggleWinSidebar(SPLIT_LEFT)
	end)

	if mode == "unsplit" then
		SPLIT_RIGHT = nil
		SPLIT_LEFT = nil
	end
end

---select a second window to pass to vsplitSetLayout()
local function selectSecondWin()
	local apps = runningApps()
	hs
		.chooser
		.new(function(selection)
			if not selection then return end
			local appName = selection.text
			local secondWin = hs.application(appName):allWindows()[1]
			vsplitSetLayout("split", secondWin)
		end)
		:choices(apps)
		:rows(#apps - 2) -- for whatever reason, the rows parameter is off by 3?!
		:width(30)
		:placeholderText("Split " .. frontAppName() .. " with...")
		:show()
end

--------------------------------------------------------------------------------
-- HOTKEYS

hotkey(hyper, "X", function() vsplitSetLayout("swap") end)
hotkey(hyper, "V", function()
	if splitActive() then
		vsplitSetLayout("unsplit")
	else
		selectSecondWin()
	end
end)
