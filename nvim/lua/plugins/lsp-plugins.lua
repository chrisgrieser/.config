-- lsp attach function

local signatureConfig = {

				floating_window = false,
				hint_prefix = "﬍ ",
				hint_scheme = "NonText", -- highlight group
}

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local capabilities = client.server_capabilities

		-- stylua: ignore
		if capabilities.inlayHintProvider then
			require("lsp-inlayhints").on_attach(client, bufnr)
		end

		if capabilities.documentSymbolProvider and client.name ~= "cssls" then
			require("nvim-navic").attach(client, bufnr)
		end

		if capabilities.signatureHelpProvider then
			require "lsp_signature".on_attach(signatureConfig, bufnr)
		end
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
		config = function()
			require("nvim-navic").setup {
				icons = { Object = "ﴯ " },
				separator = "  ",
				depth_limit = 7,
				depth_limit_indicator = "…",
			}
		end,
	},
	{
		"folke/neodev.nvim", -- lsp for nvim-lua config
		lazy = false,
		config = function()
			-- INFO this must come before lua LSP setup
			require("neodev").setup {
				library = { plugins = false },
			}
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		lazy = true,
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
		lazy = true, -- attaching to supporting lsp servers (see init function)
		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					local capabilities = client.server_capabilities

					if capabilities.inlayHintProvider then
						require("lsp-inlayhints").on_attach(client, bufnr)
					end
				end,
			})
		end,
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
		lazy = true, -- loaded when attaching to supporting lsp servers
		-- event = "LspAttach",
		config = function() require("inc_rename").setup {} end,
	},
}
