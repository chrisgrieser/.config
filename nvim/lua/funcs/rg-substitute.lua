local M = {}
--------------------------------------------------------------------------------

local config = {
	win = {
		width = 40,
		border = vim.g.borderStyle,
	},
	keymaps = {
		confirm = "<CR>",
		abort = "q",
	},
}

-- XXXaaaaaa
-- XXXaaaaaa
-- XXXaaaaaa
-- XXXaaaaaa

---@param rgBuf integer temporary rg buffer
---@param targetBuf integer buffer where the output will be written
local function executeSubstitution(rgBuf, targetBuf)
	local toSearch, toReplace = unpack(vim.api.nvim_buf_get_lines(rgBuf, 0, -1, false))
	local file = vim.api.nvim_buf_get_name(targetBuf)

	-- HACK deal with annoying named capture groups (see `man rg` on `--replace`)
	toReplace = toReplace:gsub("%$(%d+)", "${%1}")

	local rgResult = vim.system({
		"rg",
		toSearch,
		"--replace=" .. toReplace,
		"--passthrough",
		"--no-line-number",
		"--no-config",
		"--",
		file,
	}):wait()
	assert(rgResult.code == 0, "rg failed: " .. rgResult.stderr)

	-- update
	local newLines = vim.split(rgResult.stdout, "\n")
	vim.api.nvim_buf_set_lines(targetBuf, 0, -1, false, newLines)
end

function M.rgSubstitute()
	local targetBuf = vim.api.nvim_get_current_buf()

	-- create & prefill temp rg-buffer
	local searchPrefill
	if vim.fn.mode() == "n" then
		searchPrefill = vim.fn.expand("<cword>")
	else
		vim.cmd.normal { '"zy', bang = true }
		searchPrefill = vim.fn.getreg("z")
	end
	local rgBuf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(rgBuf, 0, -1, false, { searchPrefill, "" })
	-- adds syntax highlighting via treesitter `regex` parser
	vim.api.nvim_set_option_value("filetype", "regex", { buf = rgBuf })

	-- create window
	local winnr = vim.api.nvim_open_win(rgBuf, true, {
		relative = "win",
		row = vim.api.nvim_win_get_height(0) - 5,
		col = math.floor((vim.api.nvim_win_get_width(0) - config.win.width) / 2),
		width = config.win.width,
		height = 2,
		style = "minimal",
		border = config.win.border,
		title = "  rg substitute ",
		title_pos = "center",
	})
	vim.api.nvim_set_option_value("signcolumn", "no", { win = winnr })
	vim.api.nvim_set_option_value("number", false, { win = winnr })
	vim.api.nvim_set_option_value("sidescrolloff", 0, { win = winnr })
	vim.api.nvim_set_option_value("scrolloff", 0, { win = winnr })
	vim.cmd.startinsert { bang = true }

	-- keymaps
	local function close()
		vim.api.nvim_win_close(winnr, true)
		vim.api.nvim_buf_delete(rgBuf, { force = true })
	end

	vim.keymap.set({ "n", "x" }, config.keymaps.abort, close, { buffer = rgBuf, nowait = true })
	vim.keymap.set({ "n", "x" }, config.keymaps.confirm, function()
		executeSubstitution(rgBuf, targetBuf)
		close()
	end, { buffer = rgBuf, nowait = true })
end

--------------------------------------------------------------------------------
return M





