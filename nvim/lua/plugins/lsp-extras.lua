local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- display inlay hints from LSP
		"lvimuser/lsp-inlayhints.nvim",
		init = function()
			if vim.version().major == 0 and vim.version().minor >= 10 then
				vim.notify("lsp-inlayhints.nvim is now obsolete.")
			end

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					local capabilities = client.server_capabilities
					if capabilities.inlayHintProvider then
						require("lsp-inlayhints").on_attach(client, bufnr, false)
					end
				end,
			})
		end,
		opts = {
			inlay_hints = {
				parameter_hints = {
					prefix = " 󰁍 ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
				type_hints = {
					prefix = " ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
				labels_separator = ":",
				only_current_line = true,
				highlight = "NonText",
			},
		},
	},
	{ -- virtual text showing usage count of functions
		"Wansmer/symbol-usage.nvim",
		event = "BufReadPre", -- TODO need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
		opts = {
			hl = { link = "NonText" },
			vt_position = "end_of_line",
			references = { enabled = true, include_declaration = false },
			definition = { enabled = false },
			implementation = { enabled = false },
			-- see `lsp.SymbolKind`
			kinds = { vim.lsp.protocol.SymbolKind.Function, vim.lsp.protocol.SymbolKind.Method },
			text_format = function(symbol) return " 󰈿 " .. symbol.references end,
		},
	},
	{ -- lsp definitions & references count in the status line
		"chrisgrieser/nvim-dr-lsp",
		event = "LspAttach",
		config = function()
			u.addToLuaLine("sections", "lualine_x", require("dr-lsp").lspProgress)
			u.addToLuaLine("sections", "lualine_c", {
				require("dr-lsp").lspCount,
				-- needs the highlight value, since setting the hlgroup directly
				-- results in bg color being inherited from main editor
				color = function() return { fg = u.getHighlightValue("Comment", "fg") } end,
				fmt = function(str) return str:gsub("R", ""):gsub("D", " 󰄾"):gsub("LSP:", "󰈿") end,
			})
		end,
	},
	{ -- breadcrumbs for winbar
		"SmiteshP/nvim-navic",
		event = "LspAttach", -- loading on `require` ignores the config, so loading on LspAttach
		keys = {
			{
				"<D-b>",
				function()
					local rawdata = require("nvim-navic").get_data()
					if not rawdata then
						u.notify("Navic", "No breadcrumbs available.")
						return
					end
					local breadcrumbs = ""
					for _, v in pairs(rawdata) do
						breadcrumbs = breadcrumbs .. v.name .. "."
					end
					breadcrumbs = breadcrumbs:sub(1, -2)
					vim.fn.setreg("+", breadcrumbs)
					u.notify("Copied", breadcrumbs)
				end,
				desc = "󰒕 Copy Breadcrumbs",
			},
		},
		opts = {
			lsp = {
				auto_attach = true,
				preference = { "pyright", "tsserver" },
			},
			icons = { Object = "󰆧 " },
			separator = "  ",
			depth_limit = 7,
			depth_limit_indicator = "…",
		},
	},
	{ -- signature hints
		"ray-x/lsp_signature.nvim",
		event = "BufReadPre", -- TODO need run before LspAttach if you use nvim 0.9. On 0.10 use 'LspAttach'
		opts = {
			floating_window = false,
			always_trigger = true,
			hint_prefix = "󰘎 ",
			hint_scheme = "NonText", -- = highlight group
		},
	},
	{ -- better LSP variable-rename
		"smjonas/inc-rename.nvim",
		event = "CmdlineEnter", -- loading with `cmd = "IncRename` does not work with incremental preview
		opts = {
			post_hook = function(results)
				if not results.changes then return end

				-- if more than one file is changed, save all buffers
				local filesChanged = #vim.tbl_keys(results.changes)
				if filesChanged > 1 then vim.cmd("silent wall") end

				-- FIX making the cmdline-history not navigable
				-- PENDING: https://github.com/smjonas/inc-rename.nvim/issues/40
				vim.fn.histdel("cmd", "^IncRename ")
			end,
		},
	},
}
