local M = {}
function M.PluginList()

	-- Package Management
	use "wbthomason/packer.nvim" -- packer manages itself
	-- use "dstein64/vim-startuptime" -- measure startup time with `:StartupTime`
	use "lewis6991/impatient.nvim" -- reduces startup time by ~50%
	use {"williamboman/mason.nvim", requires = "RubixDev/mason-update-all"}

	-- Themes
	-- use "navarasu/onedark.nvim"
	-- use "EdenEast/nightfox.nvim"
	-- use "folke/tokyonight.nvim"
	-- use "rebelot/kanagawa.nvim"
	use "savq/melange" -- like Obsidian's Primary color scheme

	-- use "Mofiqul/dracula.nvim"
	-- use "Yazeed1s/minimal.nvim"
	-- use "kaiuri/nvim-juliana" -- sublime-mariana like

	-- Syntax
	use {
		"nvim-treesitter/nvim-treesitter",
		run = function() -- auto-update parsers on start: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
			require("nvim-treesitter.install").update {with_sync = true}
		end,
		requires = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-refactor",
			"p00f/nvim-ts-rainbow",
		}
	}
	use "mityu/vim-applescript" -- applescript syntax highlighting
	use "hail2u/vim-css3-syntax" -- better css syntax highlighting (until treesitter css looks decent…)

	-- LSP & Linting
	use {"neovim/nvim-lspconfig", requires = "williamboman/mason-lspconfig.nvim"}
	use "ray-x/lsp_signature.nvim"
	use {"jose-elias-alvarez/null-ls.nvim", requires = {
		"nvim-lua/plenary.nvim",
		"jayp0521/mason-null-ls.nvim",
	}}

	-- DAP & Debugging
	-- use {"mfussenegger/nvim-dap", requires = {
	-- 	"jayp0521/mason-nvim-dap.nvim",
	-- 	"rcarriga/nvim-dap-ui",
	-- 	"mxsdev/nvim-dap-vscode-js",
	-- }}

	-- Completion & Suggestion
	use {"windwp/nvim-autopairs", requires = "hrsh7th/nvim-cmp"}
	use {"hrsh7th/nvim-cmp", requires = {
		"hrsh7th/cmp-buffer", -- completion sources
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"dmitmel/cmp-cmdline-history",
		"hrsh7th/cmp-emoji",
		"chrisgrieser/cmp-nerdfont",
		"petertriho/cmp-git",
		"hrsh7th/cmp-nvim-lsp", -- lsp
		"folke/neodev.nvim", -- lsp for nvim-lua config
		"L3MON4D3/LuaSnip", -- snippet engine
		"saadparwaiz1/cmp_luasnip",
	}}

	-- Appearance
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use "nvim-lualine/lualine.nvim" -- status line
	use "lewis6991/gitsigns.nvim"
	use "f-person/auto-dark-mode.nvim" -- auto-toggle themes with OS dark/light mode
	use "uga-rosa/ccc.nvim" -- color previews & color utilites
	use "hood/popui.nvim" -- alternative to "stevearc/dressing.nvim"
	use "stevearc/dressing.nvim"
	use "rcarriga/nvim-notify"


	-- File Management & Switching
	use {"nvim-telescope/telescope.nvim", requires = {
		"nvim-lua/plenary.nvim",
		"kyazdani42/nvim-web-devicons",
	}}

	-- Operators & Text Objects
	use "kylechui/nvim-surround"
	use "gbprod/substitute.nvim" -- substitution operator, neovim version for vim-subversive
	use "numToStr/Comment.nvim"
	use "michaeljsmith/vim-indent-object"

	-- Navigation
	use "mg979/vim-visual-multi" -- multi-cursor
	use "phaazon/hop.nvim"
	use "unblevable/quick-scope" -- f-t-improvement

	-- Editing
	use "AndrewRadev/splitjoin.vim"
	use "Darazaki/indent-o-matic" -- detect indention (alternative: NMAC427/guess-indent.nvim)
	use "mbbill/undotree" -- undo history nagivation

end
return M
