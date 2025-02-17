-- INFO
-- * overwrite pagedown & pageup to scroll a certain amount instead. This ensures
--   that they do not move a full viewport, effectively creating a scroll offset.
-- * Not implemented via Karabiner, since Karabiner does not allow for scrolling
-- * This file is somewhat equivalent to https://github.com/dexterleng/KeyboardScroller.docs
--------------------------------------------------------------------------------

-- CONFIG
-- * distance to scroll per app. Needed since scrolling translates into
--   different distances in different apps
-- * false to ignore app
local perAppSettings = {
	defaultScrollDistance = 30,
	Highlights = 50,

	-- uses pageup/pagedown for mappings
	Neovide = false,
	neovide = false,
	WezTerm = false,
	Alfred = false,
}

--------------------------------------------------------------------------------

---@param direction "up" | "down
local function scroll(direction)
	local frontApp = hs.application.frontmostApplication()
	if not frontApp:mainWindow() then return end
	local ignoreApp = perAppSettings[frontApp:name()] == false
	if ignoreApp then
		-- simply pass through the key
		hs.eventtap.keyStroke({}, "page" .. direction, 0, frontApp)
		return
	end

	-- cursor needs to be inside main window to scroll the right frame, since on
	-- macOS the frame below the cursor is scrolled not the focused one
	local frame = frontApp:mainWindow():frame()
	local centerPos = { x = frame.x + frame.w * 0.5, y = frame.y + frame.h * 0.5 }
	hs.mouse.setRelativePosition(centerPos)

	-- determine distance and scroll
	local distance = perAppSettings[frontApp:name()] or perAppSettings.defaultScrollDistance
	if direction == "down" then distance = distance * -1 end
	hs.eventtap.scrollWheel({ 0, distance }, {})

	-- moving cursor away so it is not in the way
	local screen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
	local bottomLeftPos = { x = 0, y = screen:frame().h * 0.9 }
	hs.mouse.setRelativePosition(bottomLeftPos, screen)
end

local function scrollDown() scroll("down") end
local function scrollUp() scroll("up") end

--------------------------------------------------------------------------------
-- HOTKEYS
hs.hotkey.bind({ "alt" }, "J", scrollDown, nil, scrollDown)
hs.hotkey.bind({}, "pagedown", scrollDown, nil, scrollDown)

hs.hotkey.bind({ "alt" }, "K", scrollUp, nil, scrollUp)
hs.hotkey.bind({}, "pageup", scrollUp, nil, scrollUp)
