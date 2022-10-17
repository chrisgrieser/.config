require("lua.utils")
require("lua.window-management")
--------------------------------------------------------------------------------

local function runningApps()
	local wins = hs.window:allWindows()
	local appsArr = {}
	for i = 1, #wins do
		local appName = wins[i]:application():name()
		local isExcludedApp = appName == frontapp() or appName == "Hammerspoon" or appName == "Twitterrific" or appName == "Notification Centre"
		if not(isExcludedApp) then
			table.insert(appsArr, {text = appName})
		end
	end
	return appsArr
end

local function startSplit()
	local function splitWithSecondWin(selection)
		if not(selection) then return end
		local appName = selection.text
		local secondWin = hs.application(appName):allWindows()[1]
		vsplit ("split", secondWin)
	end
	local apps = runningApps()
	hs.chooser.new(splitWithSecondWin)
		:choices(apps)
		:rows(#apps - 2) -- for whatever reason, the rows parameter is off by 3?!
		:width(30)
		:placeholderText("Split "..frontapp().." with...")
		:show()
end

-- if one of the two is activated, also activate the other
-- unsplit if one of the two windows has been closed
function pairedActivation(mode)
	if mode == "start" then
		local app1 = SPLIT_LEFT:application():name()
		local app2 = SPLIT_RIGHT:application():name()
		wf_pairedActivation = wf.new{app1, app2}
		wf_pairedActivation:subscribe(wf.windowFocused, function(focusedWin)
			-- not using :focus(), since that would cause infinite recursion
			-- raising needs small delay, so that focused window is already at front
			if focusedWin:id() == SPLIT_RIGHT:id() then
				runDelayed (0.02, function ()	SPLIT_LEFT:raise() end)
			elseif focusedWin:id() == SPLIT_LEFT:id() then
				runDelayed (0.02, function ()	SPLIT_RIGHT:raise() end)
			end
		end)
		wf_pairedActivation:subscribe(wf.windowDestroyed, function(closedWin)
			if not(SPLIT_LEFT) or not(SPLIT_RIGHT) or (SPLIT_RIGHT:id() == closedWin:id()) or (SPLIT_LEFT:id() == closedWin:id()) then
				vsplit("unsplit")
			end
		end)
	elseif mode == "stop" then
		if wf_pairedActivation then wf_pairedActivation:unsubscribeAll() end
		wf_pairedActivation = nil
	end
end

function vsplit (mode, secondWin)
	-- various guard clauses
	local splitActive
	if SPLIT_RIGHT and SPLIT_LEFT then
		splitActive = true
	else
		splitActive = false
	end
	if not(splitActive) and (mode == "swap" or mode == "unsplit") then
		notify("no split active")
		return
	end
	if splitActive and mode == "split" then
		notify("split still active")
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
		f1 = hs.layout.left50
		f2 = hs.layout.right50
	elseif mode == "unsplit" then
		f1 = baseLayout
		f2 = baseLayout
		pairedActivation("stop")
	elseif mode == "swap" then
		f1 = hs.layout.right50
		f2 = hs.layout.left50
	end

	moveResize(SPLIT_RIGHT, f1)
	moveResize(SPLIT_LEFT, f2)
	SPLIT_RIGHT:raise()
	SPLIT_LEFT:raise()
	runDelayed(0.2, function ()
		if SPLIT_RIGHT:application() then
			if SPLIT_RIGHT:application():name() == "Drafts" then toggleDraftsSidebar(SPLIT_RIGHT)
			elseif SPLIT_RIGHT:application():name() == "Obsidian" then toggleObsidianSidebar(SPLIT_RIGHT)
			elseif SPLIT_RIGHT:application():name() == "Highlights" then toggleHighlightsSidebar(SPLIT_RIGHT)
			end
		end
		if SPLIT_LEFT:application() then
			if SPLIT_LEFT:application():name() == "Drafts" then toggleDraftsSidebar(SPLIT_LEFT)
			elseif SPLIT_LEFT:application():name() == "Obsidian" then toggleObsidianSidebar(SPLIT_LEFT)
			elseif SPLIT_LEFT:application():name() == "Highlights" then toggleHighlightsSidebar(SPLIT_LEFT)
			end
		end
	end)

	if mode == "unsplit" then
		SPLIT_RIGHT = nil
		SPLIT_LEFT = nil
	end
end

--------------------------------------------------------------------------------
-- HOTKEYS

hotkey(hyper, "X", function() vsplit("swap") end)
hotkey(hyper, "C", function() vsplit("unsplit") end)
hotkey(hyper, "V", startSplit)


