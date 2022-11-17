local M = {}
function M.PluginList(use)

	-- Package Management
	use "wbthomason/packer.nvim" -- packer manages itself
	use "lewis6991/impatient.nvim" -- reduces startup time by ~50%
	use {"williamboman/mason.nvim", requires = "RubixDev/mason-update-all"}
	-- use "dstein64/vim-startuptime" -- measure startup time with `:StartupTime`

	-- Themes
	use "folke/tokyonight.nvim"
	use "savq/melange" -- like Obsidian's Primary color scheme
	-- use "EdenEast/nightfox.nvim"
	-- use "rebelot/kanagawa.nvim"
	-- use "Mofiqul/dracula.nvim"

	-- Syntax
	use {
		"nvim-treesitter/nvim-treesitter",
		run = function() -- auto-update parsers on start: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
			require("nvim-treesitter.install").update {with_sync = true}
		end,
		requires = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"nvim-treesitter/nvim-treesitter-refactor",
			"nvim-treesitter/nvim-treesitter-context",
			"p00f/nvim-ts-rainbow",
		}
	}
	use {"mityu/vim-applescript", ft = "applescript"} -- applescript syntax highlighting
	use {"hail2u/vim-css3-syntax", ft = "css"} -- better css syntax highlighting (until treesitter css looks decent…)

	-- LSP
	use {"neovim/nvim-lspconfig", requires = {
		"williamboman/mason-lspconfig.nvim",
		"lvimuser/lsp-inlayhints.nvim", -- only temporarily needed, until https://github.com/neovim/neovim/issues/18086
		"ray-x/lsp_signature.nvim",
	}}

	-- Linting
	use {"jose-elias-alvarez/null-ls.nvim", requires = {
		"nvim-lua/plenary.nvim",
		"jayp0521/mason-null-ls.nvim",
	}}

	-- DAP & Debugging
	use {"mfussenegger/nvim-dap", requires = {
		"jayp0521/mason-nvim-dap.nvim",
		"jbyuki/one-small-step-for-vimkind", -- lua debugger specifically for neovim config
		-- "rcarriga/nvim-dap-ui",
		-- "theHamsta/nvim-dap-virtual-text",
	}}

	-- Completion & Suggestion
	use {"hrsh7th/nvim-cmp", requires = {
		"hrsh7th/cmp-buffer", -- completion sources
		"hrsh7th/cmp-path",
		"hrsh7th/cmp-cmdline",
		"dmitmel/cmp-cmdline-history",
		"hrsh7th/cmp-emoji",
		"chrisgrieser/cmp-nerdfont",
		"petertriho/cmp-git", -- git issues, mentions & commits
		"hrsh7th/cmp-nvim-lsp", -- lsp
		"L3MON4D3/LuaSnip", -- snippet engine
		"saadparwaiz1/cmp_luasnip", -- adapter for snippet engine
	}}
	use {"tzachar/cmp-tabnine", run = "./install.sh", requires = "hrsh7th/nvim-cmp"}
	use {"windwp/nvim-autopairs", requires = "hrsh7th/nvim-cmp"}
	use "folke/neodev.nvim" -- lsp for nvim-lua config


	-- Appearance
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use "nvim-lualine/lualine.nvim" -- status line
	use "lewis6991/gitsigns.nvim" -- gutter signs
	use "f-person/auto-dark-mode.nvim" -- auto-toggle themes with OS dark/light mode
	use "stevearc/dressing.nvim" -- Selection Menus and Inputs
	use "rcarriga/nvim-notify" -- notifications
	use "uga-rosa/ccc.nvim" -- color previews & color utilites
	use "petertriho/nvim-scrollbar" -- kinda works as secondary gutter

	-- File Management & Switching
	use {"nvim-telescope/telescope.nvim", requires = {
		"nvim-lua/plenary.nvim",
		"kyazdani42/nvim-web-devicons",
	}}

	-- File History
	use {"mbbill/undotree", cmd = "UndotreeToggle"}
	use {"sindrets/diffview.nvim",
		requires = "nvim-lua/plenary.nvim",
		cmd = {"DiffviewFileHistory", "DiffviewOpen"},
		config = function()
			require("diffview").setup {
				file_history_panel = {win_config = {height = 8}},
				keymaps = {
					file_history_panel = {["o"] = require("diffview.actions").options},
					option_panel = {["<CR>"] = require("diffview.actions").select_entry},
				},
			}
		end
	}

	-- Operators & Text Objects
	use "kylechui/nvim-surround"
	use "gbprod/substitute.nvim" -- substitution operator, neovim version for vim-subversive
	use "numToStr/Comment.nvim"
	use {"michaeljsmith/vim-indent-object", keys = {{"o", "ai"}, {"o", "ii"}}}

	-- Navigation
	use "mg979/vim-visual-multi" -- multi-cursor
	use "ggandor/leap.nvim"

	-- Editing
	use "AndrewRadev/splitjoin.vim"
	use "Darazaki/indent-o-matic" -- detect indention (alternative: NMAC427/guess-indent.nvim)

end

return M
