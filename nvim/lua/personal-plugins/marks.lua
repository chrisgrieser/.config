-- INFO
-- A simple wrapper around vim's builtin mark functionality for quick navigation.
--------------------------------------------------------------------------------

local M = {}

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

local markExtmarks = {}
---@param name string
local function setSignForMark(name)
	local ns = vim.api.nvim_create_namespace("mark-signs")
	local m = getMark(name)
	if not m then return end

	clearSignForMark(m)
	if markExtmarks[name] then vim.api.nvim_buf_del_extmark(m.bufnr, ns, markExtmarks[name]) end
	markExtmarks[name] = vim.api.nvim_buf_set_extmark(m.bufnr, ns, m.row - 1, 1, {
		sign_text = "󰃃" .. name,
		sign_hl_group = "Todo",
	})
end

--------------------------------------------------------------------------------

---@param marks string[]
function M.cycleMarks(marks)
	for _, name in pairs(marks) do
		assert(name:find("^%u$"), ("%s is not an uppercase letter."):format(name))
	end

	-- get set marks
	local marksSet = vim
		.iter(marks)
		:map(function(name) return getMark(name) end) -- name -> Markobj
		:filter(function(m) return m ~= nil end) -- only marks that are set
		:totable()
	if #marksSet == 0 then
		notify("No mark has been set.")
		return
	end
	if #marksSet == 1 and cursorIsAtMark(marksSet[1]) then
		notify("Already at the only mark set.")
		return
	end

	-- determine next mark
	local nextMark = marksSet[1] -- default to first one, if at no mark
	for i, m in ipairs(marksSet) do
		if cursorIsAtMark(m) then
			nextMark = marksSet[i == #marksSet and 1 or i + 1]
			break
		end
	end

	-- goto next mark
	local markInUnopenedFile = nextMark.bufnr == 0
	if markInUnopenedFile then
		vim.cmd.edit(nextMark.path)
	else
		vim.api.nvim_set_current_buf(nextMark.bufnr)
	end
	vim.api.nvim_win_set_cursor(0, { nextMark.row, nextMark.col })
	vim.cmd.normal { "zv", bang = true } -- open folds at cursor
	setSignForMark(nextMark.name) -- setting here simpler than on `BufEnter`
end

---Set a mark, or unsets it if the cursor is on the same line as the mark
---@param name string
function M.setUnsetMark(name)
	assert(name:find("^%u$"), ("%s is not an uppercase letter."):format(name))

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

function M.deleteMarks()
	local allMarks = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for i = 1, #allMarks do
		local name = allMarks:sub(i, i)
		clearSignForMark(getMark(name))
		vim.api.nvim_del_mark(name)
	end
	notify("All marks deleted.")
end

function M.selectMarks()
	---@param marks string[]
function M.cycleMarks(marks)
	for _, name in pairs(marks) do
		assert(name:find("^%u$"), ("%s is not an uppercase letter."):format(name))
	end
end

--------------------------------------------------------------------------------
return M
