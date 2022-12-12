---@diagnostic disable: undefined-global
local M = {}
local myrepos = os.getenv("HOME") .. "/Library/Mobile Documents/com~apple~CloudDocs/Repos/"
--------------------------------------------------------------------------------
function M.PluginList()

	-- Package Management
	use "wbthomason/packer.nvim" -- packer manages itself
	use "lewis6991/impatient.nvim" -- reduces startup time by ~50%
	use {"williamboman/mason.nvim", requires = "RubixDev/mason-update-all"}

	-- Themes
	use "savq/melange" -- like Obsidian's Primary color scheme
	use "nyoom-engineering/oxocarbon.nvim"
	-- use "folke/tokyonight.nvim"
	-- use "EdenEast/nightfox.nvim"
	-- use "rebelot/kanagawa.nvim"

	-- Treesitter
	use {
		"nvim-treesitter/nvim-treesitter",
		run = function() -- auto-update parsers on start: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
			require("nvim-treesitter.install").update {with_sync = true}
		end,
		requires = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"p00f/nvim-ts-rainbow", -- colored brackets
		}
	}

	use {"mizlan/iswap.nvim", -- swapping of notes
		config = function() require("iswap").setup {autoswap = true} end,
		cmd = "ISwapWith"
	}
	use {"m-demare/hlargs.nvim", -- highlight function args
		config = function() require("hlargs").setup() end,
	}
	use {"Wansmer/treesj", -- split-join
		requires = {
			"nvim-treesitter/nvim-treesitter",
			"AndrewRadev/splitjoin.vim", -- only used as fallback. TODO: remove when treesj has wider language support
		},
	}
	use {"cshuaimin/ssr.nvim", -- structural search & replace
		module = "ssr",
		commit = "4304933", -- TODO: update to newest version with nvim 0.9 https://github.com/cshuaimin/ssr.nvim/issues/11#issuecomment-1340671193
		config = function()
			require("ssr").setup {
				keymaps = {close = "Q"},
			}
		end
	}

	use {"abecodes/tabout.nvim", -- i_<Tab> to move out of node
		after = "nvim-cmp",
		requires = "nvim-treesitter/nvim-treesitter",
		config = function()
			require("tabout").setup {
				act_as_shift_tab = true,
				ignore_beginning = true,
			}
		end,
	}

	-- LSP
	use {"neovim/nvim-lspconfig", requires = {
		"williamboman/mason-lspconfig.nvim",
		"lvimuser/lsp-inlayhints.nvim", -- only temporarily needed, until https://github.com/neovim/neovim/issues/18086
		"ray-x/lsp_signature.nvim", -- signature hint
		"SmiteshP/nvim-navic", -- breadcrumbs
		"folke/neodev.nvim", -- lsp for nvim-lua config
		"b0o/SchemaStore.nvim", -- schemas for json-lsp
	}}
	use {"andrewferrier/textobj-diagnostic.nvim",
		module = "textobj-diagnostic",
		config = function() require("textobj-diagnostic").setup {create_default_keymaps = false} end,
	}

	-- Linting & Formatting
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
	use "stevearc/dressing.nvim" -- Selection Menus and Inputs
	use "rcarriga/nvim-notify" -- notifications
	use "uga-rosa/ccc.nvim" -- color previews & color utilities
	use "dstein64/nvim-scrollview" -- "petertriho/nvim-scrollbar" has more features, but is also more buggy atm
	use {"anuvyklack/windows.nvim", requires = "anuvyklack/middleclass"} -- auto-resize splits

	-- File Switching & File Operation
	use {myrepos .. "nvim-genghis",
		module = "genghis",
		requires = "stevearc/dressing.nvim",
	}
	use {"nvim-telescope/telescope.nvim", requires = {
		"nvim-lua/plenary.nvim",
		"kyazdani42/nvim-web-devicons"
	}}
	use {"ghillb/cybu.nvim", requires = {-- Cycle Buffers
		"nvim-tree/nvim-web-devicons",
		"nvim-lua/plenary.nvim",
	}}
	use {"simnalamburt/vim-mundo", -- undotree, also supports searching undo history
		cmd = "MundoToggle",
		run = "pip3 install --upgrade pynvim",
	}

	-- Terminal & Git
	use {"akinsho/toggleterm.nvim",
		cmd = {"ToggleTerm", "ToggleTermSendVisualSelection"},
		config = function() require("toggleterm").setup() end
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
	use {
		"ruifm/gitlinker.nvim",
		requires = "nvim-lua/plenary.nvim",
		module = "gitlinker",
		config = function()
			require("gitlinker").setup {
				mappings = nil,
				opts = {print_url = false},
			}
		end
	}

	-- Operators & Text Objects, Navigation & Editing
	use "echasnovski/mini.ai" -- custom text objects
	use "kylechui/nvim-surround" -- surround operator
	use "gbprod/substitute.nvim" -- substitution & exchange operator
	use "numToStr/Comment.nvim" -- comment operator
	use "michaeljsmith/vim-indent-object" -- indention-based text-object
	use {"mg979/vim-visual-multi", keys = {{"n", "<D-j>"}, {"x", "<D-j>"}}}
	use "Darazaki/indent-o-matic" -- auto-determine indents
	use {"nacro90/numb.nvim", -- line previews when ":n"
		config = function() require("numb").setup() end,
		keys = {{"n", ":"}},
	}
	use(myrepos .. "nvim-recorder") -- better macros

	-- Misc
	use "andweeb/presence.nvim"
	use {"kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async"} -- better folding

	-- Filetype-specific
	use {"mityu/vim-applescript", ft = "applescript"} -- syntax highlighting
	use {"hail2u/vim-css3-syntax", ft = "css"} -- better syntax highlighting (until treesitter css looks decent…)
	use {"iamcco/markdown-preview.nvim", ft = "markdown", run = "cd app && npm install"}
	use {"bennypowers/nvim-regexplainer",
		ft = {"javascript", "typescript"},
		requires = {"nvim-treesitter/nvim-treesitter", "MunifTanjim/nui.nvim"},
		config = function()
			require("regexplainer").setup {
				auto = true, -- automatically show the explainer when the cursor enters a regexp
				mappings = {toggle = nil},
			}
		end
	}

end

return M
