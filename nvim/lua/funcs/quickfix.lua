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

-- statusline component
function M.counter()
	local count = #vim.fn.getqflist()
	if count == 0 then return "" end
	return " " .. tostring(count)
end

--------------------------------------------------------------------------------
-- keymaps

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

function M.replacerWrapper()
	if quickFixIsEmpty() then return end
	if not require("replacer") then 
		vim.notify("replacer.nvim not installed.", vim.log.levels.ERROR)
		return
	end

	-- if not yet in quickfix window, open it
	if vim.bo.filetype ~= "qf" then cmd.copen() end

	require("replacer").run { rename_files = true }
	for _, key in pairs { "<D-w>", "<D-s>", "q" } do
		keymap("n", key, function()
			cmd.write()
			vim.notify(" Finished replacing.")
		end, { desc = " Finish replacing", buffer = true, nowait = true })
	end
end

--------------------------------------------------------------------------------

return M
