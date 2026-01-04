-- Simple wrapper around vim's builtin mark functionality, adding the features:
-- * marks are shown in the signcolumn
-- * command to set/unset a mark
-- * command to cycle through marks
--------------------------------------------------------------------------------

local config = {
	marks = { "A", "B" },
	signHlGroup = "StandingOut",
	signIcons = { A = "󰬈", B = "󰬉" },
}

--------------------------------------------------------------------------------

local M = {}
local ns = vim.api.nvim_create_namespace("mark-signs")

---@param msg string
---@param lvl? "info"|"warn"|"error"
local function notify(msg, lvl)
	if not lvl then lvl = "info" end
	vim.notify(msg, vim.log.levels[lvl:upper()], { title = "Marks", icon = "󰃀" })
end

---@param mark string
---@return boolean
local function cursorIsAtMark(mark)
	local row, _, bufnr, path = unpack(vim.api.nvim_get_mark(mark, {}))
	if path == nil or path == "" then return false end -- mark not set
	local cursorRow = vim.api.nvim_win_get_cursor(0)[1]
	local currentBuf = vim.api.nvim_get_current_buf()
	return cursorRow == row and currentBuf == bufnr -- intentionally don't check for col
end

---@param mark string
local function setSignForMark(mark)
	local row, _, bufnr, path = unpack(vim.api.nvim_get_mark(mark, {}))
	if path == nil or path == "" then return end -- mark not set

	local function setExtmark(buf, line, ma)
		vim.api.nvim_buf_set_extmark(buf, ns, line - 1, 0, {
			sign_text = config.signIcons[ma] or ma,
			sign_hl_group = config.signHlGroup,
		})
	end

	if bufnr ~= 0 then
		setExtmark(bufnr, row, mark)
		return
	end

	-- setup setting signs for marks that are in files that are not opened yet
	vim.api.nvim_create_autocmd("BufReadPost", {
		desc = "User(once): Add signs for mark " .. mark,
		callback = function(ctx)
			if ctx.file == path then
				setExtmark(ctx.buf, row, mark)
				return true -- delete this autocmd
			end
		end,
	})
end

---if cursor is at a mark, delete it, otherwise set it
---@param mark string
local function setUnsetMark(mark)
	local mrow, _, bufnr, _ = unpack(vim.api.nvim_get_mark(mark, {}))
	if mrow > 0 then vim.api.nvim_buf_clear_namespace(bufnr, ns, mrow - 1, mrow) end -- delete old sign

	if cursorIsAtMark(mark) then
		vim.api.nvim_del_mark(mark)
	else
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		vim.api.nvim_buf_set_mark(0, mark, row, col, {})
		setSignForMark(mark)
	end
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
		notify(("Already at the only mark [%s]."):format(marksSet[1]))
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
	local markInUnopenedFile = bufnr == 0 and path ~= ""
	if markInUnopenedFile then
		vim.cmd.edit(path)
	else
		vim.api.nvim_set_current_buf(bufnr)
	end
	local markExists = path ~= "" and pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
	if markExists then
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
