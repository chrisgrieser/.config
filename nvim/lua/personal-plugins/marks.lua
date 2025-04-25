-- INFO
-- A simple wrapper around vim's builtin mark functionality for quick navigation.
--------------------------------------------------------------------------------

local config = {
	sign = {
		hlgroup = "@keyword.return",
		priority = 21, -- gitsigns use 20
		icons = { A = "󰬈", B = "󰬉", C = "󰬊", D = "󰬋" },
	},
}

--------------------------------------------------------------------------------

local M = {}

---@class (exact) Markobj
---@field name string
---@field row integer
---@field col integer
---@field bufnr integer
---@field path string
--------------------------------------------------------------------------------

---@param msg string
---@param level? "warn" | "error"
local function notify(msg, level)
	local lvl = level and level:upper() or "INFO"
	vim.notify(msg, vim.log.levels[lvl], { title = "Marks", icon = "󰃀" })
end

---@param names string|string[]
---@return boolean
local function isValidMarkName(names)
	if type(names) == "string" then names = { names } end
	for _, name in pairs(names) do
		local valid = name:find("^%u$") ~= nil
		if not valid then
			notify(("[%s] is not an uppercase letter."):format(names), "error")
			return false
		end
	end
	return true
end

---@param name string
---@return Markobj|nil -- nil if mark is not set
local function getMark(name)
	local m = vim.api.nvim_get_mark(name, {})
	local mark = { name = name, row = m[1], col = m[2], bufnr = m[3], path = m[4] } --[[@as Markobj]]
	if m[1] ~= 0 then return mark end
end

---@param m Markobj
---@return boolean
local function cursorIsAtMark(m)
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

	vim.api.nvim_buf_set_extmark(m.bufnr, ns, m.row - 1, 0, {
		sign_text = config.sign.icons[name] or name,
		sign_hl_group = config.sign.hlgroup,
		priority = config.sign.priority,
	})
end

--------------------------------------------------------------------------------

---@param names string[]
function M.cycleMarks(names)
	if not isValidMarkName(names) then return end

	local marksSet = vim
		.iter(names)
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
	if not isValidMarkName(name) then return end

	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local m = getMark(name)
	if m and cursorIsAtMark(m) then
		clearSignForMark(m)
		vim.api.nvim_del_mark(name)
		notify(("Mark [%s] cleared."):format(name))
	else
		clearSignForMark(m)
		vim.api.nvim_buf_set_mark(0, name, row, col, {})
		setSignForMark(name)
		notify(("Mark [%s] set."):format(name))
	end
end

function M.deleteAllMarks()
	local allMarks = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	for i = 1, #allMarks do
		local name = allMarks:sub(i, i)
		clearSignForMark(getMark(name))
		vim.api.nvim_del_mark(name)
	end
	notify("All marks deleted.")
end

--------------------------------------------------------------------------------
return M
