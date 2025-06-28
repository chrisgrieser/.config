-- INFO Simple wrapper around vim's builtin mark functionality with some extras.
-- * shows marks in the signcolumn
-- * command to cycle through marks
-- * command to set marks or unset if cursor is at the mark line
-- * command to delete all marks
--------------------------------------------------------------------------------

local M = {}
local ns = vim.api.nvim_create_namespace("mark-signs")

---@class (exact) Markobj
---@field name string
---@field row integer
---@field col integer
---@field bufnr integer
---@field path string
--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"warn"|"error"
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
			notify(('"[%s]" is not an uppercase letter.'):format(names), "error")
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

---@param m Markobj?
---@return boolean
local function cursorIsAtMark(m)
	if not m then return false end
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local bufnr = vim.api.nvim_get_current_buf()
	return m.row == row and m.bufnr == bufnr -- do not check for col
end

---@param name string
local function setSignForMark(name)
	local m = getMark(name)
	if not m then return end

	local function setExtmark(bufnr, row)
		vim.api.nvim_buf_set_extmark(bufnr, ns, row - 1, 0, {
			sign_text = M.config.signs.icons[name] or name,
			sign_hl_group = M.config.signs.hlgroup,
			priority = M.config.signs.priority,
		})
	end

	if m.bufnr ~= 0 then
		setExtmark(m.bufnr, m.row)
	else
		-- setup setting signs for marks that are in files that are not opened yet
		vim.api.nvim_create_autocmd("BufReadPost", {
			desc = "User(once): Add signs for mark " .. name,
			group = vim.api.nvim_create_augroup("marks-signs", { clear = true }),
			callback = function(ctx)
				if ctx.file ~= m.path then return end
				setExtmark(ctx.buf, m.row)
				return true -- delete this autocmd
			end,
		})
	end
end

--------------------------------------------------------------------------------

function M.cycleMarks()
	if not isValidMarkName(M.config.marks) then return end

	local marksSet = vim
		.iter(M.config.marks)
		:map(function(name) return getMark(name) end) -- name -> Markobj
		:filter(function(m) return m ~= nil end) -- only marks that are set
		:totable() --[[@as Markobj[] ]]

	if #marksSet == 0 then
		notify("No mark has been set.")
		return
	elseif #marksSet == 1 and cursorIsAtMark(marksSet[1]) then
		notify("Already at the only mark set.")
		return
	end

	-- determine next mark
	local nextMark = marksSet[1] -- default to first one, if not at mark
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
end

---@param name string
function M.setUnsetMark(name)
	if not isValidMarkName(name) then return end

	local m = getMark(name)
	if cursorIsAtMark(m) then
		M.deleteMark(name)
	else
		M.deleteMark(name, "silent") -- silent, since this func itself notifies
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		vim.api.nvim_buf_set_mark(0, name, row, col, {})
		setSignForMark(name)
		notify(("Mark [%s] set."):format(name))
	end
end

---@param name string
---@param silent? "silent"
function M.deleteMark(name, silent)
	if not isValidMarkName(name) then return end
	local m = getMark(name)
	if not m then return end

	vim.api.nvim_del_mark(m.name)
	if not silent then notify(("Mark [%s] deleted."):format(name)) end

	-- clear sign
	vim.api.nvim_buf_clear_namespace(m.bufnr, ns, m.row - 1, m.row)
end

function M.deleteAllMarks()
	if not isValidMarkName(M.config.marks) then return end
	for _, name in pairs(M.config.marks) do
		M.deleteMark(name, "silent") -- silent, since this func itself notifies
	end
	notify("All marks deleted.")
end

--------------------------------------------------------------------------------

---@class Marks.Config
local defaultConfig = {
	signs = {
		hlgroup = "IncSearch",
		priority = 30, -- gitsigns.nvim use 20
		icons = { A = "A", B = "B", C = "C" },
	},
	marks = { "A", "B", "C" },
}
M.config = defaultConfig

---@param userOpts table?
function M.setup(userOpts)
	if not userOpts then userOpts = {} end
	M.config = vim.tbl_deep_extend("force", defaultConfig, userOpts)
	if not isValidMarkName(M.config.marks) then return end

	vim.defer_fn(function()
		for _, name in pairs(M.config.marks) do
			setSignForMark(name)
		end
	end, 250) -- deferred to ensure shadafile is loaded
end

--------------------------------------------------------------------------------
return M
