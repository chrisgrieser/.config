-- INFO Stop the macOS wallpaper from shining through gaps due to rounded
-- corners of macOS apps.
--------------------------------------------------------------------------------
local M = {}

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")

---CORNERS OF THE SCREEN--------------------------------------------------------
local roundedCorner = hs.loadSpoon("RoundedCorners") -- https://www.hammerspoon.org/Spoons/RoundedCorners.html
if roundedCorner then
	roundedCorner.radius = 20 -- macOS Tahoe's radius
	roundedCorner:start()
end

---BETWEEN THE MASTODON APP & PSEUDO-MAXIMIZED WINDOW-----------------------
function M.update()
	if M.coverParts then
		for _, cover in pairs(M.coverParts) do
			if cover.delete then cover:delete() end
			cover = nil
		end
		M.coverParts = nil
	end
	if env.isProjector() then return end

	local screen = hs.screen.mainScreen():frame()
	local pseudoMaxCornerEnd = wu.toTheSide.w * screen.w + 15
	local bgColor = u.isDarkMode() and { red = 0.2, green = 0.2, blue = 0.2, alpha = 1 }
		or { red = 0.8, green = 0.8, blue = 0.8, alpha = 1 }

	M.cover = hs
		.canvas
		.new({ x = 0, y = screen.h - 40, w = pseudoMaxCornerEnd, h = 40 }) --[[@as hs.canvas]]
		:appendElements({
			{ type = "rectangle", action = "fill", fillColor = bgColor },
		}) --[[@as hs.canvas]]
		:sendToBack() --[[@as hs.canvas]]
		:show()
end
M.update() -- initialize

--------------------------------------------------------------------------------
return M
