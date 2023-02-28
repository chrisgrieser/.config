return {

	-- Treesitter & Syntax Highlighting
	{
		"nvim-treesitter/nvim-treesitter",
		build = function()
			-- auto-update parsers on start: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
			require("nvim-treesitter.install").update { with_sync = true }
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"mrjones2014/nvim-ts-rainbow",
		},
	},
	{ "mityu/vim-applescript", ft = "applescript" }, -- syntax highlighting
	{ "hail2u/vim-css3-syntax", ft = "css" }, -- better syntax highlighting (until treesitter css looks decent…)

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

	-- Linting & Formatting
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"jayp0521/mason-null-ls.nvim",
		},
	},

	-- File Switching & File Operation
	{
		"ThePrimeagen/harpoon",
		lazy = true,
		dependencies = "nvim-lua/plenary.nvim",
	},

	-- change cwd per project, mostly used for project-specific scope for Harpoon
	-- and `:Telescope find_files`
	{
		"ahmedkhalf/project.nvim",
		event = "VimEnter",
		config = function()
			require("project_nvim").setup {
				-- priority order
				detection_methods = { "pattern", "lsp" }, 
				-- `.harpoon` as file to manually mark project roots in certain directories
				patterns = { ".git", ".luarc.json", ".harpoon" }, 
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
				window = {
					border = "none", -- none to save space
					padding = { 0, 0, 0, 0 },
					margin = { 0, 0, 0, 0 },
				},
				layout = { -- of the columns
					height = { min = 4, max = 17 },
					width = { min = 20, max = 33 },
					spacing = 1,
				},
			}
		end,
	},
}
