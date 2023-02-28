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

	-- Misc
	{ "iamcco/markdown-preview.nvim", ft = "markdown", build = "cd app && npm install" },
	{
		"ThePrimeagen/harpoon",
		lazy = true,
		dependencies = "nvim-lua/plenary.nvim",
	},
	{
		"ahmedkhalf/project.nvim",
		config = function()
			require("project_nvim").setup {
				detection_methods = { "lsp", "pattern" },
				ignore_lsp = {"null-ls"},
				-- refer to the configuration section below
			}
		end,
	},

	-- TODO pending: https://github.com/cbochs/grapple.nvim/issues/62
	-- more flexible Harpoon alternative
	-- {
	-- 	"cbochs/grapple.nvim",
	-- 	dependencies = "nvim-lua/plenary.nvim",
	-- 	init = function()
	-- 		-- first looks for a `.grapple_root` file from the current directory
	-- 		-- upwards, if not found uses the git repo, if also not found, the
	-- 		-- current directory https://github.com/cbochs/grapple.nvim#scope-api
	-- 		My_resolver = require("grapple.scope").fallback({
	-- 			require("grapple.scope").root(".luarc.json"),
	-- 			require("grapple").resolvers.git_fallback,
	-- 			require("grapple").resolvers.directory,
	-- 		}, { cache = false })
	-- 		require("grapple").setup {
	-- 			scope = My_resolver,
	-- 		}
	-- 		vim.api.nvim_create_autocmd("BufEnter", {
	-- 			pattern = "*",
	-- 			callback = function()
	-- 				require("grapple.scope").update(My_resolver)
	-- 			end,
	-- 		})
	-- 	end,
	-- },
	{
		"chrisgrieser/nvim-genghis",
		lazy = true,
		dev = true,
		dependencies = "stevearc/dressing.nvim",
		init = function() vim.g.genghis_disable_commands = true end,
	},
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
