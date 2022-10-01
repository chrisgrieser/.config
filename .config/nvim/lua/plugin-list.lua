function PluginList (use)
	use 'wbthomason/packer.nvim' -- packer manages itself
	use 'dstein64/vim-startuptime' -- measure startup time with `:StartupTime`

	-- Themes
	use 'folke/tokyonight.nvim'

	-- Appearance
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use 'nvim-lualine/lualine.nvim'
	use 'airblade/vim-gitgutter'
	use 'rcarriga/nvim-notify'

	-- -- LSP & Syntax
	use {'neoclide/coc.nvim', branch = 'release'}
	use {
		'nvim-treesitter/nvim-treesitter',
		run = function() require('nvim-treesitter.install').update({ with_sync = true }) end,
	}
	use { 'nvim-treesitter/nvim-treesitter-context', requires = {'nvim-treesitter/nvim-treesitter'} }
	use { 'p00f/nvim-ts-rainbow', requires = {'nvim-treesitter/nvim-treesitter'} }

	-- File Releated
	use 'tpope/vim-eunuch' -- file operation utilities
	use { 'nvim-telescope/telescope.nvim', -- fuzzy finder
		requires = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' }
	}
	-- use 'ThePrimeagen/harpoon' -- switching regularly between multiple files

	-- Operators
	use {'tpope/vim-surround', requires = 'tpope/vim-repeat'}
	use 'tpope/vim-commentary' -- comments operator & text object
	use 'tpope/vim-abolish' -- various case conversions
	use 'svermeulen/vim-subversive' -- substitution operator

	-- Objects & Motions
	use 'mg979/vim-visual-multi' -- multi-cursor
	use 'michaeljsmith/vim-indent-object'
	use 'gcmt/wildfire.vim' -- incrementally expanding objects (alternative: terryma/vim-expand-region)
	use{ 'nvim-treesitter/nvim-treesitter-textobjects', requires = 'nvim-treesitter/nvim-treesitter'}
	use 'justinmk/vim-sneak'

	-- Misc
	use 'Raimondi/delimitMate' -- auto-close brackets & quotes in insert mode (alternative: cohama/lexima.vim)
	use 'mzlogin/vim-markdown-toc'
	use 'preservim/vim-markdown' -- conceal (fold) markdown URLs

end

