-- INFO Stop the macOS wallpaper from shining through gaps due to rounded
-- corners of macOS apps.
--------------------------------------------------------------------------------
local M = {}

---CORNERS OF THE SCREEN--------------------------------------------------------
local roundedCorner = hs.loadSpoon("RoundedCorners") -- https://www.hammerspoon.org/Spoons/RoundedCorners.html
if roundedCorner then
	roundedCorner.radius = 15 -- higher for macOS Tahoe
	roundedCorner.allScreens = true
	roundedCorner:start()
end

---BOTTOM/TOP OF THE SCREEN ----------------------------------------------------

M.cover_top = {}
M.cover_bottom = {}

function M.update()
	-- CONFIG
	local height = 20
	local menubarHeight = 30

	for i = 1, #M.cover_top do
		if M.cover_top[i] then
			M.cover_top[i]:delete() ---@diagnostic disable-line: undefined-field
			M.cover_top[i] = nil
		end
	end
	for i = 1, #M.cover_bottom do
		if M.cover_bottom[i] then
			M.cover_bottom[i]:delete() ---@diagnostic disable-line: undefined-field
			M.cover_bottom[i] = nil
		end
	end

	-----------------------------------------------------------------------------

	local screens = hs.screen.allScreens() --[[@as hs.screen[]]
	for i, screen in ipairs(screens) do
		local frame = screen:fullFrame()
		local bgColor = require("meta.utils").isDarkMode()
				and { red = 0.1, green = 0.1, blue = 0.1, alpha = 1 }
			or { red = 0.88, green = 0.88, blue = 0.88, alpha = 1 }

		M.cover_top[i] = hs
			.canvas
			.new({ x = 0, y = menubarHeight, w = frame.w, h = height }) --[[@as hs.canvas]]
			:appendElements({
				{ type = "rectangle", action = "fill", fillColor = bgColor },
			}) --[[@as hs.canvas]]
			:sendToBack() --[[@as hs.canvas]]
			:show()

		local isMainScreen = hs.screen.mainScreen():id() == screen:id()
		if isMainScreen then
			M.cover_bottom[i] = hs
				.canvas
				.new({ x = 0, y = frame.h - height, w = frame.w, h = height }) --[[@as hs.canvas]]
				:appendElements({
					{ type = "rectangle", action = "fill", fillColor = bgColor },
				}) --[[@as hs.canvas]]
				:sendToBack() --[[@as hs.canvas]]
				:show()
		end
	end
end
M.update() -- initialize

--------------------------------------------------------------------------------
return M
