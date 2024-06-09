local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	-- -- PENDING https://github.com/folke/lazydev.nvim/issues/29
	-- { -- nvim lua typings
	-- 	"folke/lazydev.nvim",
	-- 	ft = "lua",
	-- 	opts = { library = { "luvit-meta/library" } },
	-- },
	-- -- `vim.uv` typings (not as dependency, since they never need to be loaded)
	-- { "Bilal2453/luvit-meta", lazy = true },
	-----------------------------------------------------------------------------
	{ -- breadcrumbs for tabline
		"SmiteshP/nvim-navic",
		event = "LspAttach",
		init = function()
			vim.g.navic_silence = false
			local component = { "navic", section_separators = { left = "▒░", right = "" } }
			u.addToLuaLine("tabline", "lualine_b", component)
		end,
		opts = {
			lazy_update_context = true,
			lsp = {
				auto_attach = true,
				preference = { "basedpyright", "tsserver", "marksman", "cssls" },
			},
			icons = { Object = "󰠲 " },
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
			{
				"<D-g>",
				function() require("lsp_signature").toggle_float_win() end,
				mode = { "n", "v", "i" },
				desc = "󰒕 LSP signature",
			},
		},
		opts = {
			hint_prefix = "󰏪 ",
			hint_scheme = "@variable.parameter", -- highlight group
			floating_window = false,
			always_trigger = true,
			handler_opts = { border = vim.g.borderStyle },
			auto_close_after = 3000,
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
					prefix = " 󰏪 ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
				type_hints = {
					prefix = " 󰜁 ",
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
					if not client then return end
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
			implementation = { enabled = false },
			text_format = function(symbol)
				if not (symbol.references and symbol.references > 0) then return "" end
				return (" 󰈿 %s "):format(symbol.references)
			end,
			disable = {
				filetypes = { "css", "scss" },
			},
			-- available kinds: https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
			kinds = {
				vim.lsp.protocol.SymbolKind.Module,
				vim.lsp.protocol.SymbolKind.Package,
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
			u.addToLuaLine("sections", "lualine_c", {
				require("dr-lsp").lspCount,
				fmt = function(str) return str:gsub("R", ""):gsub("D", " 󰄾"):gsub("LSP:", "󰈿") end,
			})
			u.addToLuaLine("sections", "lualine_x", require("dr-lsp").lspProgress)
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
