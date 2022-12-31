return {
	-- Package Management
	{ "williamboman/mason.nvim", dependencies = "RubixDev/mason-update-all" },

	-- Themes
	"EdenEast/nightfox.nvim",
	"folke/tokyonight.nvim",
	-- "rebelot/kanagawa.nvim",
	-- "nyoom-engineering/oxocarbon.nvim",
	-- "savq/melange",

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = function() -- auto-update parsers on start: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
			require("nvim-treesitter.install").update { with_sync = true }
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"p00f/nvim-ts-rainbow", -- colored brackets
		},
	},
	
	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"lvimuser/lsp-inlayhints.nvim", -- only temporarily needed, until https://github.com/neovim/neovim/issues/18086
			"ray-x/lsp_signature.nvim", -- signature hint
			"SmiteshP/nvim-navic", -- breadcrumbs
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
	
	-- DAP
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"jayp0521/mason-nvim-dap.nvim",
			"theHamsta/nvim-dap-virtual-text",
			"rcarriga/nvim-dap-ui",
			"jbyuki/one-small-step-for-vimkind", -- lua debugger specifically for neovim config
		},
	},
	
	-- File Switching & File Operation
	{ "chrisgrieser/nvim-genghis", dev = true, lazy = true, dependencies = "stevearc/dressing.nvim" },
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"debugloop/telescope-undo.nvim",
		},
	},
	
	-- Terminal & Git
	{
		"TimUntersberger/neogit",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = "Neogit",
		config = function()
			require("neogit").setup {
				disable_insert_on_commit = false, -- false = start commit msgs in insert mode
				disable_commit_confirmation = false,
				integrations = { diffview = true }, -- diffview plugin
				signs = {
					section = { "", "" },
					item = { "", "" },
				},
			}
		end,
	},
	{ "metakirby5/codi.vim", cmd = { "Codi", "CodiNew", "CodiExpand" } }, -- only coderunner with virtual text
	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "ToggleTermSendVisualSelection" },
		config = function() require("toggleterm").setup() end,
	},
	{
		"sindrets/diffview.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = { "DiffviewFileHistory", "DiffviewOpen" },
		config = function()
			require("diffview").setup {
				file_history_panel = { win_config = { height = 5 } },
			}
		end,
	},
	
	{
		"axieax/urlview.nvim",
		cmd = "UrlView",
		dependencies = "nvim-telescope/telescope.nvim",
		config = function()
			require("urlview").setup {
				default_picker = "telescope",
				default_action = "system",
				sorted = false,
			}
		end,
	},
	"Darazaki/indent-o-matic", -- auto-determine indents
	{ "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async" }, -- better folding
	
	-- Filetype-specific
	{ "mityu/vim-applescript", ft = "applescript" }, -- syntax highlighting
	{ "hail2u/vim-css3-syntax", ft = "css" }, -- better syntax highlighting (until treesitter css looks decent…)
	{ "iamcco/markdown-preview.nvim", ft = "markdown", build = "cd app && npm install" },
}
