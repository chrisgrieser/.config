return {


	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"lvimuser/lsp-inlayhints.nvim", -- only temporarily needed, until https://github.com/neovim/neovim/issues/18086
			"ray-x/lsp_signature.nvim", -- signature hint
			"SmiteshP/nvim-navic", -- breadcrumbs for statusline/winbar
			"folke/neodev.nvim", -- lsp for nvim-lua config
			"b0o/SchemaStore.nvim", -- schemas for json-lsp
		},
	},


	-- File Switching & File Operation
	{
		"ThePrimeagen/harpoon",
		lazy = true,
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			require("harpoon").setup {
				menu = {
					borderchars = BorderChars,
					width = 50,
					height = 8,
				},
			}

			-- HACK to make Harpoon marks syncable across devices by creating symlink
			-- to the `harpoon.json` that is synced
			local symlinkCmd = string.format(
				"ln -sf '%s' '%s'",
				VimDataDir .. "/harpoon.json",
				vim.fn.stdpath("data") .. "/harpoon.json" -- https://github.com/ThePrimeagen/harpoon/blob/master/lua/harpoon/init.lua#L7
			)
			vim.fn.system(symlinkCmd)
		end,
	},

	-- change cwd per project, mostly used for project-specific scope for Harpoon
	-- and `:Telescope find_files`
	{
		"ahmedkhalf/project.nvim",
		event = "VimEnter",
		config = function()
			require("project_nvim").setup {
				detection_methods = { "pattern", "lsp" }, -- prioty: pattern, then lsp
				patterns = {
					".git",
					"package.json", -- node
					"=File Hub", -- my general-inbox-working-directory
					"info.plist", -- Alfred workflows
					".luarc.json", -- lua projects
					".harpoon", -- manually mark certain folders as project roots
				},
				exclude_dirs = { "node_modules", "build", "dist" },
				datapath = VimDataDir,
			}
		end,
	},
	{
		"chrisgrieser/nvim-genghis",
		lazy = true,
		dev = true,
		dependencies = "stevearc/dressing.nvim",
		init = function() vim.g.genghis_disable_commands = true end,
	},

	-- Misc
	{ "iamcco/markdown-preview.nvim", ft = "markdown", build = "cd app && npm install" },
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			vim.opt.timeoutlen = 600 -- duration until which-key is shown
			require("which-key").setup {
				plugins = {
					presets = {
						operators = true,
						motions = false,
					},
				},
				triggers_blacklist = {
					n = { "y" }, -- FIX "y" needed to fix weird delay occurring when yanking after a change
				},
				hidden = {},
				window = {
					border = { "", "─", "", "" }, -- no border to the side to save space
					padding = { 0, 0, 0, 0 },
					margin = { 0, 0, 0, 0 },
				},
				layout = { -- of the columns
					height = { min = 4, max = 17 },
					width = { min = 22, max = 33 },
					spacing = 1,
				},
			}
		end,
	},
}
