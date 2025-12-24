-- INFO Stop the macOS wallpaper from shining through gaps due to rounded
-- corners of macOS apps.
--------------------------------------------------------------------------------
local M = {}

local env = require("meta.environment")
local u = require("meta.utils")

---CORNERS OF THE SCREEN--------------------------------------------------------
local roundedCorner = hs.loadSpoon("RoundedCorners") -- https://www.hammerspoon.org/Spoons/RoundedCorners.html
if roundedCorner then
	roundedCorner.radius = 15 -- higher for macOS Tahoe
	roundedCorner:start()
end

---BOTTOM OF THE SCREEN --------------------------------------------------------
function M.update()
	if M.cover then
		M.cover:delete() ---@diagnostic disable-line: undefined-field
		M.cover = nil
	end
	if env.isProjector() then return end

	local screen = hs.screen.mainScreen():frame()
	local bgColor = u.isDarkMode() and { red = 0.2, green = 0.2, blue = 0.2, alpha = 1 }
		or { red = 0.8, green = 0.8, blue = 0.8, alpha = 1 }

	local height = 20
	M.cover = hs
		.canvas
		.new({ x = 0, y = screen.h - height, w = screen.w, h = height }) --[[@as hs.canvas]]
		:appendElements({
			{ type = "rectangle", action = "fill", fillColor = bgColor },
		}) --[[@as hs.canvas]]
		:sendToBack() --[[@as hs.canvas]]
		:show()
end
M.update() -- initialize

--------------------------------------------------------------------------------
return M
