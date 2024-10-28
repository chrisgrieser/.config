return {
	{
		"williamboman/mason.nvim",
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason Home" },
		},
		-- so mason packages are available before loading mason itself
		init = function() vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH end,
		opts = {
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

			-- FIX manual `MasonToolsUpdate`, since `run_on_start` doesn't work with lazy-loading
			require("mason-tool-installer").setup { ensure_installed = packages }
			vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
			vim.defer_fn(vim.cmd.MasonToolsUpdate, 4000)
			vim.defer_fn(vim.cmd.MasonToolsClean, 8000)
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		config = function()
			require("lspconfig.ui.windows").default_options.border = vim.g.borderStyle

			-- Enable completion (nvim-cmp/blink.cmp) and folding (nvim-ufo)
			-- PENDING https://github.com/Saghen/blink.cmp/issues/13
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true
			capabilities.textDocument.foldingRange =
				{ dynamicRegistration = false, lineFoldingOnly = true }

			local myServerConfigs = require("config.lsp-servers").serverConfigs
			for lspName, config in pairs(myServerConfigs) do
				config.capabilities = capabilities
				require("lspconfig")[lspName].setup(config)
			end
		end,
	},
}
