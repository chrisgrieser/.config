return {
	{ -- mason
		"williamboman/mason.nvim",
		init = function()
			-- system python is on 3.9, but some programs require 3.12 (e.g. autotools-ls)
			-- NOTE this has the drawback that `pynvim` cannot be installed anymore
			vim.g.python3_host_prog = "python3.12"
		end,
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason" },
		},
		opts = {
			ui = {
				border = vim.g.borderStyle,
				height = 0.8, -- so statusline is still visible
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
			-- dependencies of plugins (via lazy.nvim) -- PENDING https://github.com/folke/lazy.nvim/issues/1264
			local plugins = require("lazy").plugins()
			local deps = vim.tbl_map(function(plugin) return plugin.extra_dependencies end, plugins)
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
