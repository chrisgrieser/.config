local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{
		"OlegGulevskyy/better-ts-errors.nvim",
		dependencies = "MunifTanjim/nui.nvim",
		ft = { "typescript", "javascript" },
		opts = {
			keymaps = {
				toggle = "<leader>ct",
				go_to_definition = "<leader>cd",
			},
		},
	},
	-- { -- nicher typescript errors
	-- 	"dmmulroy/ts-error-translator.nvim",
	-- 	ft = { "typescript", "javascript" },
	-- 	opts = true,
	-- },
	{ -- display inlay hints from LSP
		"lvimuser/lsp-inlayhints.nvim",
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
		opts = {
			inlay_hints = {
				labels_separator = "",
				only_current_line = false,
				-- highlight = "NonText",
				parameter_hints = {
					prefix = " 󰁍 ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
				type_hints = {
					-- prefix = " ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
			},
		},
	},
	{ -- CodeLens, but also for languages not supporting it
		"Wansmer/symbol-usage.nvim",
		event = "BufReadPre",
		opts = {
			hl = { link = "Comment" },
			vt_position = "end_of_line",
			request_pending_text = false, -- no "Loading…" PENDING https://github.com/Wansmer/symbol-usage.nvim/issues/24
			references = { enabled = true, include_declaration = false },
			definition = { enabled = false },
			implementation = { enabled = false },
			text_format = function(symbol)
				if symbol.references == 0 then return "" end
				return " 󰈿 " .. symbol.references
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
				vim.lsp.protocol.SymbolKind.Constructor,
				vim.lsp.protocol.SymbolKind.Method,
				vim.lsp.protocol.SymbolKind.Interface,
				vim.lsp.protocol.SymbolKind.Object,
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
			hint_inline = function() return vim.lsp.inlay_hint ~= nil end,
			floating_window = false,
			always_trigger = true,
			bind = true, -- This is mandatory, otherwise border config won't get registered.
			handler_opts = { border = vim.g.borderStyle },
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
			{
				"<leader>cy",
				function() require("rulebook").yankDiagnosticCode() end,
				desc = "󰅍 Yank Diagnostic Code",
			},
		},
	},
}
