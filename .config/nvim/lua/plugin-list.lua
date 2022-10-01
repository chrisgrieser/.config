function PluginList (use)
	use 'wbthomason/packer.nvim' -- packer manages itself
	use 'dstein64/vim-startuptime' -- measure startup time with `:StartupTime`

	-- Themes
	use 'folke/tokyonight.nvim'

	-- Appearance
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use 'nvim-lualine/lualine.nvim' -- statusbar (w/o requiring icons, since I don't use them)
	use 'airblade/vim-gitgutter' -- changes

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

	-- Insert Mode
	use 'Raimondi/delimitMate' -- auto-close brackets & quotes in insert mode (alternative: cohama/lexima.vim)
	use 'mzlogin/vim-markdown-toc' -- markdown toc

	-- Motions
	use 'justinmk/vim-sneak' -- better vertical movement

	-- Operators
	use {'tpope/vim-surround', requires = 'tpope/vim-repeat'} -- surround with punctuation
	use 'tpope/vim-commentary' -- comments operator & text object
	use 'tpope/vim-abolish' -- various case conversions
	use 'svermeulen/vim-subversive' -- replacement operator

	-- Objects
	use 'mg979/vim-visual-multi' -- multi-cursor
	use 'michaeljsmith/vim-indent-object' -- indention text objects
	use 'gcmt/wildfire.vim' -- incrementally expanding objects (alternative: terryma/vim-expand-region)

end

