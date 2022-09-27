function pluginList (use)
	use 'wbthomason/packer.nvim' -- packer manages itself

	-- Appearance
	use 'folke/tokyonight.nvim' -- color scheme
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use "unblevable/quick-scope" -- highlight for f and t movements

	-- Utility
	use 'farmergreg/vim-lastplace' -- remember last cursor position on file re-opening
	use {
		'nvim-telescope/telescope.nvim', -- fuzzy finder
		requires = {
			'nvim-lua/plenary.nvim', -- requirement
			'kyazdani42/nvim-web-devicons' --icons for fuzzy finder
		}
	}

	-- Editing
	use 'tpope/vim-commentary' -- comments
	use 'tpope/vim-surround' -- surround with punctuation
	use 'wellle/targets.vim' -- various text object improvements
	use 'michaeljsmith/vim-indent-object' -- indention-based text objects

	-- check out later?
	-- use {
	-- 	'nvim-treesitter/nvim-treesitter-context',
	-- 	requires = {'nvim-treesitter/nvim-treesitter'},
	-- }
end
