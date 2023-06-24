local u = require("lua.utils")
--------------------------------------------------------------------------------

-- INFO
-- - overwrite pagedown & pageup to scroll a certain amount instead. This ensures
--   that they do not move a full viewport, effectively creating a scroll offset
-- - not implemented via Karabiner, since Karabiner does not allow for scrolling

-- CONFIG
local scrollamount = 35

--------------------------------------------------------------------------------

---@param amount number steps to be scroll down (or up if negative)
local function scroll(amount)
	local frontApp = hs.application.frontmostApplication()
	local frame = frontApp:mainWindow():frame()
	local screen = hs.mouse.getCurrentScreen() or hs.screen.mainScreen()
	print("👽 beep")

	-- cursor needs to be inside main window to scroll the right frame
	local centerPos = { x = frame.x + frame.w * 0.5, y = frame.y + frame.h * 0.5 }
	hs.mouse.setRelativePosition(centerPos)
	hs.eventtap.scrollWheel({ 0, amount }, {})

	-- now moving cursor away so it is not in the way
	local bottomLeftPos = { x = 0, y = screen:frame().h * 0.9 }
	hs.mouse.setRelativePosition(bottomLeftPos, screen)
end

local function scrollDown() scroll(-scrollamount) end
local function scrollUp() scroll(scrollamount) end

--------------------------------------------------------------------------------
-- HOTKEYS

u.hotkey({ "alt" }, "J", scrollDown, nil, scrollDown)
u.hotkey({}, "pagedown", scrollDown, nil, scrollDown)

u.hotkey({ "alt" }, "K", scrollUp, nil, scrollUp)
u.hotkey({}, "pageup", scrollUp, nil, scrollUp)
