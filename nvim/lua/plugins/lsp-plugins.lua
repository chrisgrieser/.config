local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- breadcrumbs for tabline
		"SmiteshP/nvim-navic",
		event = "LspAttach",
		init = function()
			vim.g.navic_silence = false
			u.addToLuaLine("tabline", "lualine_b", {
				"navic",
				section_separators = { left = "▒░", right = "" },
				cond = function() return vim.fn.mode():find("i") == nil end,
			})
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
		"ray-x/lsp_signature.nvim",
		event = "BufReadPre",
		keys = {
			-- stylua: ignore
			{ "<D-g>", function() require("lsp_signature").toggle_key() end, desc = "󰒕 LSP signature" },
		},
		opts = {
			hint_prefix = "󰏪 ",
			hint_scheme = "@variable.parameter", -- highlight group
			floating_window = false,
			always_trigger = true,
			auto_close_after = 3000,
			bind = true, -- needed for border config
			handler_opts = { border = vim.g.borderStyle },
		},
		config = function(_, opts)
			require("lsp_signature").setup(opts)
			u.addToLuaLine("tabline", "lualine_b", {
				function()
					local sig = require("lsp_signature").status_line(200)
					local start = sig.range.start
					local stop = sig.range["end"]
					local label = sig.label:sub(1, start - 1)
						.. sig.label:sub(start, stop):upper()
						.. sig.label:sub(stop + 1, -1)
					return opts.hint_prefix .. label
				end,
				cond = function() return vim.fn.mode():find("i") ~= nil end,
			})
		end,
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
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					require("lsp-inlayhints").on_attach(client, args.buf)
				end,
			})
		end,
	},
	{ -- CodeLens, but also for languages not supporting it
		"Wansmer/symbol-usage.nvim",
		event = "LspAttach",
		opts = {
			request_pending_text = false, -- remove "loading…"
			hl = { link = "LspInlayHint" },
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
				vim.lsp.protocol.SymbolKind.Object,
				vim.lsp.protocol.SymbolKind.Array,
			},
		},
	},
	{ -- lsp definitions & references count in the status line
		"chrisgrieser/nvim-dr-lsp",
		event = "LspAttach",
		config = function()
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
