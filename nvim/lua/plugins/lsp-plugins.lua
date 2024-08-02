local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- display type hints at eol, not in the middle of a line
		"chrisgrieser/nvim-lsp-endhints",
		event = "LspAttach",
		opts = true,
	},
	{ -- nvim lua typings
		"folke/lazydev.nvim",
		ft = "lua",
		opts = {
			library = {
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
			integrations = { cmp = false }, -- prevents loading cmp
		},
	},
	-- `vim.uv` typings (not as dependency, since it never needs to be loaded)
	{ "Bilal2453/luvit-meta", lazy = true },
	-----------------------------------------------------------------------------
	{ -- breadcrumbs for tabline
		"SmiteshP/nvim-navic",
		event = "LspAttach",
		opts = {
			lazy_update_context = false,
			lsp = {
				auto_attach = true,
				preference = { "basedpyright", "tsserver", "marksman", "cssls" },
			},
			icons = { Object = "⬟ " },
			separator = " ",
			depth_limit = 7,
			depth_limit_indicator = "…",
		},
		config = function(_, opts)
			vim.g.navic_silence = false
			require("nvim-navic").setup(opts)

			vim.g.lualine_add("tabline", "lualine_b", { "navic" })
		end,
		keys = {
			{ -- copy breadcrumbs
				"<D-b>",
				function()
					local rawdata = require("nvim-navic").get_data()
					if not rawdata then return end
					local breadcrumbs = ""
					for _, v in pairs(rawdata) do
						breadcrumbs = breadcrumbs .. v.name .. "."
					end
					breadcrumbs = breadcrumbs:sub(1, -2):gsub(".%[", "[")
					u.copyAndNotify(breadcrumbs)
				end,
				desc = "󰒕 Copy Breadcrumbs",
			},
			{ -- go up to parent
				"gk",
				function()
					local symbolPath = require("nvim-navic").get_data()
					if not symbolPath then return end
					local parent = symbolPath[#symbolPath - 1]
					if not parent then return end
					local pos = parent.scope.start
					vim.api.nvim_win_set_cursor(0, { pos.line, pos.character })
				end,
				desc = "󰒕 Go up to parent",
			},
		},
	},
	{ -- signature hints
		-- "ray-x/lsp_signature.nvim",
		"chrisgrieser/lsp_signature.nvim", -- PENDING https://github.com/ray-x/lsp_signature.nvim/pull/334
		branch = "patch-1",

		event = "BufReadPre",
		opts = {
			hint_prefix = " 󰏪 ",
			hint_scheme = "Todo", -- highlight group, alt: @variable.parameter
			floating_window = false,
			always_trigger = true,
		},
	},
	{ -- CodeLens, but also for languages not supporting it
		"Wansmer/symbol-usage.nvim",
		event = "LspAttach",
		opts = {
			request_pending_text = false, -- remove "loading…"
			references = { enabled = true, include_declaration = false },
			definition = { enabled = false },
			implementation = { enabled = false },
			vt_position = "signcolumn",
			vt_priority = 5, -- below the gitsigns default of 6
			hl = { link = "Comment" },
			text_format = function(symbol)
				if not symbol.references or symbol.references == 0 then return end
				if symbol.references < 2 and vim.bo.filetype == "css" then return end
				if symbol.references > 99 then return "" end

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
				vim.lsp.protocol.SymbolKind.Function,
				vim.lsp.protocol.SymbolKind.Method,
				vim.lsp.protocol.SymbolKind.Class,
				vim.lsp.protocol.SymbolKind.Interface,
				vim.lsp.protocol.SymbolKind.Constructor,
			},
		},
	},
	{ -- lsp definitions & references count in the status line
		"chrisgrieser/nvim-dr-lsp",
		event = "LspAttach",
		config = function()
			vim.opt.updatetime = 250 -- time for `CursorHold` event

			vim.g.lualine_add("sections", "lualine_c", {
				require("dr-lsp").lspCount,
				fmt = function(str) return str:gsub("R", ""):gsub("D", " 󰄾"):gsub("LSP:", "󰈿") end,
			})
		end,
	},
	{ -- add ignore-comments & lookup rules
		"chrisgrieser/nvim-rulebook",
		opts = {
			suppressFormatter = {
				-- use `biome` instead of `prettier`
				javascript = { location = "prevLine", ignoreBlock = "// biome-ignore format: expl" },
				typescript = { location = "prevLine", ignoreBlock = "// biome-ignore format: expl" },
				css = { location = "prevLine", ignoreBlock = "/* biome-ignore format: expl */" },
			},
		},
		keys = {
			-- stylua: ignore start
			{ "<leader>cl", function() require("rulebook").lookupRule() end, desc = " Lookup Rule" },
			{ "<leader>ci", function() require("rulebook").ignoreRule() end, desc = "󰅜 Ignore Rule" },
			{ "<leader>cy", function() require("rulebook").yankDiagnosticCode() end, desc = "󰅍 Yank Diagnostic Code" },
			{ "<leader>cf", function() require("rulebook").suppressFormatter() end, mode = { "n", "x" }, desc = "󰉿 Suppress Formatter" },
			-- stylua: ignore end
		},
	},
}
