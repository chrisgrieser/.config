return {
	{
		"williamboman/mason.nvim",
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason Home" },
		},

		-- so mason packages are available before loading mason itself
		init = function() vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH end,
		opts = {
			PATH = "skip", -- since already adding to PATH above

			-- add my own local registry: https://github.com/mason-org/mason-registry/pull/3671#issuecomment-1851976705
			-- also requires `yq` being available in the system
			-- registries = {
			-- 	"file:" .. vim.fn.stdpath("config") .. "/personal-mason-registry", -- needs to come first
			-- 	"github:mason-org/mason-registry",
			-- },
			ui = {
				border = vim.g.borderStyle,
				height = 0.85,
				width = 0.8,
				icons = {
					package_installed = "✓",
					package_pending = "󰔟",
					package_uninstalled = "✗",
				},
				keymaps = { -- consistent with keymaps for lazy.nvim
					uninstall_package = "x",
					toggle_help = "?",
					toggle_package_expand = "<Tab>",
				},
			},
		},
	},
	{ -- auto-install lsps & formatters
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = "williamboman/mason.nvim",
		config = function()
			local packages = require("config.lsp-servers").masonDependencies
			assert(#packages > 10, "Warning: in mason config, many packages would be uninstalled.")

			-- FIX manually running `MasonToolsUpdate`, since `run_on_start` does
			-- not work with lazy-loading.
			require("mason-tool-installer").setup { ensure_installed = packages }
			vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
			vim.defer_fn(vim.cmd.MasonToolsUpdate, 5000)
			vim.defer_fn(vim.cmd.MasonToolsClean, 8000)
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		config = function()
			require("lspconfig.ui.windows").default_options.border = vim.g.borderStyle

			-- Enable completion (nvim-cmp) and folding (nvim-ufo)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true
			capabilities.textDocument.foldingRange =
				{ dynamicRegistration = false, lineFoldingOnly = true }

			local serverConfigs = require("config.lsp-servers").serverConfigs
			for lspName, serverConfig in pairs(serverConfigs) do
				serverConfig.capabilities = capabilities
				require("lspconfig")[lspName].setup(serverConfig)
			end
		end,
	},
}
