local M = {}
--------------------------------------------------------------------------------

local MARKS = { "A", "B" }

---@param msg string
local function notify(msg) vim.notify(msg, nil, { title = "Marks", icon = "󰃃" }) end

function M.cycleMarks()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local bufnr = vim.api.nvim_get_current_buf()

	local nextMark
	for i, name in pairs(MARKS) do
		local mRow, mCol, mBufnr = unpack(vim.api.nvim_get_mark(name, {}))
		local isAtMark = mRow == row and mCol == col and mBufnr == bufnr
		if isAtMark then
			nextMark = MARKS[i == #MARKS and 1 or i + 1]
			break
		end
	end
	if not nextMark then
		notify("No mark has been set.")
		return
	end

	local nextRow, nextCol, nextBufnr = unpack(vim.api.nvim_get_mark(nextMark, {}))
	vim.api.nvim_buf_set_mark(bufnr, nextMark, row, col, {})
	vim.api.nvim_set_current_buf(mBufnr)
	vim.api.nvim_win_set_cursor(0, { mRow, mCol })
	return
	vim.api.nvim_buf_set_mark(bufnr, MARKS[1], nextRow, nextCol, {})

	local mark = vim.api.nvim_get_mark(MARKS[1], {})
	mark["name"] = MARKS[1]
	Chainsaw(mark) -- 🪚
end

function M.setMark()
	local newMark = MARKS[1]
	for _, mark in pairs(MARKS) do
		if vim.api.nvim_get_mark(mark, {}) == 0 then
			newMark = mark
			break
		end
	end

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_mark(0, newMark, row, col, {})
	notify(("Mark [%s] set."):format(newMark))
end

function M.deleteMarks()
	for _, mark in pairs(MARKS) do
		vim.api.nvim_del_mark(mark)
	end
	notify("All marks deleted.")
end

--------------------------------------------------------------------------------
return M
