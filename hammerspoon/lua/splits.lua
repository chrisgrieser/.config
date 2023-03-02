require("lua.utils")
require("lua.window-management")
--------------------------------------------------------------------------------

-- HELPERS

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
local function pairedActivation()
	local app1 = SPLIT_LEFT:application():name()
	local app2 = SPLIT_RIGHT:application():name()

	Wf_pairedActivation = Wf.new({ app1, app2 })
		-- focus windows together
		:subscribe(Wf.windowFocused, function(focusedWin)
			-- not using :focus(), since that would cause infinite recursion
			-- raising needs small delay, so that focused window is already at front
			print("focusedWin:", focusedWin:id())
			print("SPLIT_RIGHT:", SPLIT_RIGHT:id())
			print("SPLIT_LEFT:", SPLIT_LEFT:id())

			if focusedWin:id() == SPLIT_RIGHT:id() then
				print("left raised")
				RunWithDelays(0.2, function()
					SPLIT_LEFT:raise()
				end)
			elseif focusedWin:id() == SPLIT_LEFT:id() then
				print("right raised")
				RunWithDelays(0.2, function()
					SPLIT_RIGHT:raise()
				end)
			end
		end)
		-- hide when neither is focused
		:subscribe(Wf.windowUnfocused, function()
			local curWin = hs.window.focusedWindow()
			if curWin:id() ~= SPLIT_LEFT:id() and curWin:id() ~= SPLIT_RIGHT:id() then
				SPLIT_RIGHT:application():hide()	
				SPLIT_LEFT:application():hide()	
			end
		end)
		-- stop vertical split when one of the windows is closed
		:subscribe(Wf.windowDestroyed, function(closedWin)
			if
				not SPLIT_LEFT
				or not SPLIT_RIGHT
				or (SPLIT_RIGHT:id() == closedWin:id())
				or (SPLIT_LEFT:id() == closedWin:id())
			then
				VsplitSetLayout("unsplit")
				print("2️⃣ Split stopped automatically due to one window closing.")
			end
		end)
end

---main split function
---@param mode string unsplit|split, split will use the secondWin and the current win
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
		print("2️⃣ Split started.")
		pairedActivation()
		f1 = LeftHalf
		f2 = RightHalf
	elseif mode == "unsplit" then
		Wf_pairedActivation:unsubscribeAll()
		f1 = PseudoMaximized
		f2 = PseudoMaximized
	end

	if SPLIT_RIGHT then
		MoveResize(SPLIT_RIGHT, f1) 
		SPLIT_RIGHT:raise()
	end
	if SPLIT_LEFT then
		MoveResize(SPLIT_LEFT, f2) 
		SPLIT_LEFT:raise()
	end

	if mode == "unsplit" then
		Wf_pairedActivation = nil ---@diagnostic disable-line: assign-type-mismatch
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
		:rows(#apps - 2) -- for whatever reason, the rows parameter is off by 3?
		:width(30)
		:placeholderText("Split " .. FrontAppName() .. " with…")
		:show()
end

--------------------------------------------------------------------------------
-- HOTKEYS

Hotkey(Hyper, "V", function()
	if splitActive() then
		print("2️⃣ Split stopped manually.")
		VsplitSetLayout("unsplit")
	else
		selectSecondWin()
	end
end)
