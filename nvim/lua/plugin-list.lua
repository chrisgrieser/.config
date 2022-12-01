local M = {}
myrepos = os.getenv("HOME") .. "/Library/Mobile Documents/com~apple~CloudDocs/Repos/"
--------------------------------------------------------------------------------
function M.PluginList(use)

	-- Package Management
	use "wbthomason/packer.nvim" -- packer manages itself
	use "lewis6991/impatient.nvim" -- reduces startup time by ~50%
	use {"williamboman/mason.nvim", requires = "RubixDev/mason-update-all"}
	-- use {"dstein64/vim-startuptime", cmd = "StartupTime"} -- measure startup time with `:StartupTime`

	-- Themes
	use "folke/tokyonight.nvim"
	use "savq/melange" -- like Obsidian's Primary color scheme
	-- use "EdenEast/nightfox.nvim"
	-- use "rebelot/kanagawa.nvim"

	-- Treesitter
	use {
		"nvim-treesitter/nvim-treesitter",
		run = function() -- auto-update parsers on start: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
			require("nvim-treesitter.install").update {with_sync = true}
		end,
		requires = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-refactor",
			"p00f/nvim-ts-rainbow", -- colored brackets
		}
	}
	use {"Wansmer/treesj", -- split-join
		requires = {
			"nvim-treesitter/nvim-treesitter",
			"AndrewRadev/splitjoin.vim", -- only used as fallback. TODO: remove when treesj has wider language support
		},
	}
	use {"andymass/vim-matchup", requires = "nvim-treesitter/nvim-treesitter"} -- % improved
	use {"cshuaimin/ssr.nvim", -- structural search & replace
		module = "ssr",
		config = function() require("ssr").setup() end,
	}

	-- LSP
	use {"neovim/nvim-lspconfig", requires = {
		"williamboman/mason-lspconfig.nvim",
		"lvimuser/lsp-inlayhints.nvim", -- only temporarily needed, until https://github.com/neovim/neovim/issues/18086
		"ray-x/lsp_signature.nvim", -- signature hint
		"SmiteshP/nvim-navic", -- breadcrumbs
		"j-hui/fidget.nvim", -- lsp status
		"folke/neodev.nvim", -- lsp for nvim-lua config
		"b0o/SchemaStore.nvim", -- schemas for json-lsp
	}}

	-- Linting
	use {"jose-elias-alvarez/null-ls.nvim", requires = {
		"nvim-lua/plenary.nvim",
		"jayp0521/mason-null-ls.nvim",
	}}

	-- DAP
	use {"mfussenegger/nvim-dap", requires = {
		"jayp0521/mason-nvim-dap.nvim",
		"theHamsta/nvim-dap-virtual-text",
		"rcarriga/nvim-dap-ui",
		"jbyuki/one-small-step-for-vimkind", -- lua debugger specifically for neovim config
	}}

	-- Completion & Suggestion
	use {"hrsh7th/nvim-cmp", requires = {
		"hrsh7th/cmp-buffer", -- completion sources
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"dmitmel/cmp-cmdline-history",
		"hrsh7th/cmp-emoji",
		myrepos .. "cmp-nerdfont",
		"tamago324/cmp-zsh",
		"ray-x/cmp-treesitter",
		"petertriho/cmp-git", -- git issues, mentions & commits
		"hrsh7th/cmp-nvim-lsp", -- lsp
		"L3MON4D3/LuaSnip", -- snippet engine
		"saadparwaiz1/cmp_luasnip", -- adapter for snippet engine
	}}
	use {"tzachar/cmp-tabnine", run = "./install.sh", requires = "hrsh7th/nvim-cmp"}
	use {"windwp/nvim-autopairs", requires = "hrsh7th/nvim-cmp"}

	-- Appearance
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use "nvim-lualine/lualine.nvim" -- status line
	use "lewis6991/gitsigns.nvim" -- gutter signs
	use "f-person/auto-dark-mode.nvim" -- auto-toggle themes with OS dark/light mode
	use "stevearc/dressing.nvim" -- Selection Menus and Inputs
	use "rcarriga/nvim-notify" -- notifications
	use "uga-rosa/ccc.nvim" -- color previews & color utilites
	use "dstein64/nvim-scrollview" -- "petertriho/nvim-scrollbar" has more features, but is also more buggy atm
	use "anuvyklack/pretty-fold.nvim"

	-- File Switching & File Operation
	use {myrepos .. "nvim-genghis", requires = "stevearc/dressing.nvim"}
	use {"nvim-telescope/telescope.nvim", requires = {
		"nvim-lua/plenary.nvim",
		"kyazdani42/nvim-web-devicons"
	}}

	use {"ghillb/cybu.nvim", requires = {-- Cycle Buffers
		"nvim-tree/nvim-web-devicons",
		"nvim-lua/plenary.nvim",
	}}

	-- File History
	use {"simnalamburt/vim-mundo", -- undotree, also supports searching undo history
		cmd = "MundoToggle",
		run = "pip3 install --upgrade pynvim",
	}
	use {"sindrets/diffview.nvim",
		requires = "nvim-lua/plenary.nvim",
		cmd = {"DiffviewFileHistory", "DiffviewOpen"},
		config = function()
			require("diffview").setup {
				file_history_panel = {win_config = {height = 4}},
			}
		end,
	}

	-- Operators & Text Objects, Navigation & Editing
	use "kylechui/nvim-surround"
	use "gbprod/substitute.nvim"
	use "numToStr/Comment.nvim"
	use "michaeljsmith/vim-indent-object"
	use {"mg979/vim-visual-multi", keys = {{"n", "<D-j>"}, {"v", "<D-j>"}, {"n", "<M-Up>"}, {"n", "<M-Down>"}}}
	use "ggandor/leap.nvim"
	use "Darazaki/indent-o-matic"
	use {"abecodes/tabout.nvim", -- i_<Tab> to move out of node
		after = "nvim-cmp",
		requires = "nvim-treesitter/nvim-treesitter",
		config = function() require("tabout").setup() end,
		event = "InsertEnter",
	}

	-- Filetype-specific
	use {"mityu/vim-applescript", ft = "applescript"} -- syntax highlighting
	use {"hail2u/vim-css3-syntax", ft = "css"} -- better syntax highlighting (until treesitter css looks decent…)
	use {"iamcco/markdown-preview.nvim", ft = "markdown", run = "cd app && npm install"}

end

return M
