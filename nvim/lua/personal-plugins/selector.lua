-- INFO A simple UI for `vim.ui.select`.

local config = {
	border = vim.g.borderStyle,
	keymaps = {
		confirm = "<CR>",
		abort = { "<Esc>", "q" },
		next = "<Tab>",
		prev = "<S-Tab>",
		inspectItem = "?",
	},
}
--------------------------------------------------------------------------------

---@class (exact) SelectorOpts
---@field prompt? string nvim spec
---@field kind? string nvim spec
---@field format_item? fun(item: any): string nvim spec

---@param items any[]
---@param opts SelectorOpts
---@param on_choice fun(item: any, idx?: integer)
---@diagnostic disable-next-line: duplicate-set-field -- intentional overwrite
vim.ui.select = function(items, opts, on_choice)
	if #items == 0 then
		vim.notify("No items to select from.", vim.log.levels.INFO, { title = "Selector" })
		return
	end

	-- OPTIONS
	assert(type(on_choice) == "function", "`on_choice` must be a function.")
	local defaultOpts = { format_item = function(i) return i end, prompt = "Select", kind = "" }
	opts = vim.tbl_deep_extend("force", defaultOpts, opts) ---@type SelectorOpts
	opts.prompt = opts.prompt:gsub(":%s*$", "")
	if opts.kind == "codeaction" then
		opts.prompt = "󱐋 " .. opts.prompt
		opts.kind = ""
		opts.format_item = function(item)
			return ("%s [%s]"):format(item.action.title, item.action.kind)
		end
	end

	-- PARAMETERS
	local formattedItems = vim.tbl_map(opts.format_item, items)
	assert(type(formattedItems[1]) == "string", "`opts.format_item` must return a string.")
	local longestItemLen = vim.iter(formattedItems):fold(0, function(acc, c) return math.max(acc, #c) end)
	local width = math.max(longestItemLen, #opts.prompt, #opts.kind) + 2
	local height = #formattedItems
	local footer = opts.kind ~= "" and " " .. opts.kind .. " " or ""

	-- CREATE WINDOW
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formattedItems)
	local winid = vim.api.nvim_open_win(bufnr, true, {
		relative = "win",
		row = vim.o.lines / 2 - height / 2 - 1,
		col = vim.o.columns / 2 - width / 2,
		width = width,
		height = height,
		title = " " .. opts.prompt .. " ",
		footer = { { footer, "NonText" } },
		footer_pos = "right",
		border = config.border,
		style = "minimal",
	})
	vim.wo[winid].statuscolumn = " " -- = left-padding
	vim.wo[winid].cursorline = true
	vim.wo[winid].colorcolumn = ""
	vim.wo[winid].winfixbuf = true
	vim.bo[bufnr].modifiable = false
	vim.bo[bufnr].filetype = "selector"
	vim.wo[winid].sidescrolloff = 0

	-- highlighting
	pcall(vim.treesitter.start, bufnr, "markdown")
	vim.wo[winid].conceallevel = 3
	vim.wo[winid].concealcursor = "nvic"

	-- KEYMAPS
	local function map(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, nowait = true }) end
	for _, key in ipairs(config.keymaps.abort) do
		map(key, vim.cmd.bwipeout)
	end
	map(config.keymaps.next, function() vim.cmd.normal { "j", bang = true } end)
	map(config.keymaps.prev, function() vim.cmd.normal { "k", bang = true } end)
	map(config.keymaps.inspectItem, function()
		local ln = vim.api.nvim_win_get_cursor(0)[1]
		local out = vim.inspect(items[ln])
		vim.notify(out, vim.log.levels.INFO, { title = "Inspect", ft = "lua" })
	end)
	map(config.keymaps.confirm, function()
		local ln = vim.api.nvim_win_get_cursor(0)[1]
		vim.cmd.bwipeout()
		on_choice(items[ln], ln)
	end)

	-- UNMOUNT
	vim.api.nvim_create_autocmd("WinLeave", {
		desc = "Selector: Unmount",
		callback = function()
			local curWin = vim.api.nvim_get_current_win()
			if curWin == winid then
				vim.api.nvim_buf_delete(bufnr, { force = true })
				return true -- deletes this autocmd
			end
		end,
	})
end
