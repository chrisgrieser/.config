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
		inspect = "?", -- selection kind & item under cursor
	},
	telescopeFallback = {
		ifKindMatchesPattern = { "^tinygit" }, ---@type string[] -- checked via string.find
		ifMoreItemsThan = 10,
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

local function telescopeFallback(_items, _opts, _on_choice)
	local installed, telescope = pcall(require, "telescope")
	if not installed then
		vim.notify("telescope.nvim is not installed.", vim.log.levels.WARN)
		return
	end
	-- TODO
	vim.notify("Not implemented yet.", vim.log.levels.WARN)
end

--------------------------------------------------------------------------------

---@param items any[]
---@param opts SelectorOpts
---@param on_choice fun(item: any?, idx: integer?)
function M.modifiedUiSelect(items, opts, on_choice)
	-- GUARD
	assert(on_choice, "`on_choice` must be a function.")
	if #items == 0 then
		vim.notify("No items to select from.", vim.log.levels.WARN)
		return
	end

	-- REDIRECT TO FALLBACK
	local defaultOpts = { format_item = function(i) return i end }
	opts = vim.tbl_deep_extend("force", defaultOpts, opts) ---@type SelectorOpts
	local fallbackKind = vim.iter(config.telescopeFallback.ifKindMatchesPattern)
		:any(function(p) return (opts.kind and opts.kind:find(p)) ~= nil end)
	local fallbackMore = #items > config.telescopeFallback.ifMoreItemsThan
	if fallbackKind or fallbackMore then
		telescopeFallback(items, opts, on_choice)
		return
	end

	-- PARAMETERS
	local title = opts.prompt and (" " .. opts.prompt:gsub(":%s*$", "") .. " ") or nil
	local choices = vim.tbl_map(opts.format_item, items)
	assert(type(choices[1]) == "string", "`format_item` must return a string.")
	local longestChoice = vim.iter(choices):fold(0, function(acc, c) return math.max(acc, #c) end)
	local width = math.max(longestChoice, #(title or "")) + 2
	local height = #choices
	local footer = opts.footer and (" " .. opts.footer .. " ") or nil

	-- CREATE WINDOW
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, choices)
	local winid = vim.api.nvim_open_win(bufnr, true, {
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
	vim.wo[winid].statuscolumn = " " -- = left-padding
	vim.wo[winid].cursorline = true
	vim.wo[winid].colorcolumn = ""
	vim.wo[winid].winfixbuf = true
	vim.bo[bufnr].modifiable = false
	vim.bo[bufnr].filetype = opts.ft or config.win.ft

	-- KEYMAPS
	local function map(lhs, rhs) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, nowait = true }) end
	for _, key in ipairs(config.keymaps.abort) do
		map(key, vim.cmd.bwipeout)
	end
	map(config.keymaps.next, "j")
	map(config.keymaps.prev, "k")
	map(config.keymaps.inspect, function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		local out = "kind = " .. opts.kind .. "\n" ..
		vim.inspect { kind = opts.kind, item = items[lnum] }
		vim.notify(out, vim.log.levels.DEBUG, { title = "Inspect", ft = "lua" })
	end)
	map(config.keymaps.confirm, function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		vim.cmd.bwipeout()
		on_choice(items[lnum], lnum)
	end)

	-- UNMOUNT
	vim.api.nvim_create_autocmd("WinLeave", {
		desc = "Selector: Close window",
		once = true,
		callback = function()
			local curWin = vim.api.nvim_get_current_win()
			if curWin == winid then vim.api.nvim_buf_delete(bufnr, { force = true }) end
		end,
	})
end

local _originalVimUiSelect = vim.ui.select
vim.ui.select = M.modifiedUiSelect

--------------------------------------------------------------------------------
return M
