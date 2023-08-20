local M = {}
--------------------------------------------------------------------------------

local g = vim.g
local cmd = vim.cmd

---checks whether quickfixlist is empty and notifies if it is
---@nodiscard
---@return boolean
local function quickFixIsEmpty()
	if #vim.fn.getqflist() == 0 then
		vim.notify(" Quickfix List empty.", vim.log.levels.WARN)
		return true
	end
	return false
end

--------------------------------------------------------------------------------

-- HELPERS

-- statusline component, showing current and total quickfix item
function M.counter()
	local totalItems = #vim.fn.getqflist()
	if totalItems == 0 then return "" end
	local out = " "
	if g.qfCount then out = out .. tostring(g.qfCount) .. "/" end
	out = out .. tostring(totalItems)
	return out
end

--------------------------------------------------------------------------------
-- KEYMAPS

---delete the quickfixlist
function M.deleteList()
	if g.qfCount then g.qfCount = nil end -- de-initialize
	vim.cmd.cexpr("[]")
end

---goto next quickfix and wrap around
function M.next()
	if quickFixIsEmpty() then return end
	if not g.qfCount then g.qfCount = 0 end -- initialize counter

	local wentToNext = pcall(function() cmd("silent cnext") end)
	if wentToNext then
		g.qfCount = g.qfCount + 1
	else
		cmd("silent cfirst")
		g.qfCount = 1
		vim.notify("Wrapping to the beginning.")
	end
end

---goto previous quickfix and wrap around
function M.previous()
	if quickFixIsEmpty() then return end
	if not g.qfCount then g.qfCount = #(vim.fn.getqflist()) end -- initialize counter

	local wentToPrevious = pcall(function() cmd("silent cprevious") end)
	if wentToPrevious then
		g.qfCount = g.qfCount - 1
	else
		cmd("silent clast")
		g.qfCount = #(vim.fn.getqflist())
		vim.notify("Wrapping to the end.")
	end
end

--------------------------------------------------------------------------------
return M
