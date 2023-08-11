local u = require("config.utils")

return {
	{ -- lsp definitions & references count in the status line
		"chrisgrieser/nvim-dr-lsp",
		lazy = true, -- loaded by lualine
		dev = true,
	},
	{ -- breadcrumbs for winbar
		"SmiteshP/nvim-navic",
		event = "LspAttach", -- loading on `require` ignores the config, so loading on LspAttach
		init = function()
			vim.g.navic_silence = true -- suppress notifications on errors
			vim.keymap.set("n", "gk", function()
				if not require("nvim-navic").is_available() then
					vim.notify("Navic is not available.")
					return
				end
				local symbolPath = require("nvim-navic").get_data()
				local parent = symbolPath[#symbolPath - 1]
				if not parent then
					vim.notify("Already at the highest parent.")
					return
				end
				local parentPos = parent.scope.start
				u.setCursor(0, { parentPos.line, parentPos.character })
			end, { desc = "󰒕 Go Up to Parent" })

			-- copy breadcrumbs (nvim navic)
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
		lazy = true, -- required in attach function
		init = function()
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
					show = true,
					prefix = "󰁍 ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
				type_hints = {
					show = true,
					prefix = "   ",
					remove_colon_start = true,
					remove_colon_end = true,
				},
				only_current_line = true,
				highlight = "NonText", -- highlight group
			},
		},
	},
	{ -- better LSP variable-rename
		"smjonas/inc-rename.nvim",
		event = "CmdlineEnter", -- loading with `cmd = "IncRename` does not work with incremental preview
		opts = {
			-- if more than one file is changed, save all buffers
			post_hook = function(results)
				local filesChanged = #vim.tbl_keys(results.changes)
				if filesChanged > 1 then vim.cmd.wall() end
			end,
		},
	},
}
