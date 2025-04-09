return {
	"Wansmer/symbol-usage.nvim",
	event = "LspAttach",
	opts = {
		references = { enabled = true, include_declaration = false },
		definition = { enabled = false },
		implementation = { enabled = false },
		vt_position = "signcolumn",
		vt_priority = 5, -- gitsigns have 6, below so gitsigns are not broken up
		hl = { link = "Comment" },
		request_pending_text = false, -- disable "loading…"
		text_format = function(symbol)
			if not symbol.references or symbol.references == 0 then return end
			if symbol.references < 2 and vim.bo.filetype == "css" then return end
			if symbol.references > 99 then return "󰐗" end

			local digits =
				{ "󰎡", "󰎤", "󰎧", "󰎪", "󰎭", "󰎱", "󰎳", "󰎶", "󰎹", "󰎼" }

				-- stylua: ignore
				return tostring(symbol.references):gsub("%d", function(d) return digits[tonumber(d) + 1] end)
		end,
		-- available kinds: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
		kinds = {
			vim.lsp.protocol.SymbolKind.File,
			vim.lsp.protocol.SymbolKind.Module,
			vim.lsp.protocol.SymbolKind.Function,
			vim.lsp.protocol.SymbolKind.Method,
			vim.lsp.protocol.SymbolKind.Class,
			vim.lsp.protocol.SymbolKind.Interface,
			vim.lsp.protocol.SymbolKind.Object,
			vim.lsp.protocol.SymbolKind.Array,

			vim.lsp.protocol.SymbolKind.Property,
			vim.lsp.protocol.SymbolKind.Key,
		},
	},
}
