return {
	{
		"williamboman/mason.nvim",
		-- PENDING https://github.com/williamboman/mason.nvim/pull/1608
		branch = "eat/more-python-candidates",
		external_dependencies = { "node", "python3" },
		-- build = function()
		-- 	-- INFO System python is on 3.9, but some packages require 3.12, so we are
		-- 	-- are creating a symlink, so mason picks up homebrew's python, which
		-- 	-- isn't picked up by default, since it uses `python3.12` instead of
		-- 	-- `python3` as binary name.
		-- 	local symLinkFrom = vim.env.HOMEBREW_PREFIX .. "/bin/python3.12"
		-- 	local symLinkTo = vim.env.HOMEBREW_PREFIX .. "/bin/python3"
		-- 	local symlinkExists = vim.loop.fs_stat(symLinkTo) ~= nil
		-- 	if not symlinkExists then vim.loop.fs_symlink(symLinkFrom, symLinkTo) end
		-- end,
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason" },
		},
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
