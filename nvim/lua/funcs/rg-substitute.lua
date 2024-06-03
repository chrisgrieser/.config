local M = {}
--------------------------------------------------------------------------------

-- XXXXXXXXXXXX
-- XXXXXXXXXXXX
-- XXXXXXXXXXXX
-- XXXXXXXXXXXX

---@param file string
---@param targetBuf integer buffer where the output will be written
---@param toSearch string
---@param toReplace string
local function executeSubstitution(file, targetBuf, toSearch, toReplace)
	local out = vim.system({
		"rg",
		toSearch,
		"--replace=" .. toReplace,
		"--passthrough",
		"--no-line-number",
		"--no-config",
		file,
	}):wait()
	assert(out.code == 0, "rg failed: " .. out.stderr)

	-- update
	local newLines = vim.split(out.stdout, "\n")
	vim.api.nvim_buf_set_lines(targetBuf, 0, -1, false, newLines)
end

function M.rgSubstitute()
	local targetBuf = vim.api.nvim_get_current_buf()
	local file = vim.api.nvim_buf_get_name(0)
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "ss", "" })

	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "win",
		row = vim.api.nvim_win_get_height(0) - 2,
		col = 1,
		width = 40,
		height = 2,
		style = "minimal",
		border = "rounded",
		title = "  rg substitute ",
		title_pos = "center",
	})
	vim.api.nvim_set_option_value("signcolumn", "no", { win = winnr })
	vim.api.nvim_set_option_value("number", false, { win = winnr })
	vim.api.nvim_set_option_value("sidescrolloff", 2, { win = winnr })
	vim.api.nvim_set_option_value("scrolloff", 0, { win = winnr })
	vim.cmd.startinsert()

	local function close()
		vim.api.nvim_win_close(winnr, true)
		vim.api.nvim_buf_delete(bufnr, { force = true })
	end

	vim.keymap.set({ "n", "x" }, "q", close, { buffer = bufnr, nowait = true })
	vim.keymap.set({ "n", "x", "i" }, "<D-CR>", function()
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		executeSubstitution(file, targetBuf, lines[1], lines[2])
		close()
	end, { buffer = bufnr, nowait = true })
end

--------------------------------------------------------------------------------
return M

