local M = {}

local env = require("meta.environment")
local u = require("meta.utils")
local wu = require("win-management.window-utils")
--------------------------------------------------------------------------------

-- https://www.hammerspoon.org/Spoons/RoundedCorners.html
local roundedCorner = hs.loadSpoon("RoundedCorners")
if roundedCorner then
	roundedCorner.radius = 7
	roundedCorner:start()
end

--------------------------------------------------------------------------------

-- FIX https://github.com/FelixKratz/SketchyBar/issues/641
local function privacyIndicatorCover()
	local toMode = u.isDarkMode() and "dark" or "light"
	local bgColor = toMode == "dark" and { red = 0.2, green = 0.2, blue = 0.2, alpha = 1 }
		or { red = 0.8, green = 0.8, blue = 0.8, alpha = 1 }

	---@diagnostic disable: undefined-field
	if M.privacyDot then
		M.privacyDot:delete()
		M.privacyDot = nil
	end
	if env.isProjector() then return end

	local screen = hs.screen.mainScreen():frame()
	M.privacyDot = hs.drawing.rectangle { x = screen.w - 50, y = screen.h - 50, w = 20, h = 20 }

	M.privacyDot:setFillColor(bgColor)
	M.privacyDot:setFill(true)
	M.privacyDot:setStrokeColor(bgColor)
	M.privacyDot:sendToBack()
	M.privacyDot:show()
	---@diagnostic enable: undefined-field
end

---to stop wallpaper shining through
local function holeCover()
	local toMode = u.isDarkMode() and "dark" or "light"

	if M.triangleParts then
		for _, cover in pairs(M.triangleParts) do
			cover:delete()
			cover = nil
		end
		M.triangleParts = nil
	end
	if env.isProjector() then return end

	local screen = hs.screen.mainScreen():frame()
	local pseudoMaxCorner = wu.toTheSide.w + wu.toTheSide.x
	local bgColor = toMode == "dark" and { red = 0.2, green = 0.2, blue = 0.2, alpha = 1 }
		or { red = 0.8, green = 0.8, blue = 0.8, alpha = 1 }

	M.triangleParts = {
		hs.drawing.rectangle { x = pseudoMaxCorner - 9, y = screen.h - 3, w = 18, h = 3 },
		hs.drawing.rectangle { x = pseudoMaxCorner - 6, y = screen.h - 6, w = 12, h = 3 },
		hs.drawing.rectangle { x = pseudoMaxCorner - 3, y = screen.h - 9, w = 6, h = 3 },
	}

	for _, cover in pairs(M.triangleParts) do
		cover:setFillColor(bgColor)
		cover:setFill(true)
		cover:setStrokeColor(bgColor)
		cover:sendToBack()
		cover:show()
	end
end

--------------------------------------------------------------------------------

function M.update()
	holeCover()
	privacyIndicatorCover()
end
if u.isSystemStart() then M.update() end

--------------------------------------------------------------------------------
return M
