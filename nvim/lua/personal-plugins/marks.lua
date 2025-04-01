-- INFO
-- A simple wrapper around vim's builtin mark functionality for quick navigation.
--------------------------------------------------------------------------------

local M = {}
local markExtmarks = {}

---@param msg string
local function notify(msg) vim.notify(msg, nil, { title = "Marks", icon = "󰃀" }) end

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

---@param m Markobj?
local function clearSignForMark(m)
	if not m then return end
	local ns = vim.api.nvim_create_namespace("mark-signs")
	vim.api.nvim_buf_clear_namespace(m.bufnr, ns, m.row - 1, m.row)
end

---@param name string
local function setSignForMark(name)
	local ns = vim.api.nvim_create_namespace("mark-signs")
	local m = getMark(name)
	if not m then return end

	clearSignForMark(m)
	if markExtmarks[name] then
		vim.api.nvim_buf_del_extmark(m.bufnr, ns, markExtmarks[name])
	end
	markExtmarks[name] = vim.api.nvim_buf_set_extmark(m.bufnr, ns, m.row - 1, 1, {
		sign_text = "󰃃" .. name,
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
	local next = getMark(nextMark)
	if not next then
		local msg = marksSet == 0 and "No mark has been set." or "Already at the only mark set."
		notify(msg)
		return
	end

	-- goto next mark
	if next.bufnr > 0 then
		vim.api.nvim_set_current_buf(next.bufnr)
	else
		vim.cmd.edit(next.path)
	end
	vim.api.nvim_win_set_cursor(0, { next.row, next.col })
	vim.cmd.normal { "zv", bang = true } -- open folds at cursor

	-- set sign (simpler than setting it on `BufEnter`)
	setSignForMark(next.name)
end

---@param name string
function M.setUnsetMark(name)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local m = getMark(name)
	if m and cursorIsAtMark(m) then
		clearSignForMark(m)
		vim.api.nvim_del_mark(name)
		notify(("Mark [%s] cleared."):format(name))
	else
		vim.api.nvim_buf_set_mark(0, name, row, col, {})
		setSignForMark(name)
		notify(("Mark [%s] set."):format(name))
	end
end

---@param marks string[]
function M.deleteMarks(marks)
	for _, name in pairs(marks) do
		clearSignForMark(getMark(name))
		vim.api.nvim_del_mark(name)
	end
	notify("Marks deleted.")
end

--------------------------------------------------------------------------------
return M
