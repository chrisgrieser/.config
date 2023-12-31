local M = {} -- persist from garbage collector

local env = require("lua.environment-vars")
local u = require("lua.utils")
local wu = require("lua.window-utils")
local aw = hs.application.watcher
local wf = hs.window.filter

--------------------------------------------------------------------------------

M.wf_browser = wf.new(env.browserApp)
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
			wu.autoTile(M.wf_browser)
		end
	end)
	:subscribe(wf.windowDestroyed, function() wu.autoTile(M.wf_browser) end)
	:subscribe(wf.windowFocused, wu.bringAllWinsToFront)

-- Automatically hide Browser has when no window
-- requires wider window-filter to not hide PiP windows etc
M.wf_browserAll = wf.new(env.browserApp)
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
	M.hotkey_jHidesCursor:disable()
	M.hotkey_kHidesCursor:disable()

	-- hide the cursor
	local screen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
	local bottomLeftPos = { x = 0, y = screen:frame().h * 0.9 }
	hs.mouse.setRelativePosition(bottomLeftPos, screen)

	-- pass through the key pressed
	u.keystroke({}, key, 1)
end

M.hotkey_jHidesCursor = u.hotkey({}, "j", function() hideCurAndPassThrough("j") end):disable()
M.hotkey_kHidesCursor = u.hotkey({}, "k", function() hideCurAndPassThrough("k") end):disable()

-- watches browser, enables when hotkeys when browser is activated
M.aw_jkHotkeys = aw.new(function(appName, eventType)
	if eventType ~= aw.activated then return end

	if appName == env.browserApp then
		M.hotkey_jHidesCursor:enable()
		M.hotkey_kHidesCursor:enable()
	else
		M.hotkey_jHidesCursor:disable()
		M.hotkey_kHidesCursor:disable()
	end
end):start()

--------------------------------------------------------------------------------
-- BOOKMARKS SYNCED TO CHROME BOOKMARKS
-- (so Alfred can pick up the Bookmarks without extra keyword)

local appSupport = os.getenv("HOME") .. "/Library/Application Support/"
local config = {
	sourceProfile = appSupport .. env.browserDefaultsPath,
	sourceBookmarks = appSupport .. env.browserDefaultsPath .. "/Default/Bookmarks",
	chromeProfile = appSupport .. "Google/Chrome/",
}
M.pathw_bookmarks = hs.pathwatcher.new(config.sourceBookmarks, function()
	-- Bookmarks
	local bookmarks = hs.json.read(config.sourceBookmarks)
	if not bookmarks then return end
	hs.execute(("mkdir -p '%s'"):format(config.chromeProfile))
	local success = hs.json.write(bookmarks, config.chromeProfile .. "/Default/Bookmarks", false, true)
	if not success then
		u.notify("🔖⚠️ Bookmarks not correctly synced.")
		return
	end

	-- Local State (also required for Alfred to pick up the Bookmarks)
	local content = u.readFile(config.sourceProfile .. "/Local State")
	if not content then return end
	u.writeToFile(config.chromeProfile .. "/Local State", content, false)

	print("🔖 Bookmarks synced to Chrome Bookmarks")
end):start()
--------------------------------------------------------------------------------
return M
