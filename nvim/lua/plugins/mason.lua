return {
	{
		"williamboman/mason.nvim",
		init = function()
			-- so mason packages are available before loading mason itself
			vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"
		end,
		external_dependencies = { "node", "python3.12", "yq" },
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason Home" },
		},
		opts = {
			-- add my own local registry: https://github.com/mason-org/mason-registry/pull/3671#issuecomment-1851976705
			-- also requires yq being available in the system
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
			local pluginDeps = vim.iter(require("lazy").plugins())
				:map(function(plugin) return plugin.mason_dependencies end)
				:flatten()
				:totable()
			table.sort(pluginDeps)
			vim.fn.uniq(pluginDeps)

			require("mason-tool-installer").setup {
				ensure_installed = pluginDeps,
				run_on_start = false, -- manually, since otherwise not working with lazy-loading
			}
			vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
			vim.defer_fn(vim.cmd.MasonToolsClean, 1000) -- delayed, so noice.nvim is loaded before
		end,
	},
}
