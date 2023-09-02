local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- lightbulb for available lsp actions
		"kosayoda/nvim-lightbulb",
		event = "LspAttach",
		keys = {
			{
				"<leader>C",
				"<cmd>lua require('nvim-lightbulb').debug()<CR>",
				desc = "󰒕 Code Action Info",
			},
		},
		opts = {
			-- -1 = updatetime set by myself
			autocmd = { enabled = true, updatetime = -1 },
			sign = { enabled = false },
			status_text = { enabled = true, text = " " },
			action_kinds = { "refactor" },
			ignore = {
				clients = {
					"lua_ls", -- spams parameter refactoring
					"marksman", -- spams ToC update everywhere
					"ruff_lsp", -- spams fixAll everywhere
				},
			},
		},
	},
	{ -- lsp definitions & references count in the status line
		"chrisgrieser/nvim-dr-lsp",
		event = "LspAttach",
		dev = true,
		config = function()
			u.addToLuaLine("section", "lualine_c", require("dr-lsp").lspProgress)

			u.addToLuaLine("section", "lualine_c", {
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
		init = function()
			vim.keymap.set("n", "^", function()
				if not require("nvim-navic").is_available() then
					vim.notify("Navic is not available.")
					return
				end
				local symbolPath = require("nvim-navic").get_data()
				if #symbolPath == 0 then return end
				local parent = #symbolPath > 1 and symbolPath[#symbolPath - 1] or symbolPath[1]
				local parentPos = parent.scope.start
				vim.api.nvim_win_set_cursor(0, { parentPos.line, parentPos.character })
			end, { desc = "󰒕 Go Up to Parent" })

			-- copy breadcrumbs
			vim.keymap.set("n", "<D-b>", function()
				local rawdata = require("nvim-navic").get_data()
				if not rawdata then
					vim.notify("No Breadcrumbs available", u.warn)
					return
				end
				local breadcrumbs = ""
				for _, v in pairs(rawdata) do
					breadcrumbs = breadcrumbs .. v.name .. "."
				end
				breadcrumbs = breadcrumbs:sub(1, -2)
				vim.fn.setreg("+", breadcrumbs)
				vim.notify("COPIED\n" .. breadcrumbs)
			end, { desc = "󰒕 Copy Breadcrumbs" })
		end,
		opts = {
			lsp = { auto_attach = true },
			icons = { Object = "󰆧 " },
			separator = "  ",
			depth_limit = 7,
			depth_limit_indicator = "…",
		},
	},
	{ -- signature hints
		"ray-x/lsp_signature.nvim",
		-- loading on `require` or InsertEnter ignores the config, so loading on LspAttach
		event = "LspAttach",
		opts = {
			floating_window = false,
			hint_prefix = "󰘎 ",
			hint_scheme = "NonText", -- = highlight group
		},
	},
	{ -- display inlay hints from LSP
		"lvimuser/lsp-inlayhints.nvim", -- INFO only temporarily needed, until https://github.com/neovim/neovim/issues/18086
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
					prefix = " ",
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
	{ -- better LSP variable-rename
		"smjonas/inc-rename.nvim",
		event = "CmdlineEnter", -- loading with `cmd = "IncRename` does not work with incremental preview
		opts = {
			post_hook = function(results)
				if not results.changes then return end

				-- if more than one file is changed, save all buffers
				local filesChang = #vim.tbl_keys(results.changes)
				if filesChang > 1 then vim.cmd.wall() end

				-- FIX making the cmdline-history not navigable, pending: https://github.com/smjonas/inc-rename.nvim/issues/40
				vim.fn.histdel("cmd", "^IncRename ")
			end,
		},
	},
}
