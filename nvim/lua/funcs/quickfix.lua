local M = {}
local g = vim.g

---checks whether quickfixlist is empty and notifies
---@return boolean
local function quickFixIsEmpty()
	if #vim.fn.getqflist() == 0 then
		vim.notify(" Quickfix List empty.", vim.log.levels.WARN)
		return true
	end
	return false
end

--------------------------------------------------------------------------------

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
-- keymaps

---delete the quickfixlist
function M.deleteList() vim.cmd.cexpr("[]") end

---goto next quickfix and wrap around
function M.next()
	if quickFixIsEmpty() then return end
	if not g.qfCount then g.qfCount = 0 end -- initialize counter

	local wentToNext = pcall(function() cmd([[silent cnext]]) end)
	if wentToNext then
		g.qfCount = g.qfCount + 1
	else
		cmd([[silent cfirst]])
		g.qfCount = 1
	end
end

---goto previous quickfix and wrap around
function M.previous()
	if quickFixIsEmpty() then return end
	if not g.qfCount then g.qfCount = #(vim.fn.getqflist()) end -- initialize counter

	local wentToPrevious = pcall(function() cmd([[silent cprevious]]) end)
	if wentToPrevious then
		g.qfCount = g.qfCount - 1
	else
		cmd([[silent clast]])
		g.qfCount = #(vim.fn.getqflist())
	end
end

---wrapper around replacer.nvim for convenience
---@param closingKeys string[]? keys to save changes and close quickfix window
function M.replacerWrapper(closingKeys)
	if quickFixIsEmpty() then return end
	if not require("replacer") then
		vim.notify("replacer.nvim not installed.", vim.log.levels.ERROR)
		return
	end

	-- if not yet in quickfix window, open it
	if vim.bo.filetype ~= "qf" then cmd.copen() end

	-- run replacer
	require("replacer").run { rename_files = true }
	vim.cmd.file("Quickfix: Replacer") -- set buffer name

	-- set closing keybindings for replacer.nvim
	if not closingKeys or #closingKeys == 0 then return end
	for _, key in pairs(closingKeys) do
		vim.keymap.set("n", key, function()
			vim.cmd.write()
			vim.notify(" Finished replacing.", vim.log.levels.INFO)
		end, { desc = " Finish replacing", buffer = true, nowait = true })
	end
end

--------------------------------------------------------------------------------

return M
