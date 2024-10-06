-- CONFIG
local mastodonUsername = "pseudometa"
--------------------------------------------------------------------------------

local M = {} -- persist from garbage collector

local u = require("modules.utils")
local wu = require("modules.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter
--------------------------------------------------------------------------------

-- SHOW if referenceWin is pseudo-maximized or centered
-- HIDE referenceWin is maximized
---@param refWin hs.window
local function showHideTickerApp(refWin)
	-- GUARD
	local masto = u.app("Mona")
	if not masto or not refWin then return end
	local loginWin = refWin:title() == "Login"
	local screenshotOverlay = refWin:title() == "" or u.isFront("CleanShot X")
	if loginWin or screenshotOverlay then return end

	if wu.winHasSize(refWin, wu.pseudoMax) or wu.winHasSize(refWin, wu.middleHalf) then
		local mastoWin = masto:findWindow("Mona") or masto:findWindow(mastodonUsername)
		if not mastoWin then return end

		masto:unhide()
		mastoWin:setFrame(wu.toTheSide)
		mastoWin:raise()
	elseif wu.winHasSize(refWin, hs.layout.maximized) then
		masto:hide()
	end
end

-- show/hide app when any other wins move
M.aw_forOtherApps = aw.new(function(appName, event, _)
	if appName == "Mona" and (event == aw.activated or event == aw.launched) then
		showHideTickerApp(hs.window.focusedWindow())
	end
end):start()

M.wf_someWindowActivity = wf.new(true)
	:setOverrideFilter({ allowRoles = "AXStandardWindow", hasTitlebar = true })
	:subscribe(wf.windowMoved, showHideTickerApp)
	:subscribe(wf.windowCreated, showHideTickerApp)

--------------------------------------------------------------------------------

-- SPECIAL WINS
-- - auto-focus when composeWin when activating
-- - auto-close when deactivating
M.aw_forSpecialMastoWins = aw.new(function(appName, event, masto)
	if appName ~= "Mona" then return end

	if event == aw.activated then
		masto:selectMenuItem { "Window", "Bring All to Front" }
		local composeWin = masto:findWindow("Compose")
		if composeWin then composeWin:focus() end
	elseif event == aw.deactivated then
		local mediaWin = masto:findWindow("Media") or masto:findWindow("Image")
		if mediaWin then
			mediaWin:close()
			hs.eventtap.keyStroke({ "cmd" }, "w", 1, masto) -- redundancy as closing not reliable
		end
	end
end):start()

--------------------------------------------------------------------------------
return M
