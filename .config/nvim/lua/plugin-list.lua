function PluginList ()
	use 'wbthomason/packer.nvim' -- packer manages itself

	-- Themes
	use 'folke/tokyonight.nvim' -- color scheme

	-- Appearance
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use "unblevable/quick-scope" -- highlight for f & t
	use 'nvim-lualine/lualine.nvim' -- statusbar (w/o requiring icons, since I don't use them)
	use 'itchyny/vim-highlighturl' -- highlight urls
	use 'airblade/vim-gitgutter' -- Nomen est omen

	-- check out later?
	-- use 'nvim-treesitter/nvim-treesitter'
	-- use { 'nvim-treesitter/nvim-treesitter-context', requires = {'nvim-treesitter/nvim-treesitter'},
	-- }

	-- LSP & Syntax
	use {'neoclide/coc.nvim', branch = 'release'}

	-- Utility
	-- use 'dstein64/vim-startuptime' -- measure startup time with `:StartupTime`
	use 'tpope/vim-eunuch' -- file operation utilities
	use {
		'nvim-telescope/telescope.nvim', -- fuzzy finder
		requires = {
			'nvim-lua/plenary.nvim', -- requirement
			'kyazdani42/nvim-web-devicons' -- filetype icons
		}
	}

	-- Editing
	use 'tpope/vim-commentary' -- comments
	use 'tpope/vim-abolish' -- the case conversions
	use 'mg979/vim-visual-multi' -- multi-cursor
	use 'tpope/vim-surround' -- surround with punctuation
	use 'Raimondi/delimitMate' -- auto-close brakcets & quotes. Alternative: cohama/lexima.vim
	use 'michaeljsmith/vim-indent-object' -- indention-based text objects

end


