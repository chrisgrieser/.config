vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local capabilities = client.server_capabilities

		-- navic not that useful for css
		if capabilities.documentSymbolProvider and client.name ~= "cssls" then
			require("nvim-navic").attach(client, bufnr)
		end

		if capabilities.inlayHintProvider then
			require("lsp-inlayhints").on_attach(client, bufnr, false)
		end
	end,
})

--------------------------------------------------------------------------------

return {
	{ -- breadcrumbs for winbar
		"SmiteshP/nvim-navic",
		event = "LspAttach", -- loading on `require` ignores the config, so loading on LspAttach
		init = function() vim.g.navic_silence = true end, -- suppress notifications on errors
		opts = {
			icons = { Object = "󰆧 " },
			separator = "  ",
			depth_limit = 7,
			depth_limit_indicator = "…",
		},
	},
	{ -- better virtualtext diagnostics
		"https://git.sr.ht/~whynothugo/lsp_lines.nvim",
		config = true,
		lazy = true, -- loaded by keymaps
		-- off at start
		init = function() vim.diagnostic.config { virtual_lines = false } end,
	},
	{ -- better references/definitions
		"dnlhc/glance.nvim",
		cmd = "Glance",
		opts = {
			height = 20,
			border = {
				enable = true,
				top_char = BorderHorizontal,
				bottom_char = BorderHorizontal,
			},
			list = { width = 0.35 },
			hooks = {
				-- jump directly to definition if there is only one https://github.com/dnlhc/glance.nvim#before_open
				before_open = function(results, open, jump)
					if #results == 1 then
						jump()
					else
						open()
					end
				end,
			},
		},
	},
	{ -- signature hints
		"ray-x/lsp_signature.nvim",
		event = "LspAttach", -- loading on `require` ignores the config, so loading on LspAttach
		opts = {
			floating_window = false,
			hint_prefix = "󰘎 ",
			hint_scheme = "NonText", -- highlight group
		},
	},
	{ -- display inlay hints from LSP
		"lvimuser/lsp-inlayhints.nvim", -- INFO only temporarily needed, until https://github.com/neovim/neovim/issues/18086
		lazy = true, -- required in attach function
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
	{ -- better LSP rename
		"smjonas/inc-rename.nvim",
		event = "LspAttach", -- loading on `:IncRename` would disable preview on first run
		opts = {
			-- if more than one file is changed, save all buffers
			post_hook = function(results)
				local filesChanged = #vim.tbl_keys(results.changes)
				if filesChanged > 1 then vim.cmd.wall() end
			end,
		},
	},
}
