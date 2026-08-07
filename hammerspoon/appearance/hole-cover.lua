-- INFO Stop the macOS wallpaper from shining through gaps due to rounded
-- corners of macOS apps.
--------------------------------------------------------------------------------
local M = {}

---CORNERS OF THE SCREEN--------------------------------------------------------
-- DOCS https://www.hammerspoon.org/Spoons/RoundedCorners.html
local roundedCorner = hs.loadSpoon("RoundedCorners")
if roundedCorner then
	roundedCorner.allScreens = true
	roundedCorner.radius = 15 -- higher for macOS Tahoe
	roundedCorner:start()
end

---BOTTOM/TOP OF THE SCREEN ----------------------------------------------------
M.cover_top = {}
M.cover_bottom = {}

function M.update()
	local coverHeight = 20 -- CONFIG

	-----------------------------------------------------------------------------
	-- initialize/reset covers
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

	-- add covers on each screen (but bottom cover only on the main screen)
	local allScreens = hs.screen.allScreens() --[[@as hs.screen[]]
	for i, screen in ipairs(allScreens) do
		local frame = screen:fullFrame() -- fullframe includes the menu bar
		local menubarHeight = screen:fullFrame().h - screen:frame().h - 2
		local bgColor = U.isDarkMode() and { red = 0.1, green = 0.1, blue = 0.1, alpha = 1 }
			or { red = 0.88, green = 0.88, blue = 0.88, alpha = 1 }

		local pos = { x = 0, y = menubarHeight, w = frame.w, h = coverHeight }
		M.cover_top[i] = hs
			.canvas -- 󰁅 transform to screen-relative positions
			.new(screen:localToAbsolute(pos)) --[[@as hs.canvas]]
			:appendElements({
				{ type = "rectangle", action = "fill", fillColor = bgColor },
			}) --[[@as hs.canvas]]
			:sendToBack() --[[@as hs.canvas]]
			:show()

		local isMainScreen = hs.screen.mainScreen():id() == screen:id()
		if isMainScreen then
			pos = { x = 0, y = frame.h - coverHeight, w = frame.w, h = coverHeight }
			M.cover_bottom[i] = hs
				.canvas
				.new(screen:localToAbsolute(pos)) --[[@as hs.canvas]]
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
