local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")
local aw = hs.application.watcher
local wf = hs.window.filter

--------------------------------------------------------------------------------

Wf_browser = wf.new(env.browserApp)
	:setOverrideFilter({
		rejectTitles = {
			"^Picture in Picture$",
			"^Task Manager$",
			"^Developer Tools", -- when inspecting websites
			"^DevTools",
			"^$", -- when inspecting Vivaldi UI, devtools are titled "^$" on creation
		},
		allowRoles = "AXStandardWindow",
		hasTitlebar = true,
	})
	:subscribe(wf.windowCreated, function(win)
		local winOnMainScreen = win:screen():id() == hs.screen.mainScreen():id()
		if env.isProjector() and winOnMainScreen then
			wu.moveResize(win, wu.maximized)
		else
			wu.autoTile(Wf_browser)
		end
	end)
	:subscribe(wf.windowDestroyed, function() wu.autoTile(Wf_browser) end)
	:subscribe(wf.windowFocused, wu.bringAllWinsToFront)

-- Automatically hide Browser has when no window
-- requires wider window-filter to not hide PiP windows etc
Wf_browser_all = wf.new(env.browserApp)
	:setOverrideFilter({ allowRoles = "AXStandardWindow" })
	:subscribe(wf.windowDestroyed, function()
		local app = u.app(env.browserApp)
		if app and #(app:allWindows()) == 0 then app:hide() end
	end)

--------------------------------------------------------------------------------

-- VIMIUM CURSOR HIDER
-- Companion for Vimium-like browser extensions which are not able to hide the
-- cursor properly

---when Browser activates and j or k is pressed for the first time, hide cursor
---@param key string character that triggers cursor hiding
local function hideCurAndPassThrough(key)
	-- disable to it works only once
	JHidesCursor:disable()
	KHidesCursor:disable()

	-- hide the cursor
	local screen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
	local bottomLeftPos = { x = 0, y = screen:frame().h * 0.9 }
	hs.mouse.setRelativePosition(bottomLeftPos, screen)

	-- pass through the key pressed
	u.keystroke({}, key, 1)
end

JHidesCursor = u.hotkey({}, "j", function() hideCurAndPassThrough("j") end):disable()
KHidesCursor = u.hotkey({}, "k", function() hideCurAndPassThrough("k") end):disable()

-- watches browser, enables when hotkeys when browser is activated

Jk_watcher = aw.new(function(appName, eventType)
	if eventType ~= aw.activated then return end

	if appName == env.browserApp then
		JHidesCursor:enable()
		KHidesCursor:enable()
	else
		JHidesCursor:disable()
		KHidesCursor:disable()
	end
end):start()
