-- INFO
-- A simple wrapper around vim's builtin mark functionality for quick navigation.
--------------------------------------------------------------------------------

local M = {}
local markExtmarks = {}

---@param msg string
local function notify(msg) vim.notify(msg, nil, { title = "Marks", icon = "󰃃" }) end

--------------------------------------------------------------------------------

local function clearSignForMark(markName)
	local ns = vim.api.nvim_create_namespace("mark-signs")
	local mRow, _, mBufnr = unpack(vim.api.nvim_get_mark(markName, {}))
	vim.api.nvim_buf_clear_namespace(mBufnr, ns, mRow, mRow + 1)
end

---@param markName string
local function setSignForMark(markName)
	clearSignForMark(markName)
	local ns = vim.api.nvim_create_namespace("mark-signs")
	local mRow, mCol, mBufnr = unpack(vim.api.nvim_get_mark(markName, {}))

	if markExtmarks[markName] then
		vim.api.nvim_buf_del_extmark(mBufnr, ns, markExtmarks[markName])
	end
	markExtmarks[markName] = vim.api.nvim_buf_set_extmark(mBufnr, ns, mRow - 1, mCol, {
		sign_text = "󰃃" .. markName,
		sign_hl_group = "Todo",
	})
end

--------------------------------------------------------------------------------

---@param marks string[]
function M.cycleMarks(marks)
	-- determine next mark
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local bufnr = vim.api.nvim_get_current_buf()

	local nextMark = marks[1]
	local marksSet = 0
	for i, name in pairs(marks) do
		local mRow, mCol, mBufnr = unpack(vim.api.nvim_get_mark(name, {}))
		if mBufnr ~= 0 then marksSet = marksSet + 1 end
		local isAtMark = mRow == row and mCol == col and mBufnr == bufnr
		if isAtMark then
			nextMark = marks[i == #marks and 1 or i + 1]
			break
		end
	end

	-- goto next mark
	local nextRow, nextCol, nextBufnr = unpack(vim.api.nvim_get_mark(nextMark, {}))
	if nextBufnr == 0 then
		local msg = marksSet == 0 and "No mark has been set." or "Already at the only mark set."
		notify(msg)
	else
		vim.api.nvim_set_current_buf(nextBufnr)
		vim.api.nvim_win_set_cursor(0, { nextRow, nextCol })
		setSignForMark(nextMark) -- simpler than setting it on bufenter
	end
end

---@param mark string
function M.setMark(mark)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_mark(0, mark, row, col, {})
	setSignForMark(mark)
	notify(("Mark [%s] set."):format(mark))
end

---@param marks string[]
function M.deleteMarks(marks)
	for _, mark in pairs(marks) do
		clearSignForMark(mark)
		vim.api.nvim_del_mark(mark)
	end
	notify("Marks deleted.")
end

--------------------------------------------------------------------------------
return M
