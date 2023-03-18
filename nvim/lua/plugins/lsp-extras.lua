vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local capabilities = client.server_capabilities

		-- navic not that useful for css
		if capabilities.documentSymbolProvider and client.name ~= "cssls" then
			require("nvim-navic").attach(client, bufnr)
		end

		if capabilities.inlayHintProvider then require("lsp-inlayhints").on_attach(client, bufnr) end
	end,
})

--------------------------------------------------------------------------------

return {
	{ -- breadcrumbs for statusline/winbar
		"SmiteshP/nvim-navic",
		event = "LspAttach", -- loading on `require` ignores the config, so loading on LspAttach
		config = function()
			require("nvim-navic").setup {
				icons = { Object = " " },
				separator = "  ",
				depth_limit = 8,
				depth_limit_indicator = "…",
			}
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "LspAttach",
		config = function()
			require("lsp_signature").setup {
				floating_window = false,
				hint_prefix = "﬍ ",
				hint_scheme = "NonText", -- highlight group
			}
		end,
	},
	{
		-- INFO only temporarily needed, until https://github.com/neovim/neovim/issues/18086
		"lvimuser/lsp-inlayhints.nvim",
		lazy = true, -- loaded when required in attach function
		config = function()
			require("lsp-inlayhints").setup {
				inlay_hints = {
					parameter_hints = {
						show = true,
						prefix = " ",
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
			}
		end,
	},
	{
		"smjonas/inc-rename.nvim",
		event = "LspAttach",
		config = function()
			require("inc_rename").setup {
				post_hook = function(results)
					-- if more than one file is changed, save all
					local filesChanged = #vim.tbl_keys(results.changes)
					if filesChanged > 1 then vim.cmd.wall() end
				end,
			}
		end,
	},
}
