local M = {} -- persist from garbage collector

local env = require("modules.environment-vars")
local u = require("modules.utils")
local wu = require("modules.window-utils")

local aw = hs.application.watcher
local wf = hs.window.filter
--------------------------------------------------------------------------------

-- AUTO-TILING
M.wf_browser = wf.new("Brave Browser")
	:setOverrideFilter({
		rejectTitles = {
			"^Picture in Picture$",
			"^Task Manager$",
			"^Developer Tools", -- when inspecting websites
			"^DevTools",
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

-- AUTOMATICALLY HIDE WHEN NO WINDOW
-- requires wider window-filter to not hide PiP windows etc
M.wf_browserAll = wf.new("Brave Browser")
	:setOverrideFilter({ allowRoles = "AXStandardWindow" })
	:subscribe(wf.windowDestroyed, function()
		local app = u.app("Brave Browser")
		if app and #(app:allWindows()) == 0 then app:hide() end
	end)

--------------------------------------------------------------------------------
-- AUTO-COPY on focus loss
aw.new(function(appName, eventType, browserApp)
	if eventType == aw.deactivated and appName == "Brave Browser" then
		print("🖨️ beep 🔵")
		hs.eventtap.keyStroke({ "cmd" }, "x", 0, hs.application("TextEdit"))
	end
end):start()

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
	hs.eventtap.keyStroke({}, key, 1)
end

M.hotkey_jHidesCursor = hs.hotkey.bind({}, "j", function() hideCurAndPassThrough("j") end):disable()
M.hotkey_kHidesCursor = hs.hotkey.bind({}, "k", function() hideCurAndPassThrough("k") end):disable()

-- watches browser, enables when hotkeys when browser is activated
M.aw_jkHotkeys = aw.new(function(appName, eventType)
	if eventType ~= aw.activated then return end

	if appName == "Brave Browser" then
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

local chromeBookmarks = os.getenv("HOME")
	.. "/Library/Application Support/Google/Chrome/Default/Bookmarks"

local function touchSymlink()
	-- `-h` touches the symlink itself instead of its target.
	-- The pathwatcher *trigger* is triggered by changes of the target, while
	-- this function touches the symlink itself.
	hs.execute(("touch -h %q"):format(chromeBookmarks))
end

-- sync on system start & when bookmarks are changed
if u.isSystemStart() then touchSymlink() end
M.pathw_bookmarks = hs.pathwatcher.new(chromeBookmarks, touchSymlink):start()

--------------------------------------------------------------------------------

-- HACK URI for triggering from surfingkeys itself
hs.urlevent.bind(
	"open-surfingkeys-config",
	function() hs.open("../+ browser-extension-configs/surfing-keys.js") end
)

--------------------------------------------------------------------------------
return M
