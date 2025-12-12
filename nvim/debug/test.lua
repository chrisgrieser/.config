local M = {}
--------------------------------------------------------------------------------

---@param win hs.window
---@param pos hs.geometry
function M.moveResize(win, pos)
	if not (win and win:isMaximizable() and win:isStandard()) then return end

	-- handle negative positions (= win partially not on screen) by converting
	-- them to a frame, since `moveToUnit` doesn't support negative positions
	if pos.x < 0 then
		local screenFrame = win:screen():frame()
		local x = pos.x
		pos.x = 0 -- store, since `fromUnitRect` cannot handle negative values
		local rect = pos:fromUnitRect(screenFrame)
		pos.x = x
		rect.x = x * screenFrame.w
		win:setFrame(rect)
		return
	end

	-- resize with redundancy, since macOS sometimes doesn't resize properly
	u.defer({ 0, 0.4, 0.8 }, function() win:moveToUnit(pos) end)
end


--------------------------------------------------------------------------------
return M

