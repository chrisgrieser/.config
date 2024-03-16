return {
	{
		"williamboman/mason.nvim",
		external_dependencies = { "node", "python3.12" },
		mason_dependencies = "yq", -- only needed when using local registry
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason" },
		},
		-- temporary FIX if npm package installs are hanging. 
		-- for permanent fix, investigate local `openssl` installation
		-- init = function () vim.env.npm_config_strict_ssl=false end, 
		opts = {
			-- add my own local registry: https://github.com/mason-org/mason-registry/pull/3671#issuecomment-1851976705
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
			-- dependencies of plugins (via lazy.nvim)
			local plugins = require("lazy").plugins()
			local deps = vim.tbl_map(function(plugin) return plugin.mason_dependencies end, plugins)
			deps = vim.tbl_flatten(vim.tbl_values(deps))
			table.sort(deps)
			deps = vim.fn.uniq(deps)

			require("mason-tool-installer").setup {
				ensure_installed = deps,
				run_on_start = false, -- manually, since otherwise not working with lazy-loading
			}
			vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
			vim.defer_fn(vim.cmd.MasonToolsClean, 1000) -- delayed, so noice.nvim is loaded before
		end,
	},
}
