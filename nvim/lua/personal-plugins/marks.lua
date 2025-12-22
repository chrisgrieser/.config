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
local lastMarkSet

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

---@param mark string
local function deleteMark(mark)
	local row, _col, bufnr, path = unpack(vim.api.nvim_get_mark(mark, {}))
	if path == nil or path == "" then return end -- mark not set
	vim.api.nvim_del_mark(mark)
	vim.api.nvim_buf_clear_namespace(bufnr, ns, row - 1, row)
end

---@return string[]
local function getSetMarks()
	return vim.tbl_filter(function(mark)
		local row = unpack(vim.api.nvim_get_mark(mark, {}))
		return row ~= nil and row ~= 0
	end, config.marks)
end

--------------------------------------------------------------------------------

function M.cycleMarks()
	local marksSet = getSetMarks()

	if #marksSet == 0 then
		notify("No mark has been set.")
		return
	elseif #marksSet == 1 and cursorIsAtMark(marksSet[1]) then
		notify("Already at the only mark set.")
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
		notify(("Mark [%s] not valid anymore."):format(nextMark), "warn")
		vim.api.nvim_del_mark(nextMark)
	end
end

function M.setUnsetMark()
	local setMarks = getSetMarks()

	-- if cursor is at a mark, delete it
	for _, mark in ipairs(setMarks) do
		if cursorIsAtMark(mark) then
			deleteMark(mark)
			notify(("Mark [%s] deleted."):format(mark))
			return
		end
	end

	-- otherwise, set mark
	local firstUnsetMark = vim.iter(config.marks)
		:find(function(mark) return not vim.list_contains(setMarks, mark) end)
	local markToSet = firstUnsetMark
	if not markToSet then
		local nextMark = config.marks[1]
		for _, mark in ipairs(config.marks) do
			if lastMarkSet and mark > lastMarkSet then -- lua can compare letters
				nextMark = mark
				break
			end
		end
		markToSet = nextMark
	end

	deleteMark(markToSet)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	vim.api.nvim_buf_set_mark(0, markToSet, row, col, {})
	lastMarkSet = markToSet
	setSignForMark(markToSet)
	notify(("Mark [%s] set."):format(markToSet))
end

function M.loadSigns()
	vim.schedule(function() -- scheduled to ensure shadafile is loaded
		vim.iter(config.marks):each(setSignForMark)
	end)
end

--------------------------------------------------------------------------------
return M
