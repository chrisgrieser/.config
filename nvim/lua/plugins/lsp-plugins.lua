-- INFO by lazyloading all this plugins and only setting up / attaching them in
-- the lspAttach autocmd, they are only loaded when an LSP server with the
-- supporting capatibility is loaded, maximing the amount of lazyloading
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local capabilities = client.server_capabilities

		-- stylua: ignore start
		if capabilities.inlayHintProvider then
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
			require("lsp-inlayhints").on_attach(client, bufnr)
		end
		if capabilities.documentSymbolProvider and client.name ~= "cssls" then
			require("nvim-navic").setup {
				icons = { Object = "ﴯ " },
				separator = "  ",
				depth_limit = 7,
				depth_limit_indicator = "…",
			}
			require("nvim-navic").attach(client, bufnr)
		end
		if capabilities.signatureHelpProvider then
			require("lsp_signature").on_attach({
				floating_window = false,
				hint_prefix = "﬍ ",
				hint_scheme = "NonText", -- highlight group
			}, bufnr)
		end
		if capabilities.renameProvider then
			require("inc_rename").setup()
		end
		-- stylua: ignore end
	end,
})

--------------------------------------------------------------------------------

return {
	{ -- schemas for json-lsp
		"b0o/SchemaStore.nvim",
		lazy = true, -- loaded on jsonls setup
	},
	{ -- breadcrumbs for statusline/winbar
		"SmiteshP/nvim-navic",
		lazy = true, -- loaded when attaching to supporting lsp servers
	},
	{
		"ray-x/lsp_signature.nvim",
		lazy = true, -- loaded when attaching
	},
	{
		-- INFO only temporarily needed, until https://github.com/neovim/neovim/issues/18086
		"lvimuser/lsp-inlayhints.nvim",
		lazy = true, -- loaded when attaching
	},
	{
		"smjonas/inc-rename.nvim",
		lazy = true, -- loaded when attaching
	},
}
