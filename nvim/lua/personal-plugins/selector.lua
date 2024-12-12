local M = {}
--------------------------------------------------------------------------------

local config = {
	ft = "selector",
	border = "single",
}

--------------------------------------------------------------------------------

---@param items any[]
---@param opts { prompt?: string, kind?: string, format_item: fun(item: any): string  }
---@param on_choice fun(item: any?, idx: integer?)
M.select = function(items, opts, on_choice)
	if type(on_choice) ~= "function" then
		vim.notify("`on_choice` must be a function", vim.log.levels.ERROR)
		return
	end
	local defaultOpts = { prompt = "", kind = "select", format_item = function(i) return i end }
	opts = vim.tbl_deep_extend("force", defaultOpts, opts)

	local choices = vim.tbl_map(opts.format_item, items)
	local longestChoice = vim.iter(choices):fold(0, function(acc, c) return math.max(acc, #c) end)
	local width = math.max(longestChoice, #opts.prompt) + 2
	local height = #choices

	-- create window
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, choices)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "cursor",
		row = 1,
		col = 1,
		width = width,
		height = height,
		title = " " .. opts.prompt .. " ",
		border = config.border,
		style = "minimal",
	})
	vim.wo[winnr].winfixbuf = true
	vim.bo[bufnr].modifiable = false
	vim.wo[winnr].statuscolumn = " " -- = left-padding
	vim.bo[bufnr].filetype = config.ft
	vim.wo[winnr].cursorline = true
	
	-- keymaps
	local mapOpts = { buffer = bufnr, nowait = true }
	vim.keymap.set("n", "q", vim.cmd.close, mapOpts)
	vim.keymap.set("n", "<Esc>", vim.cmd.close, mapOpts)
	vim.keymap.set("n", "<CR>", function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		local item = items[lnum]
		on_choice(item, lnum)
		vim.cmd.close()
	end, mapOpts)
end

--------------------------------------------------------------------------------
return M
