-- INFO: Server names are LSP names, not Mason names
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
local lsp_servers = {
	"lua_ls",
	"yamlls",
	"jsonls",
	"cssls",
	"emmet_ls", -- css & html completion
	"pyright", -- python
	"marksman", -- markdown
	"tsserver", -- ts/js
	"eslint", -- ts/js
	"bashls", -- also used for zsh
	"taplo", -- toml
}

--------------------------------------------------------------------------------

return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup {
				ui = {
					border = BorderStyle,
					icons = {
						package_installed = "✓",
						package_pending = "羽",
						package_uninstalled = "✗",
					},
				},
			}
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = "williamboman/mason.nvim",
		config = function()
			require("mason-lspconfig").setup {
				ensure_installed = lsp_servers,
			}
		end,
	},

	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.api.nvim_create_augroup("LSP", {})
			vim.api.nvim_create_autocmd("LspAttach", {
				group = "LSP",
				callback = function(args)
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					local capabilities = client.server_capabilities

					require("lsp-inlayhints").on_attach(client, bufnr)

					if capabilities.documentSymbolProvider and client.name ~= "cssls" then
						require("nvim-navic").attach(client, bufnr)
					end
				end,
			})

			-- Border Styling
			require("lspconfig.ui.windows").default_options.border = BorderStyle
			vim.lsp.handlers["textDocument/hover"] =
				vim.lsp.with(vim.lsp.handlers.hover, { border = BorderStyle })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = BorderStyle })
		end,
	},
}
