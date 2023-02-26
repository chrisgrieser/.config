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
		local isExcludedApp = { "Hammerspoon", "Twitter", "Notification Centre", FrontAppName() }
		if not TableContains(isExcludedApp, appName) then table.insert(appsArr, { text = appName }) end
	end
	return appsArr
end

--------------------------------------------------------------------------------

---if one of the two is activated, also activate the other
---unsplit if one of the two windows has been closed
---@param mode string start|stop of paired-activation
local function pairedActivation(mode)
	if mode == "stop" then
		if Wf_pairedActivation then Wf_pairedActivation:unsubscribeAll() end
		Wf_pairedActivation = nil
		return
	end

	local app1 = SPLIT_LEFT:application():name()
	local app2 = SPLIT_RIGHT:application():name()

	Wf_pairedActivation = Wf.new({ app1, app2 })
		:subscribe(Wf.windowFocused, function(focusedWin)
			-- not using :focus(), since that would cause infinite recursion
			-- raising needs small delay, so that focused window is already at front
			if focusedWin:id() == SPLIT_RIGHT:id() then
				RunWithDelays(0.02, function() SPLIT_LEFT:raise() end)
			elseif focusedWin:id() == SPLIT_LEFT:id() then
				RunWithDelays(0.02, function() SPLIT_RIGHT:raise() end)
			end
		end)
		:subscribe(Wf.windowDestroyed, function(closedWin)
			if
				not SPLIT_LEFT
				or not SPLIT_RIGHT
				or (SPLIT_RIGHT:id() == closedWin:id())
				or (SPLIT_LEFT:id() == closedWin:id())
			then
				VsplitSetLayout("unsplit")
			end
		end)
end

---main split function
---@param mode string swap|unsplit|split, split will use the secondWin and the current win
---@param secondWin? hs.window required when using mode "split"
function VsplitSetLayout(mode, secondWin)
	if not (splitActive()) and (mode == "swap" or mode == "unsplit") then
		Notify("no split active")
		return
	end

	-- define split windows
	if mode == "split" then
		SPLIT_LEFT = hs.window.focusedWindow()
		SPLIT_RIGHT = secondWin
	end

	local f1
	local f2
	if mode == "split" then
		pairedActivation("start")
		f1 = LeftHalf
		f2 = RightHalf
	elseif mode == "swap" then
		f1 = RightHalf
		f2 = LeftHalf
	elseif mode == "unsplit" then
		pairedActivation("stop")
		f1 = PseudoMaximized
		f2 = PseudoMaximized
	end

	MoveResize(SPLIT_RIGHT, f1) ---@diagnostic disable-line: param-type-mismatch
	MoveResize(SPLIT_LEFT, f2) ---@diagnostic disable-line: param-type-mismatch
	SPLIT_RIGHT:raise()
	SPLIT_LEFT:raise()
	RunWithDelays(0.3, function()
		ToggleWinSidebar(SPLIT_RIGHT) ---@diagnostic disable-line: param-type-mismatch
		ToggleWinSidebar(SPLIT_LEFT) ---@diagnostic disable-line: param-type-mismatch
	end)

	if mode == "unsplit" then
		SPLIT_RIGHT = nil
		SPLIT_LEFT = nil ---@diagnostic disable-line: assign-type-mismatch
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
			VsplitSetLayout("split", secondWin)
		end)
		:choices(apps)
		:rows(#apps - 2) -- for whatever reason, the rows parameter is off by 3?!
		:width(30)
		:placeholderText("Split " .. FrontAppName() .. " with...")
		:show()
end

--------------------------------------------------------------------------------
-- HOTKEYS

Hotkey(Hyper, "X", function() VsplitSetLayout("swap") end)
Hotkey(Hyper, "V", function()
	if splitActive() then
		VsplitSetLayout("unsplit")
	else
		selectSecondWin()
	end
end)
