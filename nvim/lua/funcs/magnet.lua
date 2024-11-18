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
}
--------------------------------------------------------------------------------

---@class (exact) Magnet.Symbol
---@field name string
---@field range lsp.Range
---@field kindName string https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind

---@return Magnet.Symbol[]?
local function getLspDocumentSymbols()
	local params = { textDocument = vim.lsp.util.make_text_document_params() }
	local response = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params)
	if not response or not response[1] or not response[1].result then
		vim.notify("No symbols found.", vim.log.levels.WARN, { title = "Symbols" })
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
local function selectSymbol(symbol)
	vim.notify(--[[🖨️]] vim.inspect(symbol), nil, { ft = "lua", title = "symbol 🖨️" })
end

---@param symbols Magnet.Symbol[]
local function createWin(symbols)
	-- add space for padding
	local names = vim.tbl_map(function(s) return " " .. s.name end, symbols)

	local ns = vim.api.nvim_create_namespace("symbol-sniper")
	local width = math.max(unpack(vim.tbl_map(function(line) return #line end, names))) + 2
	local height = #symbols
	local title = "Symbols"

	-- create window
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, names)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "win",
		row = math.floor((vim.api.nvim_win_get_height(0) - height) / 2),
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
	vim.keymap.set("n", "q", vim.cmd.close, opts)
	vim.keymap.set("n", "<Esc>", vim.cmd.close, opts)
	vim.keymap.set("n", "<CR>", function ()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		selectSymbol(symbols[lnum])
	end, opts)

	-- quick-keys
	local usedKeys = {}
	for i = 1, #symbols do
		local lnum = i - 1
		local charPos = 0
		local key
		repeat
			charPos = charPos + 1
			key = symbols[i].name:sub(charPos, charPos):lower()
			if key == "" then break end -- no more chars available
		until not vim.tbl_contains(usedKeys, key)
		if key ~= "" then
			table.insert(usedKeys, key)
			local col = charPos + 1 -- space-padding in window
			vim.api.nvim_buf_add_highlight(bufnr, ns, config.highlights.hint, lnum, col - 1, col)
			vim.keymap.set("n", key, function() selectSymbol(symbols[i]) end, opts)
		end
	end
end

--------------------------------------------------------------------------------

function M.snipe()
	local symbols = getLspDocumentSymbols()
	if not symbols then return end
	createWin(symbols)
end

--------------------------------------------------------------------------------
return M
