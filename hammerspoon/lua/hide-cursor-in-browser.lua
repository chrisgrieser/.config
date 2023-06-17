local env = require("lua.environment-vars")
local u = require("lua.utils")
-- Companion for Vimium-like browser extensions which are not able to hide the
-- cursor properly
--------------------------------------------------------------------------------

---when Browser activates and j or k is pressed for the first time, hide cursor
---@param key string character that triggers cursor hiding
local function hideCurAndPassThrough(key)
	-- disable to it works only once
	JHidesCursor:disable()
	KHidesCursor:disable()

	-- hide the cursor
	local screen = hs.mouse.getCurrentScreen() 
	if not screen then return end

	local bottomLeftPos = { x = 0, y = screen:frame().h * 0.9 }
	hs.mouse.setRelativePosition(bottomLeftPos, screen)

	-- pass through the key pressed
	u.keystroke({}, key, 1)
end

JHidesCursor = u.hotkey({}, "j", function() hideCurAndPassThrough("j") end):disable()
KHidesCursor = u.hotkey({}, "k", function() hideCurAndPassThrough("k") end):disable()

-- watches browser, enables when hotkeys when browser is activated
Jk_watcher = u.aw
	.new(function(appName, eventType)
		if eventType ~= u.aw.activated then return end

		if appName == env.browserApp then
			JHidesCursor:enable()
			KHidesCursor:enable()
		else
			JHidesCursor:disable()
			KHidesCursor:disable()
		end
	end)
	:start()
