local u = require("config.utils")
local kind = vim.lsp.protocol.SymbolKind
--------------------------------------------------------------------------------

return {
	{ -- virtual text showing usage count of functions
		"Wansmer/symbol-usage.nvim",
		event = (vim.fn.has("nvim-0.10.0") == 1 and "LspAttach" or "BufReadPre"), -- TODO
		opts = {
			hl = { link = "NonText" },
			vt_position = "end_of_line",
			request_pending_text = false, -- no "Loading…" PENDING https://github.com/Wansmer/symbol-usage.nvim/issues/24
			references = { enabled = true, include_declaration = false },
			definition = { enabled = false },
			implementation = { enabled = false },
			-- available symbolkinds: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
			kinds = { kind.Function, kind.Method, kind.Object },
			text_format = function(symbol)
				if symbol.references == 0 then return "" end
				return " 󰈿 " .. symbol.references
			end,
		},
	},
	{ -- lsp definitions & references count in the status line
		"chrisgrieser/nvim-dr-lsp",
		event = "LspAttach",
		config = function()
			u.addToLuaLine("sections", "lualine_x", require("dr-lsp").lspProgress)
			u.addToLuaLine("sections", "lualine_c", {
				require("dr-lsp").lspCount,
				fmt = function(str) return str:gsub("R", ""):gsub("D", " 󰄾"):gsub("LSP:", "󰈿") end,
			})
		end,
	},
	{ -- signature hints
		"ray-x/lsp_signature.nvim",
		event = (vim.fn.has("nvim-0.10.0") == 1 and "LspAttach" or "BufReadPre"),
		dependencies = "folke/noice.nvim",
		opts = {
			noice = true, -- render via noice.nvim
			hint_prefix = "󰏪 ",
			hint_scheme = "@parameter", -- highlight group
			hint_inline = function() return vim.lsp.inlay_hint ~= nil end,
			floating_window = false,
			always_trigger = true,
		},
	},
	{ -- add ignore-comments & lookup rules
		"chrisgrieser/nvim-rulebook",
		keys = {
			{
				"<leader>cl",
				function() require("rulebook").lookupRule() end,
				desc = " Lookup Rule",
			},
			{
				"<leader>cg",
				function() require("rulebook").ignoreRule() end,
				desc = "󰅜 Ignore Rule",
			},
		},
	},
}
