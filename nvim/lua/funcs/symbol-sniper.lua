local M = {}
--------------------------------------------------------------------------------
local config = {
	win = {
		border = vim.g.borderStyle,
	},
	icons = {
		main = "󰒕",
	}
}
--------------------------------------------------------------------------------

---@param kindFilter? lsp.SymbolKind[]
---@return lsp.DocumentSymbol[]
local function getLspDocumentSymbols(kindFilter)
	local params = { textDocument = vim.lsp.util.make_text_document_params() }
	local symbols = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params, 1000)
	if not symbols or vim.tbl_isempty(symbols) then
		vim.notify("No symbols found", vim.log.levels.WARN, { title = "Symbols", icon = "⚠️" })
		return {}
	end
	---@type lsp.DocumentSymbol[]
	local items = {}
	for _, result in pairs(symbols) do
		for _, symbol in ipairs(result.result or {}) do
			table.insert(items, {
				name = symbol.name,
				kind = vim.lsp.protocol.SymbolKind[symbol.kind] or "Unknown",
				range = symbol.range,
			})
		end
	end
	return items
end

---@param symbols lsp.DocumentSymbol[]
local function createWin(symbols)
	vim.notify(--[[🖨️]] vim.inspect(symbols[1]), nil, { ft = "lua", title = "symbols 🖨️" })
	local content = vim.tbl_map(function(s) return ("%s %s"):format(s.kind, s.name) end, symbols)

	local width = 30
	local height = 5
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		title = "Symbols",
		border = config.win.border,
		style = "minimal",
	})
	vim.wo[winnr].winfixbuf = true
	vim.bo[bufnr].modifiable = false

	vim.keymap.set("n", "q", vim.cmd.close, { buffer = bufnr, nowait = true })
end

--------------------------------------------------------------------------------

function M.snipe()
	local symbols = getLspDocumentSymbols()
	createWin(symbols)
end

--------------------------------------------------------------------------------
return M
