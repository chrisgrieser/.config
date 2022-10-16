function PluginList ()

	-- Package Management
	use "wbthomason/packer.nvim" -- packer manages itself
	use "dstein64/vim-startuptime" -- measure startup time with `:StartupTime`
	use 'lewis6991/impatient.nvim' -- reduces startup time by ~50%

	-- Themes
	use "folke/tokyonight.nvim"
	use "EdenEast/nightfox.nvim"
	use "rebelot/kanagawa.nvim"
	-- use "Mofiqul/dracula.nvim"
	-- use "navarasu/onedark.nvim"
	-- use "sainnhe/edge"
	-- use "savq/melange"
	-- use "Yazeed1s/minimal.nvim"
	-- use "kaiuri/nvim-juliana"

	-- Syntax
	use { "nvim-treesitter/nvim-treesitter", run = function() require("nvim-treesitter.install").update({ with_sync = true }) end }
	use { "nvim-treesitter/nvim-treesitter-context", requires = {"nvim-treesitter/nvim-treesitter"} }
	use "mityu/vim-applescript" -- applescript syntax highlighting
	use "hail2u/vim-css3-syntax" -- better css syntax highlighting (until treesitter css looks decent…)

	-- LSP & Linting
	use {"neovim/nvim-lspconfig", requires = {
		"williamboman/mason-lspconfig.nvim" ,
		"williamboman/mason.nvim",
	}}
	use "ray-x/lsp_signature.nvim"
	use{ "jose-elias-alvarez/null-ls.nvim", requires =  "nvim-lua/plenary.nvim"}

	-- Completion & Suggestion
	use "mattn/emmet-vim" -- Emmet for CSS
	use "tversteeg/registers.nvim"
	use {"windwp/nvim-autopairs", requires = "hrsh7th/nvim-cmp"}
	use {"hrsh7th/nvim-cmp", requires = {
		"hrsh7th/cmp-buffer", -- completion sources
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"dmitmel/cmp-cmdline-history",
		"hrsh7th/cmp-emoji",
		"chrisgrieser/cmp-nerdfont",

		"hrsh7th/cmp-nvim-lsp", -- lsp
		"folke/neodev.nvim", -- lsp for nvim config

		"L3MON4D3/LuaSnip", -- snippet engine
		"saadparwaiz1/cmp_luasnip",
		"rafamadriz/friendly-snippets", -- collection of common snippets
	}}

	-- Appearance
	use { "p00f/nvim-ts-rainbow", requires = {"nvim-treesitter/nvim-treesitter"} } -- colored brackets
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use "nvim-lualine/lualine.nvim" -- status line
	use "lewis6991/gitsigns.nvim"
	use "f-person/auto-dark-mode.nvim" -- auto-toggle themes with OS dark/light mode
	use {"uga-rosa/ccc.nvim", branch = "dev" } -- color previews & color utilites

	-- File Management & Switching
	use "tpope/vim-eunuch" -- file operation utilities
	use { "nvim-telescope/telescope.nvim", requires = {
		"nvim-lua/plenary.nvim",
		"kyazdani42/nvim-web-devicons",
		"nvim-telescope/telescope-ui-select.nvim",
	}}

	-- Operators
	use {"tpope/vim-surround", requires = "tpope/vim-repeat"}
	use "tpope/vim-abolish" -- various case conversions
	use "svermeulen/vim-subversive" -- substitution operator
	use "tpope/vim-commentary"

	-- Text Objects
	use "andrewferrier/textobj-diagnostic.nvim" -- nvim diagnostics as text object
	use "michaeljsmith/vim-indent-object"
	use {"nvim-treesitter/nvim-treesitter-textobjects", requires = "nvim-treesitter/nvim-treesitter"}

	-- Movements
	use "mg979/vim-visual-multi" -- multi-cursor
	use "justinmk/vim-sneak"
	use "simrat39/symbols-outline.nvim" -- outline view for symbols

	-- Line Editing
	use "matze/vim-move" -- move lines with auto-indention (alternative: vim.unimpaired)
	use "AndrewRadev/splitjoin.vim"

	-- Misc
	use "dbeniamine/cheat.sh-vim" -- docs search
	use "mbbill/undotree" -- undo history nagivation

end
