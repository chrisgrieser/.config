return {
	{
		"williamboman/mason.nvim",
		external_dependencies = { "node", "python3.12", "yq" },
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason Home" },
		},

		-- so mason packages are available before loading mason itself
		init = function()
			vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. ":" .. vim.env.PATH
		end,
		opts = {
			PATH = "skip", -- since already adding manually above

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
			-- INFO Adding a custom field `mason_dependencies` to
			-- lazy-plugin-specs, so they can be picked up for this plugin.
			local packages = vim.iter(require("lazy").plugins())
				:map(function(plugin) return plugin.mason_dependencies end)
				:flatten()
				:totable()
			table.sort(packages)
			vim.fn.uniq(packages)

			local errormsg = "Error in lazy-plugin-specs, many packages would be uninstalled."
			assert(#packages > 10, errormsg)

			-- FIX manually running `MasonToolsUpdate`, since `run_on_start` does
			-- not work with lazy-loading.
			require("mason-tool-installer").setup { ensure_installed = packages }
			vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
			vim.defer_fn(vim.cmd.MasonToolsUpdate, 5000)
			vim.defer_fn(vim.cmd.MasonToolsClean, 8000)
		end,
	},
}
