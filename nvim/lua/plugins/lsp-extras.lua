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
		opts = {
			icons = { Object = "󰆧 " },
			separator = "  ",
			depth_limit = 8,
			depth_limit_indicator = "…",
		},
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
		event = "LspAttach",
		opts = {
			post_hook = function(results)
				-- if more than one file is changed, save all buffers
				local filesChanged = #vim.tbl_keys(results.changes)
				if filesChanged > 1 then vim.cmd.wall() end
			end,
		},
	},
}
