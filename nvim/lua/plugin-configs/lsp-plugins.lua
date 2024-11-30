return {
	{ -- display type hints at EoL, not in the middle of a line
		"chrisgrieser/nvim-lsp-endhints",
		event = "LspAttach",
		opts = {},
		keys = {
			{ "<leader>oh", function() require("lsp-endhints").toggle() end, desc = "󰑀 Endhints" },
		},
	},
	-----------------------------------------------------------------------------
	{ -- nvim lua typings
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },

				-- global debugging function `Chainsaw`
				{ path = "nvim-chainsaw/lua/chainsaw/nvim-debug.lua", words = { "Chainsaw" } },
				{
					path = vim.g.localRepos .. "/nvim-chainsaw/lua/chainsaw/nvim-debug.lua",
					words = { "Chainsaw" },
				},
			},
		},
	},
	-----------------------------------------------------------------------------
	{ -- signature hints
		"ray-x/lsp_signature.nvim",
		event = "BufReadPre",
		opts = {
			hint_prefix = " 󰏪 ",
			hint_scheme = "Todo",
			floating_window = false,
			always_trigger = true,
		},
	},
	{ -- CodeLens
		"Wansmer/symbol-usage.nvim",
		event = "LspAttach",
		opts = {
			request_pending_text = false, -- remove "loading…"
			references = { enabled = true, include_declaration = false },
			definition = { enabled = false },
			implementation = { enabled = false },
			vt_position = "signcolumn",
			vt_priority = 7, -- gitsigns have priority of 6
			hl = { link = "Comment" },
			text_format = function(symbol)
				if not symbol.references or symbol.references == 0 then return end
				if symbol.references < 2 and vim.bo.filetype == "css" then return end
				if symbol.references > 99 then return "󰐗" end

				local refs = tostring(symbol.references)
				local altDigits =
					{ "󰎡", "󰎤", "󰎧", "󰎪", "󰎭", "󰎱", "󰎳", "󰎶", "󰎹", "󰎼" }
				for i = 0, #altDigits - 1 do
					refs = refs:gsub(tostring(i), altDigits[i + 1])
				end
				return refs
			end,
			-- available kinds: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
			kinds = {
				vim.lsp.protocol.SymbolKind.File,
				vim.lsp.protocol.SymbolKind.Function,
				vim.lsp.protocol.SymbolKind.Method,
				vim.lsp.protocol.SymbolKind.Class,
				vim.lsp.protocol.SymbolKind.Interface,
				vim.lsp.protocol.SymbolKind.Object,
				vim.lsp.protocol.SymbolKind.Array,
				vim.lsp.protocol.SymbolKind.Property,
			},
		},
	},
	{ -- add ignore-comments & lookup rules
		"chrisgrieser/nvim-rulebook",
		keys = {
			-- stylua: ignore start
			{ "<leader>cl", function() require("rulebook").lookupRule() end, desc = " Lookup Rule" },
			{ "<leader>cg", function() require("rulebook").ignoreRule() end, desc = "󰅜 I[g]nore Rule" },
			{ "<leader>cy", function() require("rulebook").yankDiagnosticCode() end, desc = "󰅍 Yank Diagnostic Code" },
			{ "<leader>cf", function() require("rulebook").suppressFormatter() end, mode = { "n", "x" }, desc = "󰉿 Suppress Formatter" },
			-- stylua: ignore end
		},
		opts = {
			suppressFormatter = {
				-- use `biome` instead of `prettier`
				javascript = { location = "prevLine", ignoreBlock = "// biome-ignore format: expl" },
				typescript = { location = "prevLine", ignoreBlock = "// biome-ignore format: expl" },
				css = { location = "prevLine", ignoreBlock = "/* biome-ignore format: expl */" },
			},
		},
	},
}
