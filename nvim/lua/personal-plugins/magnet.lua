local M = {}
--------------------------------------------------------------------------------
local config = {
	---@type string[] -- kind names: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
	kindFilter = { "Function", "Method" },
	win = {
		border = vim.g.borderStyle,
	},
	highlights = {
		hint = "CursorLineNr",
	},
	keymaps = {
		next = "<Tab>",
		prev = "<S-Tab>",
		closeWin = { "q", "<Esc>", "<D-w>" },
		select = "<CR>",
	},
}
--------------------------------------------------------------------------------

---@class (exact) Magnet.Symbol
---@field name string
---@field range lsp.Range
---@field kindName string https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind

---@return Magnet.Symbol[]?
local function getLspDocumentSymbols()
	local params = { textDocument = vim.lsp.util.make_text_document_params() }
	local response, err = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params)
	if not response or not response[1] or not response[1].result then
		local msg = vim.trim("No symbols found\n" .. (err or ""))
		vim.notify(msg, vim.log.levels.WARN, { title = "Symbols" })
		return
	end

	---@type Magnet.Symbol[]
	local symbols = vim.iter(response[1].result):fold({}, function(acc, item)
		local kindName = vim.lsp.protocol.SymbolKind[item.kind] or "Unknown"
		if not vim.tbl_contains(config.kindFilter, kindName) then return acc end
		table.insert(acc, { name = item.name, kindName = kindName, range = item.range })
		return acc
	end)
	if #symbols == 0 then
		vim.notify("Current `kindFilter` doesn't match any symbols.", nil, { title = "Symbols" })
		return
	end
	return symbols
end

---@param symbol Magnet.Symbol
---@param winnr number
local function jumpToSymbol(symbol, winnr)
	vim.api.nvim_win_close(winnr, true)
	local params = { range = symbol.range, uri = vim.uri_from_bufnr(0) }
	vim.lsp.util.jump_to_location(params, "utf-16", true)
end

---@param symbols Magnet.Symbol[]
local function selectSymbol(symbols)
	local names = vim.tbl_map(function(s) return s.name end, symbols)

	local ns = vim.api.nvim_create_namespace("symbol-sniper")
	local width = math.max(unpack(vim.tbl_map(function(line) return #line end, names))) + 2
	local winHeight = vim.api.nvim_win_get_height(0)
	local height = math.min(#symbols, winHeight)
	local title = "Symbols"

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
		local col = 0
		local key
		repeat
			col = col + 1
			key = symbols[i].name:sub(col, col):lower()
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

--------------------------------------------------------------------------------

function M.snipe()
	local symbols = getLspDocumentSymbols()
	if not symbols then return end
	selectSymbol(symbols)
end

--------------------------------------------------------------------------------
return M
