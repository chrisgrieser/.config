local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- breadcrumbs for tabline
		"SmiteshP/nvim-navic",
		event = "LspAttach",
		init = function()
			u.addToLuaLine(
				"tabline",
				"lualine_b",
				{ "navic", section_separators = { left = "▒░", right = "" } }
			)

			vim.g.navic_silence = false
		end,
		opts = {
			lazy_update_context = true,
			lsp = {
				auto_attach = true,
				preference = { "based_pyright", "tsserver" },
			},
			icons = { Object = "󰆧 " },
			separator = "  ",
			depth_limit = 7,
			depth_limit_indicator = "…",
		},
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
					vim.fn.setreg("+", breadcrumbs)
					u.notify("Copied", breadcrumbs)
				end,
				desc = "󰒕 Copy Breadcrumbs",
			},
			{ -- go up to parent
				"gk",
				function()
					if not require("nvim-navic").is_available() then return end
					local symbolPath = require("nvim-navic").get_data()
					local parent = symbolPath[#symbolPath - 1]
					if not parent then
						vim.notify("Already at the highest parent.")
						return
					end
					local pos = parent.scope.start
					vim.api.nvim_win_set_cursor(0, { pos.line, pos.character })
				end,
				desc = "󰒕 Go Up to Parent",
			},
		},
	},
	{ -- signature hints
		"ray-x/lsp_signature.nvim",
		event = "BufReadPre",
		keys = {
			{ -- better signature view
				"<D-g>",
				function() require("lsp_signature").toggle_float_win() end,
				mode = { "i", "n", "v" },
				desc = "󰏪 LSP Signature",
			},
		},
		dependencies = "folke/noice.nvim",
		opts = {
			noice = true, -- render via noice.nvim
			hint_prefix = "󰏪 ",
			hint_scheme = "@variable.parameter", -- highlight group
			floating_window = false,
			always_trigger = true,
			bind = true, -- This is mandatory, otherwise border config won't get registered.
			handler_opts = { border = vim.g.borderStyle },
		},
	},
	{ -- display inlay hints from at EoL, not in the text
		"lvimuser/lsp-inlayhints.nvim",
		keys = {
			{
				"<leader>oh",
				function() require("lsp-inlayhints").toggle() end,
				desc = "󰒕 Inlay Hints",
			},
		},
		opts = {
			inlay_hints = {
				labels_separator = "",
				parameter_hints = {
					prefix = " 󰁍 ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
				type_hints = {
					remove_colon_start = true,
					remove_colon_end = true,
				},
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					if not (args.data and args.data.client_id) then return end
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					require("lsp-inlayhints").on_attach(client, bufnr)
				end,
			})
		end,
	},
	{ -- CodeLens, but also for languages not supporting it
		"Wansmer/symbol-usage.nvim",
		event = "LspAttach",
		opts = {
			request_pending_text = false, -- remove "loading…"
			hl = { link = "Comment" },
			vt_position = "end_of_line",
			references = { enabled = true, include_declaration = false },
			definition = { enabled = false },
			implementation = { enabled = true },
			text_format = function(symbol)
				if not (symbol.references and symbol.references > 0) then return "" end
				return (" 󰈿 %s"):format(symbol.references)
			end,
			disable = {
				filetypes = { "css", "scss" },
			},
			-- available kinds: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
			kinds = {
				vim.lsp.protocol.SymbolKind.Module,
				vim.lsp.protocol.SymbolKind.Package,
				vim.lsp.protocol.SymbolKind.Function,
				vim.lsp.protocol.SymbolKind.Class,
				vim.lsp.protocol.SymbolKind.Interface,
				vim.lsp.protocol.SymbolKind.Constructor,
				vim.lsp.protocol.SymbolKind.Method,
				vim.lsp.protocol.SymbolKind.Interface,
				vim.lsp.protocol.SymbolKind.Object,
				vim.lsp.protocol.SymbolKind.Array,
				vim.lsp.protocol.SymbolKind.Key,
				vim.lsp.protocol.SymbolKind.Constant,
				vim.lsp.protocol.SymbolKind.Variable,
			},
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
	{ -- add ignore-comments & lookup rules
		"chrisgrieser/nvim-rulebook",
		keys = {
			{
				"<leader>cl",
				function() require("rulebook").lookupRule() end,
				desc = " Lookup Rule",
			},
			{
				"<leader>ci",
				function() require("rulebook").ignoreRule() end,
				desc = "󰅜 Ignore Rule",
			},
			{
				"<leader>cy",
				function() require("rulebook").yankDiagnosticCode() end,
				desc = "󰅍 Yank Diagnostic Code",
			},
		},
	},
}
