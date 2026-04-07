-- INFO Stop the macOS wallpaper from shining through gaps due to rounded
-- corners of macOS apps.
--------------------------------------------------------------------------------
local M = {}

---CORNERS OF THE SCREEN--------------------------------------------------------
local roundedCorner = hs.loadSpoon("RoundedCorners") -- https://www.hammerspoon.org/Spoons/RoundedCorners.html
if roundedCorner then
	roundedCorner.radius = 15 -- higher for macOS Tahoe
	roundedCorner:start()
end

---BOTTOM/TOP OF THE SCREEN ----------------------------------------------------
function M.update()
	if M.cover_bottom then
		M.cover_bottom:delete() ---@diagnostic disable-line: undefined-field
		M.cover_bottom = nil
	end
	if M.cover_top then
		M.cover_top:delete() ---@diagnostic disable-line: undefined-field
		M.cover_top = nil
	end

	local screen = hs.screen.mainScreen():fullFrame()

	local bgColor = require("meta.utils").isDarkMode()
			and { red = 0.1, green = 0.1, blue = 0.1, alpha = 1 }
		or { red = 0.88, green = 0.88, blue = 0.88, alpha = 1 }

	local height = 20
	M.cover_bottom = hs
		.canvas
		.new({ x = 0, y = screen.h - height, w = screen.w, h = height }) --[[@as hs.canvas]]
		:appendElements({
			{ type = "rectangle", action = "fill", fillColor = bgColor },
		}) --[[@as hs.canvas]]
		:sendToBack() --[[@as hs.canvas]]
		:show()

	local menubarHeight = 30
	M.cover_top = hs
		.canvas
		.new({ x = 0, y = menubarHeight, w = screen.w, h = height }) --[[@as hs.canvas]]
		:appendElements({
			{ type = "rectangle", action = "fill", fillColor = bgColor },
		}) --[[@as hs.canvas]]
		:sendToBack() --[[@as hs.canvas]]
		:show()
end
M.update() -- initialize

--------------------------------------------------------------------------------
return M
