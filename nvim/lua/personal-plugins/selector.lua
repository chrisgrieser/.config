-- INFO
-- simple UI for `vim.ui.select`
--------------------------------------------------------------------------------

local config = {
	win = {
		ft = "selector",
		border = "single",
		relative = "cursor",
		row = 2,
		col = 0,
		footer_pos = "left",
	},
	keymaps = {
		confirm = "<CR>",
		abort = { "<Esc>", "q" },
		next = "<Tab>",
		prev = "<S-Tab>",
		inspect = "?",
	},
	fallback = {
		provider = "telescope", -- currently only `telescope` is supported
		kindPatterns = { "tinygit" }, ---@type string[] -- checked via string.find
		moreItemsThan = 10,
	},
}

--------------------------------------------------------------------------------

local M = {}

---@class (exact) SelectorOpts
---@field prompt? string nvim spec for vim.ui.select
---@field kind? string nvim spec for vim.ui.select
---@field format_item? fun(item: any): string nvim spec for vim.ui.select
---@field footer? string specific to this plugin
---@field ft? string specific to this plugin

-- TODO
local function fallback(_items, _opts, _on_choice, _provider)
	vim.notify("Not implemented yet.", vim.log.levels.WARN)
end

--------------------------------------------------------------------------------

---@param items any[]
---@param opts SelectorOpts
---@param on_choice fun(item: any?, idx: integer?)
M.select = function(items, opts, on_choice)
	-- GUARD
	assert(on_choice, "`on_choice` must be a function")
	if #items == 0 then
		vim.notify("No items to select from.", vim.log.levels.WARN)
		return
	end

	-- fallback
	local defaultOpts = { kind = "select", format_item = function(i) return i end }
	opts = vim.tbl_deep_extend("force", defaultOpts, opts)
	local fallbackKind = vim.iter(config.fallback.kindPatterns)
		:any(function(p) return opts.kind:find(p) ~= nil end)
	local fallbackMore = #items > config.fallback.moreItemsThan
	if fallbackKind or fallbackMore then
		return fallback(items, opts, on_choice, config.fallback.provider)
	end

	-- parameters
	local title = opts.prompt and (" " .. opts.prompt .. " ") or nil
	local choices = vim.tbl_map(opts.format_item, items)
	assert(type(#choices[1]) == "string", "`format_item` must return a string.")
	local longestChoice = vim.iter(choices):fold(0, function(acc, c) return math.max(acc, #c) end)
	local width = math.max(longestChoice, #(title or "")) + 2
	local height = #choices
	local footer = opts.footer and (" " .. opts.footer .. " ") or nil

	-- create window
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, choices)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = config.win.relative,
		row = config.win.row,
		col = config.win.col,
		width = width,
		height = height,
		title = title,
		footer = footer,
		footer_pos = footer and config.win.footer_pos or nil,
		border = config.win.border,
		style = "minimal",
	})
	vim.wo[winnr].winfixbuf = true
	vim.bo[bufnr].modifiable = false
	vim.wo[winnr].statuscolumn = " " -- = left-padding
	vim.bo[bufnr].filetype = opts.ft or config.win.ft
	vim.bo[bufnr].buftype = "nofile"
	vim.wo[winnr].cursorline = true

	-- keymaps
	local function map(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, nowait = true }) end

	map("q", vim.cmd.bwipeout)
	map("<Esc>", vim.cmd.bwipeout)
	map(config.keymaps.next, "j")
	map(config.keymaps.prev, "p")
	map(config.keymaps.inspect, function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		local info = vim.inspect(items[lnum])
		vim.notify(info, vim.log.levels.DEBUG, { title = "Inspect item" })
	end)
	map(config.keymaps.confirm, function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		vim.cmd.bwipeout()
		on_choice(items[lnum], lnum)
	end)
end

--------------------------------------------------------------------------------
return M
