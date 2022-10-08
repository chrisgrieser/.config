function PluginList (use)

	-- Package Management
	use 'wbthomason/packer.nvim' -- packer manages itself
	use 'dstein64/vim-startuptime' -- measure startup time with `:StartupTime`

	use {'neovim/nvim-lspconfig', config = function() require("config.lsp").setup() end, }
	use {'williamboman/mason.nvim', -- neovim lsp/linter installer
		requires = {
			'WhoIsSethDaniel/mason-tool-installer.nvim',
			'williamboman/mason-lspconfig.nvim',
		}
	}


	-- Themes
	use 'folke/tokyonight.nvim'
	use 'Mofiqul/dracula.nvim'
	use 'EdenEast/nightfox.nvim'

	use 'sainnhe/edge'
	use 'catppuccin/nvim'
	use "rebelot/kanagawa.nvim"
	use "bluz71/vim-moonfly-colors"
	use 'frenzyexists/aquarium-vim'
	use 'glepnir/zephyr-nvim'
	use 'ray-x/aurora'
	use 'yashguptaz/calvera-dark.nvim'
	use 'kyazdani42/blue-moon'
	use 'Yazeed1s/minimal.nvim'
	use 'kvrohit/rasmus.nvim'

	-- LSP, Linting & Syntax
	use { 'nvim-treesitter/nvim-treesitter', run = function() require('nvim-treesitter.install').update({ with_sync = true }) end }
	use { 'nvim-treesitter/nvim-treesitter-context', requires = {'nvim-treesitter/nvim-treesitter'} }
	use 'mityu/vim-applescript' -- applescript syntax highlighting

	-- Completion & Suggestion
	use 'Raimondi/delimitMate' -- auto-close brackets & quotes in insert mode (alternative: cohama/lexima.vim)
	use 'mattn/emmet-vim' -- Emmet for CSS
	use 'gelguy/wilder.nvim' -- suggestions for command line mode (: and /)

	-- Appearance
	use { 'p00f/nvim-ts-rainbow', requires = {'nvim-treesitter/nvim-treesitter'} } -- colored brackets
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use 'nvim-lualine/lualine.nvim' -- status bar
	use 'airblade/vim-gitgutter' -- changes in gutter
	use 'f-person/auto-dark-mode.nvim' -- auto-toggle themes with OS dark/light mode
	use "uga-rosa/ccc.nvim" -- color previews & color utilites

	-- File Management & Switching
	use 'tpope/vim-eunuch' -- file operation utilities
	use { 'nvim-telescope/telescope.nvim', -- fuzzy finder
		requires = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' }
	}
	-- use 'ThePrimeagen/harpoon' -- for switching regularly between multiple files

	-- Operators
	use {'tpope/vim-surround', requires = 'tpope/vim-repeat'}
	use 'tpope/vim-abolish' -- various case conversions
	use 'svermeulen/vim-subversive' -- substitution operator
	use 'tpope/vim-commentary' -- comment text object

	-- Objects & Motions
	use 'mg979/vim-visual-multi' -- multi-cursor
	use 'michaeljsmith/vim-indent-object'
	use {'nvim-treesitter/nvim-treesitter-textobjects', requires = 'nvim-treesitter/nvim-treesitter'}
	use 'justinmk/vim-sneak'
	use 'matze/vim-move' -- move lines with auto-indention (alternative: vim.unimpaired)

	-- Misc
	use 'dbeniamine/cheat.sh-vim' -- docs search
	use 'AndrewRadev/splitjoin.vim'
	use 'mbbill/undotree' -- undo history nagivation
	use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }

end
