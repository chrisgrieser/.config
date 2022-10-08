function PluginList ()

	-- Package Management
	use 'wbthomason/packer.nvim' -- packer manages itself
	use 'dstein64/vim-startuptime' -- measure startup time with `:StartupTime`

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

	-- -- Syntax
	use { 'nvim-treesitter/nvim-treesitter', run = function() require('nvim-treesitter.install').update({ with_sync = true }) end }
	use { 'nvim-treesitter/nvim-treesitter-context', requires = {'nvim-treesitter/nvim-treesitter'} }
	use 'mityu/vim-applescript' -- applescript syntax highlighting

	-- LSP & Linting
	use {'neovim/nvim-lspconfig', requires = 'williamboman/mason-lspconfig.nvim' } -- neovim lsp/linter installer
	use 'williamboman/mason.nvim'
	use {'hrsh7th/cmp-nvim-lsp', requires = 'hrsh7th/nvim-cmp' }
	use 'mfussenegger/nvim-lint'
	use "https://git.sr.ht/~whynothugo/lsp_lines.nvim"

	-- Completion & Suggestion
	use 'Raimondi/delimitMate' -- auto-close brackets & quotes in insert mode (alternative: cohama/lexima.vim)
	use 'mattn/emmet-vim' -- Emmet for CSS
	use {'hrsh7th/nvim-cmp', -- autocompletion
		requires = { -- completion sources
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
			'dmitmel/cmp-cmdline-history',
			'hrsh7th/cmp-emoji',

			'hrsh7th/cmp-nvim-lsp', -- lsp
			'hrsh7th/cmp-nvim-lsp-signature-help', -- lsp
			'folke/lua-dev.nvim', -- nvim itself

			'saadparwaiz1/cmp_luasnip',
			'L3MON4D3/LuaSnip', -- snippet engine
			'rafamadriz/friendly-snippets', -- collection of common snippets
		}
	}

	-- Appearance
	use { 'p00f/nvim-ts-rainbow', requires = {'nvim-treesitter/nvim-treesitter'} } -- colored brackets
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use 'nvim-lualine/lualine.nvim' -- status line
	use 'airblade/vim-gitgutter'
	use 'f-person/auto-dark-mode.nvim' -- auto-toggle themes with OS dark/light mode
	use "uga-rosa/ccc.nvim" -- color previews & color utilites

	-- File Management & Switching
	use 'tpope/vim-eunuch' -- file operation utilities
	use { 'nvim-telescope/telescope.nvim', -- fuzzy finder
		requires = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' }
	}

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
