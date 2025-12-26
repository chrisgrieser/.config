-- INFO Simple wrapper around vim's builtin mark functionality with some extras.
-- * shows marks in the signcolumn
-- * command to set a mark
-- * command to delete all marks
--------------------------------------------------------------------------------

local config = {
	marks = { "A", "B" },
	signHlGroup = "StandingOut",
	signIcons = { A = "󰬈", B = "󰬉" },
	notifyIcon = "󰃀",
}

--------------------------------------------------------------------------------

local M = {}
local ns = vim.api.nvim_create_namespace("mark-signs")

---@param msg string
---@param level? "info"|"warn"|"error"
local function notify(msg, level)
	local lvl = level and level:upper() or "INFO"
	vim.notify(msg, vim.log.levels[lvl], { title = "Marks", icon = config.notifyIcon })
end

---@param mark string
---@return boolean
local function cursorIsAtMark(mark)
	local row, _col, bufnr, path = unpack(vim.api.nvim_get_mark(mark, {}))
	if path == nil or path == "" then return false end -- mark not set
	local cursorRow = vim.api.nvim_win_get_cursor(0)[1]
	local currentBuf = vim.api.nvim_get_current_buf()
	return cursorRow == row and currentBuf == bufnr -- do not check for col
end

---@param mark string
local function setSignForMark(mark)
	local row, _col, bufnr, path = unpack(vim.api.nvim_get_mark(mark, {}))
	if path == nil or path == "" then return end -- mark not set

	local function setExtmark(buf, line)
		vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, {
			sign_text = config.signIcons[mark] or mark,
			sign_hl_group = config.signHlGroup,
		})
	end

	if bufnr ~= 0 then
		setExtmark(bufnr, row)
		return
	end

	-- setup setting signs for marks that are in files that are not opened yet
	vim.api.nvim_create_autocmd("BufReadPost", {
		desc = "User(once): Add signs for mark " .. mark,
		callback = function(ctx)
			if ctx.file == path then
				setExtmark(ctx.buf, row)
				return true -- delete this autocmd
			end
		end,
	})
end

---if cursor is at a mark, delete it, otherwise set it
---@param mark string
local function setUnsetMark(mark)
	-- delete mark
	local mrow, _mcol, bufnr, path = unpack(vim.api.nvim_get_mark(mark, {}))
	if path and path ~= "" then
		vim.api.nvim_del_mark(mark)
		vim.api.nvim_buf_clear_namespace(bufnr, ns, mrow - 1, mrow)
	end
	if cursorIsAtMark(mark) then return end

	-- if cursor not at mark, set it at the new position
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_mark(0, mark, row, col, {})
	setSignForMark(mark)
end

--------------------------------------------------------------------------------

function M.cycleMarks()
	local marksSet = vim.tbl_filter(function(mark)
		local row = unpack(vim.api.nvim_get_mark(mark, {}))
		return row ~= nil and row ~= 0
	end, config.marks)
	if #marksSet == 0 then
		notify("No mark has been set.")
		return
	elseif #marksSet == 1 and cursorIsAtMark(marksSet[1]) then
		notify(("[%s] is the only mark set."):format(marksSet[1]))
		return
	end

	-- determine next mark
	local nextMark = marksSet[1] -- default to first one, if not at mark
	for i, mark in ipairs(marksSet) do
		if cursorIsAtMark(mark) then
			nextMark = marksSet[i + 1] or marksSet[1]
			break
		end
	end

	-- goto next mark
	local row, col, bufnr, path = unpack(vim.api.nvim_get_mark(nextMark, {}))
	local markInUnopenedFile = bufnr == 0
	if markInUnopenedFile then
		vim.cmd.edit(path)
	else
		vim.api.nvim_set_current_buf(bufnr)
	end
	local success = pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
	if success then
		vim.cmd.normal { "zv", bang = true } -- open folds at cursor
	else
		notify(("[%s] not valid anymore"):format(nextMark), "warn")
		vim.api.nvim_del_mark(nextMark)
	end
end

for _, mark in ipairs(config.marks) do
	M["setUnset" .. mark] = function() setUnsetMark(mark) end
end

function M.loadSigns()
	vim.schedule(function() -- scheduled to ensure shadafile is loaded
		vim.iter(config.marks):each(setSignForMark)
	end)
end

--------------------------------------------------------------------------------
return M
