-- INFO
-- A simple wrapper around vim's builtin mark functionality for quick navigation.
--------------------------------------------------------------------------------

local M = {}
local markExtmarks = {}

---@param msg string
local function notify(msg) vim.notify(msg, nil, { title = "Marks", icon = "󰃃" }) end

--------------------------------------------------------------------------------

---@class (exact) Markobj
---@field name string
---@field row integer
---@field col integer
---@field bufnr integer
---@field path integer

---@param name string
---@return Markobj|nil
local function getMark(name)
	local mRow, mCol, mBufnr, mPath = unpack(vim.api.nvim_get_mark(name, {}))
	local mark = { name = name, row = mRow, col = mCol, bufnr = mBufnr, path = mPath }
	if mRow ~= 0 then return mark end
end

---@param m Markobj?
---@return boolean
local function cursorIsAtMark(m)
	if not m then return false end
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local bufnr = vim.api.nvim_get_current_buf()
	return m.row == row and m.bufnr == bufnr
end

---@param markName string
local function clearSignForMark(markName)
	local ns = vim.api.nvim_create_namespace("mark-signs")
	local m = getMark(markName)
	if not m then return end
	vim.api.nvim_buf_clear_namespace(m.bufnr, ns, m.row, m.row + 1)
end

---@param markName string
local function setSignForMark(markName)
	clearSignForMark(markName)
	local ns = vim.api.nvim_create_namespace("mark-signs")
	local m = getMark(markName)
	if not m then return end

	if markExtmarks[markName] then
		vim.api.nvim_buf_del_extmark(m.bufnr, ns, markExtmarks[markName])
	end
	markExtmarks[markName] = vim.api.nvim_buf_set_extmark(m.bufnr, ns, m.row - 1, 1, {
		sign_text = "󰃀" .. markName,
		sign_hl_group = "Todo",
	})
end

--------------------------------------------------------------------------------

---@param marks string[]
function M.cycleMarks(marks)
	-- determine next mark
	local nextMark, marksSet = marks[1], 0
	for i, name in ipairs(marks) do
		local m = getMark(name)
		if m then
			marksSet = marksSet + 1
			if cursorIsAtMark(m) then
				nextMark = marks[i == #marks and 1 or i + 1]
				break
			end
		end
	end

	-- goto next mark
	local next = getMark(nextMark)
	if not next then
		local msg = marksSet == 0 and "No mark has been set." or "Already at the only mark set."
		notify(msg)
		return
	end

	if next.bufnr > 0 then
		vim.api.nvim_set_current_buf(next.bufnr)
	else
		vim.cmd.edit(next.path)
	end
	vim.api.nvim_win_set_cursor(0, { next.row, next.col })
	setSignForMark(next.name) -- simpler than setting it on `BufEnter`
end

---@param mark string
function M.setUnsetMark(mark)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local m = getMark(mark)
	if cursorIsAtMark(m) then
		clearSignForMark(mark)
		vim.api.nvim_del_mark(mark)
		notify(("Mark [%s] set."):format(mark))
	else
		vim.api.nvim_buf_set_mark(0, mark, row, col, {})
		setSignForMark(mark)
		notify(("Mark [%s] set."):format(mark))
	end
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
