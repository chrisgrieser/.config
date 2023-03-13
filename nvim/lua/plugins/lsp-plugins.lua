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

	-----------------------------------------------------------------------------

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"b0o/SchemaStore.nvim", -- schemas for json-lsp
		},
		config = function()
			-- Border Styling
			require("lspconfig.ui.windows").default_options.border = BorderStyle
			vim.lsp.handlers["textDocument/hover"] =
				vim.lsp.with(vim.lsp.handlers.hover, { border = BorderStyle })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = BorderStyle })
		end,
	},

	-----------------------------------------------------------------------------

	{
		"SmiteshP/nvim-navic", -- breadcrumbs for statusline/winbar
		event = "LspAttach",
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
		config = function()
			-- INFO this must come before lua LSP setup
			require("neodev").setup {
				library = { plugins = false },
			}
		end,
	},
	{
		"ray-x/lsp_signature.nvim",
		cmd = "InsertEnter", -- signatures only displayed in insert mode
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
		event = "LspAttach",
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
		config = function() require("inc_rename").setup {} end,
	},
}
