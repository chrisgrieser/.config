local M = {}
--------------------------------------------------------------------------------
local config = {
	---@type string[] -- kind names: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
	kindFilter = { "Function", "Method" },
	win = {
		border = vim.g.borderStyle,
	},
	kindIcons = {
		Function = "󰊕",
		Method = "󰡱",
		Struct = "󰙅",
		Class = "󰜁",
		Variable = "󰀫",
		Interface = "",
		Module = "",
	},
}
--------------------------------------------------------------------------------

---@class (exact) SniperSymbol
---@field name string
---@field icon string
---@field range lsp.Range
---@field kindName string kind names: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind

---@return SniperSymbol[]?
local function getLspDocumentSymbols()
	local params = { textDocument = vim.lsp.util.make_text_document_params() }
	local response = vim.lsp.buf_request_sync(0, "textDocument/documentSymbol", params)
	if not response or not response[1] or not response[1].result then
		vim.notify("No symbols found.", vim.log.levels.WARN, { title = "Symbols" })
		return
	end

	---@type SniperSymbol[]
	local symbols = vim.iter(response[1].result):fold({}, function(acc, item)
		local kindName = vim.lsp.protocol.SymbolKind[item.kind] or "Unknown"
		if not vim.tbl_contains(config.kindFilter, kindName) then return acc end
		table.insert(acc, {
			name = item.name,
			icon = config.kindIcons[kindName] or "*",
			kindName = kindName,
			range = item.range,
		})
		return acc
	end)
	if #symbols == 0 then
		vim.notify("Current `kindFilter` doesn't match any symbols.", nil, { title = "Symbols" })
		return
	end
	return symbols
end

---@param symbols SniperSymbol[]
local function createWin(symbols)
	local ns = vim.api.nvim_create_namespace("symbol-sniper")
	local names = vim.tbl_map(function(s) return s.name end, symbols)
	local width = math.max(unpack(vim.tbl_map(function(line) return #line end, names))) + 2
	local height = #symbols
	local title = "Symbols"
	local originalFt = vim.bo.filetype

	-- create win
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, names)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - height) / 2),
		col = math.floor((vim.o.columns - width) / 2),
		width = width,
		height = height,
		title = " " .. title .. " ",
		border = config.win.border,
		style = "minimal",
	})
	vim.wo[winnr].winfixbuf = true
	vim.bo[bufnr].modifiable = false
	vim.bo[bufnr].filetype = originalFt

	-- highlights
	for i = 1, #symbols do
		local hlGroup = symbols[i].kindName
		vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
			virt_text = { { symbols[i].icon .. " ", hlGroup } },
			virt_text_pos = "inline",
		})
	end

	-- keymaps
	vim.keymap.set("n", "q", vim.cmd.close, { buffer = bufnr, nowait = true })
	vim.keymap.set("n", "<Esc>", vim.cmd.close, { buffer = bufnr, nowait = true })
end

--------------------------------------------------------------------------------

function M.snipe()
	local symbols = getLspDocumentSymbols()
	if not symbols then return end
	createWin(symbols)
end

--------------------------------------------------------------------------------
return M
