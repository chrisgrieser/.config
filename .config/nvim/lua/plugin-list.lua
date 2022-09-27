function pluginList (use)
	use 'wbthomason/packer.nvim' -- packer manages itself

	-- Appearance
	use 'folke/tokyonight.nvim' -- color scheme
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use "unblevable/quick-scope" -- highlight for f and t movements
	use { 'nvim-lualine/lualine.nvim', requires = { 'kyazdani42/nvim-web-devicons' } }

	-- Utility
	use 'farmergreg/vim-lastplace' -- remember last cursor position on file re-opening
	use 'dstein64/vim-startuptime' -- measure startup time with `:StartupTime`
	use {
		'nvim-telescope/telescope.nvim', -- fuzzy finder
		requires = {
			'nvim-lua/plenary.nvim', -- requirement
			'kyazdani42/nvim-web-devicons' -- icons for fuzzy finder
		}
	}

	-- Editing
	use 'tpope/vim-commentary' -- comments
	use 'tpope/vim-abolish' -- used for the case conversions
	use 'mg979/vim-visual-multi' -- multi-cursor
	use 'tpope/vim-surround' -- surround with punctuation
	use 'michaeljsmith/vim-indent-object' -- indention-based text objects

	-- check out later?
	-- use {
	-- 	'nvim-treesitter/nvim-treesitter-context',
	-- 	requires = {'nvim-treesitter/nvim-treesitter'},
	-- }

end


