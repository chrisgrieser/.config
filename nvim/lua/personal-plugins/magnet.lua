--[[ INFO
Quickly jump to specific LSP symbols.

USAGE
- `require("magnet").jump()`
- Quick-select symbol via highlighted keys.
- Alternatively, move with `<Tab>` & `<S-Tab>` and select a symbol via `<CR>`.

REQUIREMENTS
- nvim 0.10+

CREDITS
Inspired by / similar to: https://github.com/kungfusheep/snipe-lsp.nvim
]]
------------------------------------------------------------------------------

local config = {
	kindFilter = {
		-- kind names: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
		default = { "Function", "Method", "Class", "Module" },

		-- filetype-specific kinds
		yaml = { "Object", "Array" },
		json = { "Module" },
		toml = { "Object" },
	},
	resultFilter = {
		default = {},

		-- filetype-specific list of lua patterns
		lua = { "^vim%." }, -- remove anonymous functions
	},
	win = {
		border = vim.g.borderStyle,
	},
	highlights = {
		hint = "Todo",
	},
	keymaps = {
		next = "<Tab>",
		prev = "<S-Tab>",
		select = "<CR>",
		closeWin = { "q", "<Esc>", "<D-w>" },
	},
}

--------------------------------------------------------------------------------

---@class (exact) Magnet.Symbol output of `vim.lsp.util.symbols_to_items`
---@field filename string
---@field text string
---@field col integer
---@field lnum integer
---@field kind string https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind

---@param symbol Magnet.Symbol
---@param winnr number
local function jumpToSymbol(symbol, winnr)
	vim.api.nvim_win_close(winnr, true)
	vim.cmd.normal { "m`", bang = true } -- set jump mark
	vim.api.nvim_win_set_cursor(0, { symbol.lnum, symbol.col - 1 })
end

---@param symbols Magnet.Symbol[]
local function selectSymbol(symbols)
	local names = vim.tbl_map(function(s) return s.text end, symbols)

	local ns = vim.api.nvim_create_namespace("magnet-window")
	local title = "Symbols"
	local longestName = math.max(unpack(vim.tbl_map(function(line) return #line end, names)))
	local width = math.max(longestName, vim.api.nvim_strwidth(title)) + 2 -- +2 for padding
	local winHeight = vim.api.nvim_win_get_height(0)
	local height = math.min(#symbols, winHeight)
	local originalFt = vim.bo.filetype

	-- create window
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, names)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "win",
		row = math.floor((winHeight - height) / 2),
		col = math.floor((vim.api.nvim_win_get_width(0) - width) / 2),
		width = width,
		height = height,
		title = " " .. title .. " ",
		border = config.win.border,
		style = "minimal",
	})
	vim.wo[winnr].winfixbuf = true
	vim.wo[winnr].cursorline = true
	vim.bo[bufnr].modifiable = false
	vim.bo[bufnr].filetype = originalFt

	-- keymaps
	local opts = { buffer = bufnr, nowait = true }
	local optsExpr = vim.tbl_extend("force", opts, { expr = true })
	for _, key in pairs(config.keymaps.closeWin) do
		vim.keymap.set("n", key, vim.cmd.close, opts)
	end
	vim.keymap.set("n", config.keymaps.next, "j", optsExpr)
	vim.keymap.set("n", config.keymaps.prev, "k", optsExpr)

	vim.keymap.set("n", config.keymaps.select, function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		jumpToSymbol(symbols[lnum], winnr)
	end, opts)

	-- quick-keys
	-- working with lower- and upper-case
	local usedKeys = {}
	for i = 1, #symbols do
		local lnum = i - 1

		local name = symbols[i].text
		local lastDotPod = name:find(".+%.")
		local col = lastDotPod and lastDotPod + 1 or 0

		local key
		repeat
			col = col + 1
			key = name:sub(col, col):lower()
			if key == "" then break end -- no more chars available
		until not vim.tbl_contains(usedKeys, key)
		if key ~= "" then
			table.insert(usedKeys, key)
			vim.api.nvim_buf_add_highlight(bufnr, ns, config.highlights.hint, lnum, col - 1, col)
			vim.keymap.set("n", key, function() jumpToSymbol(symbols[i], winnr) end, opts)
			vim.keymap.set("n", key:upper(), function() jumpToSymbol(symbols[i], winnr) end, opts)
		end
	end
end

---@param symbols Magnet.Symbol[]
---@return Magnet.Symbol[]
local function filterSymbols(symbols)
	local kindFilter = config.kindFilter[vim.bo.filetype] or config.kindFilter.default
	local resultFilter = config.resultFilter[vim.bo.filetype] or config.resultFilter.default

	local filteredSymbols = vim.iter(symbols)
		:filter(function(symbol)
			return vim.tbl_contains(kindFilter, symbol.kind)
		end)
		:totable()
	return filteredSymbols
end

---@async
local function getLspDocumentSymbols()
	local params = vim.lsp.util.make_position_params()
	vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(err, result, _, _)
		if err then
			local msg = "Error when finding document symbols: " .. err.message
			vim.notify(msg, vim.log.levels.WARN, { title = "Symbols" })
			return
		end

		if not result or #result == 0 then
			vim.notify("No results.", vim.log.levels.WARN, { title = "Symbols" })
			return
		end
		local items = vim.lsp.util.symbols_to_items(result or {}, 0) or {}

		local symbols = filterSymbols(items)
		if #symbols == 0 then
			vim.notify("Current `kindFilter` doesn't match any symbols.", nil, { title = "Symbols" })
			return
		end
		selectSymbol(symbols)
	end)
end

--------------------------------------------------------------------------------
local M = {}
function M.jump() getLspDocumentSymbols() end
return M
