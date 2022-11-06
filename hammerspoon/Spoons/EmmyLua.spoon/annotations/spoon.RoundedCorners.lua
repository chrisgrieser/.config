--# selene: allow(unused_variable)
---@diagnostic disable: unused-local

-- Give your screens rounded corners
--
-- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/RoundedCorners.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/RoundedCorners.spoon.zip)
---@class spoon.RoundedCorners
local M = {}
spoon.RoundedCorners = M

-- Controls whether corners are drawn on all screens or just the primary screen. Defaults to true
M.allScreens = nil

-- Controls which level of the screens the corners are drawn at. See `hs.canvas.windowLevels` for more information. Defaults to `screenSaver + 1`
M.level = nil

-- Controls the radius of the rounded corners, in points. Defaults to 6
M.radius = nil

-- Starts RoundedCorners
--
-- Parameters:
--  * None
--
-- Returns:
--  * The RoundedCorners object
--
-- Notes:
--  * This will draw the rounded screen corners and start watching for changes in screen sizes/layouts, reacting accordingly
function M:start() end

-- Stops RoundedCorners
--
-- Parameters:
--  * None
--
-- Returns:
--  * The RoundedCorners object
--
-- Notes:
--  * This will remove all rounded screen corners and stop watching for changes in screen sizes/layouts
function M:stop() end

