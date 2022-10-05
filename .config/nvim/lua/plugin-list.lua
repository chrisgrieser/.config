function PluginList (use)
	use 'wbthomason/packer.nvim' -- packer manages itself

	-- Themes
	use 'folke/tokyonight.nvim'
	use 'sainnhe/edge'
	use 'Mofiqul/dracula.nvim'
	use 'EdenEast/nightfox.nvim'
	use 'catppuccin/nvim'
	use "rebelot/kanagawa.nvim"
	use "bluz71/vim-moonfly-colors"
	use 'frenzyexists/aquarium-vim'
	use 'glepnir/zephyr-nvim'
	use 'ray-x/aurora'
	use 'shaunsingh/moonlight.nvim'
	use 'yashguptaz/calvera-dark.nvim'
	use 'kyazdani42/blue-moon'
	use 'Yazeed1s/minimal.nvim'
	use 'kvrohit/rasmus.nvim'

	-- LSP, Linting & Syntax
	use {'neoclide/coc.nvim', branch = 'release'}
	use { 'nvim-treesitter/nvim-treesitter',
		run = function() require('nvim-treesitter.install').update({ with_sync = true }) end }
	use { 'nvim-treesitter/nvim-treesitter-context', requires = {'nvim-treesitter/nvim-treesitter'} }
	use 'dense-analysis/ale'

	-- Completion & Suggestion
	use 'Raimondi/delimitMate' -- auto-close brackets & quotes in insert mode (alternative: cohama/lexima.vim)
	use 'mattn/emmet-vim' -- Emmet for CSS
	use 'gelguy/wilder.nvim' -- suggestions for command line mode (: and /)
	use {'rafamadriz/friendly-snippets', -- collection of common snippets
		requires = 'neoclide/coc.nvim' } -- coc.snippet is the actual requirement

	use { "tversteeg/registers.nvim", -- visualise registers on ´"´
		config = function() require("registers").setup() end, }

	-- Appearance
	use { 'p00f/nvim-ts-rainbow', requires = {'nvim-treesitter/nvim-treesitter'} } -- colored brackets
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use 'nvim-lualine/lualine.nvim' -- status bar
	use 'airblade/vim-gitgutter' -- changes in gutter
	use 'f-person/auto-dark-mode.nvim' -- auto-toggle themes with OS dark/light mode
	-- these do not seem to work for properly... :/
	-- use 'gko/vim-coloresque'
	-- use 'ap/vim-css-color'
	-- use 'norcalli/nvim-colorizer.lua'

	-- File Management & Switching
	use 'tpope/vim-eunuch' -- file operation utilities
	use { 'nvim-telescope/telescope.nvim', -- fuzzy finder
		requires = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' }
	}
	-- use 'ThePrimeagen/harpoon' -- for switching regularly between multiple files

	-- Operators
	use {'tpope/vim-surround', requires = 'tpope/vim-repeat'}
	use 'tpope/vim-commentary' -- comments operator & text object
	use 'tpope/vim-abolish' -- various case conversions
	use 'svermeulen/vim-subversive' -- substitution operator

	-- Objects & Motions
	use 'mg979/vim-visual-multi' -- multi-cursor
	use 'michaeljsmith/vim-indent-object'
	use 'gcmt/wildfire.vim' -- incrementally expanding objects (alternative: terryma/vim-expand-region)
	use {'nvim-treesitter/nvim-treesitter-textobjects', requires = 'nvim-treesitter/nvim-treesitter'}
	use 'justinmk/vim-sneak'
	use 'matze/vim-move' -- move lines with auto-indention (alternative: vim.unimpaired)

	-- Misc
	use 'mzlogin/vim-markdown-toc'
	use 'dbeniamine/cheat.sh-vim'
	use 'dstein64/vim-startuptime' -- measure startup time with `:StartupTime`
	use { 'glacambre/firenvim', run = function() vim.fn['firenvim#install'](0) end }

end
