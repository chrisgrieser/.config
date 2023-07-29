local u = require("lua.utils")
--------------------------------------------------------------------------------

-- INFO
-- - overwrite pagedown & pageup to scroll a certain amount instead. This ensures
--   that they do not move a full viewport, effectively creating a scroll offset
-- - not implemented via Karabiner, since Karabiner does not allow for scrolling
-- - This spoon is somewhat equivalent to https://github.com/dexterleng/KeyboardScroller.docs

-- CONFIG
-- distance or false to ignore app
local perAppSettings = {
	defaultScrollDistance = 40,
	Discord = 20,
	Highlights = 50,
	Neovide = false,
	neovide = false,
	["wezterm-gui"] = false,
	WezTerm = false,
}

--------------------------------------------------------------------------------

---@param direction "up" | "down
local function scroll(direction)
	local frontApp = hs.application.frontmostApplication()

	-- cursor needs to be inside main window to scroll the right frame, since on
	-- macOS the frame below the cursor is scrolled not the focussed one
	local frame = frontApp:mainWindow():frame()
	local centerPos = { x = frame.x + frame.w * 0.5, y = frame.y + frame.h * 0.5 }
	hs.mouse.setRelativePosition(centerPos)

	-- ignore app
	local ignoreApp = perAppSettings[frontApp:name()] == false
	if ignoreApp then
		hs.eventtap.keyStroke({}, "page" .. direction, 0, frontApp)
		return
	end

	-- determine distance and scroll
	local distance = perAppSettings[frontApp:name()] or perAppSettings.defaultScrollDistance
	if direction == "down" then distance = distance * -1 end
	hs.eventtap.scrollWheel({ 0, distance }, {})

	-- now moving cursor away so it is not in the way
	local screen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
	local bottomLeftPos = { x = 0, y = screen:frame().h * 0.9 }
	hs.mouse.setRelativePosition(bottomLeftPos, screen)
end

local function scrollDown() scroll("down") end
local function scrollUp() scroll("up") end

--------------------------------------------------------------------------------
-- HOTKEYS

u.hotkey({ "alt" }, "J", scrollDown, nil, scrollDown)
u.hotkey({}, "pagedown", scrollDown, nil, scrollDown)

u.hotkey({ "alt" }, "K", scrollUp, nil, scrollUp)
u.hotkey({}, "pageup", scrollUp, nil, scrollUp)
