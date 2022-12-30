-- stylua: ignore
return {
	-- Package Management
	{"williamboman/mason.nvim", dependencies = "RubixDev/mason-update-all"},

	-- Themes
	"EdenEast/nightfox.nvim",
	"rebelot/kanagawa.nvim",
	-- "folke/tokyonight.nvim",
	-- "nyoom-engineering/oxocarbon.nvim",
	-- "savq/melange",

	-- Treesitter
	{"nvim-treesitter/nvim-treesitter",
		build = function() -- auto-update parsers on start: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
			require("nvim-treesitter.install").update {with_sync = true}
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"p00f/nvim-ts-rainbow", -- colored brackets
	}},

	{"mizlan/iswap.nvim", -- swapping of notes
		config = function() require("iswap").setup {autoswap = true} end,
		cmd = "ISwapWith"
	},
	{"Wansmer/treesj", -- split-join
		dependencies = "nvim-treesitter/nvim-treesitter" ,
		config = function () require("treesj").setup { use_default_keymaps = false } end,
		cmd = "TSJToggle",
	},
	{"cshuaimin/ssr.nvim", -- structural search & replace
		lazy = true,
		config = function() require("ssr").setup {
			keymaps = {close = "Q"},
		} end
	},

	-- LSP
	{"neovim/nvim-lspconfig", dependencies = {
		"williamboman/mason-lspconfig.nvim",
		"lvimuser/lsp-inlayhints.nvim", -- only temporarily needed, until https://github.com/neovim/neovim/issues/18086
		"ray-x/lsp_signature.nvim", -- signature hint
		"SmiteshP/nvim-navic", -- breadcrumbs
		"folke/neodev.nvim", -- lsp for nvim-lua config
		"b0o/SchemaStore.nvim", -- schemas for json-lsp
	}},

	-- Linting & Formatting
	{"jose-elias-alvarez/null-ls.nvim", dependencies = {
		"nvim-lua/plenary.nvim",
		"jayp0521/mason-null-ls.nvim",
	}},

	-- DAP
	{"mfussenegger/nvim-dap",
		dependencies = {
			"jayp0521/mason-nvim-dap.nvim",
			"theHamsta/nvim-dap-virtual-text",
			"rcarriga/nvim-dap-ui",
			"jbyuki/one-small-step-for-vimkind", -- lua debugger specifically for neovim config
		}
	},

	-- File Switching & File Operation
	{"chrisgrieser/nvim-genghis",
		dev = true,
		lazy = true,
		dependencies = "stevearc/dressing.nvim",
	},
	{"nvim-telescope/telescope.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"debugloop/telescope-undo.nvim",
		},
	},

	-- Terminal & Git
	{ "TimUntersberger/neogit",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = "Neogit",
		config = function () require("neogit").setup{
				disable_signs = true,
				integrations = {diffview = true},
		} end
	},
	{"metakirby5/codi.vim", cmd = {"Codi", "CodiNew", "CodiExpand"} }, -- only coderunner with virtual text
	{"akinsho/toggleterm.nvim",
		cmd = {"ToggleTerm", "ToggleTermSendVisualSelection"},
		config = function() require("toggleterm").setup() end
	},
	{"sindrets/diffview.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = {"DiffviewFileHistory", "DiffviewOpen"},
		config = function() require("diffview").setup {
			file_history_panel = {win_config = {height = 5}},
		} end,
	},

	-- EDITING-SUPPORT
	{"andymass/vim-matchup",
		init = function ()
			
		end
	},
	{"ja-ford/delaytrain.nvim",
		keys = {"h", "l", "x"},
		config = function ()
			require("delaytrain").setup {
				delay_ms = 1000, -- How long repeated usage of a key should be prevented
				grace_period = 7, -- How many repeated keypresses are allowed
				keys = { -- Which keys (in which modes) should be delayed
					["n"] = { "h", "l", "x" },
				},
			}
		end
	},

	{ "ThePrimeagen/refactoring.nvim",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		config = function () require("refactoring").setup() end,
	},
	{"ggandor/leap.nvim", event = "VeryLazy"},
	{ "unblevable/quick-scope",
		keys = {"f", "F", "t", "T"},
		init = function ()
			vim.g.qs_highlight_on_keys = {"f", "F", "t", "T"} -- needs to be enabled before
		end,
		config = function ()
			cmd.highlight { "def link QuickScopePrimary CurSearch", bang = true }
		end
	},
	{"kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async"}, -- better folding
	"kylechui/nvim-surround", -- surround operator
	{"gbprod/substitute.nvim", -- substitution & exchange operator
		lazy = true,
		config = function () require("substitute").setup() end,
	},
	"numToStr/Comment.nvim", -- comment operator
	{"mg979/vim-visual-multi", keys = {"<D-j>", {"<D-j>", mode = "x"}}},
	"Darazaki/indent-o-matic", -- auto-determine indents
	{ "chrisgrieser/nvim-recorder", -- better macros
		dev = true,
		keys = {"0", "9"},
		config = function ()
			require("recorder").setup {
				clear = true,
				logLevel = logTrace,
				mapping = {
					startStopRecording = "0",
					playMacro = "9",
					editMacro = "c0",
					switchSlot = "<C-0>",
				},
			}
		end,
	},
	{ "chrisgrieser/nvim-various-textobjs", dev = true, lazy = true }, -- custom textobjects
	{"nacro90/numb.nvim", -- line previews when ":n"
		config = function() require("numb").setup() end,
		keys = ":",
	},
	{"axieax/urlview.nvim",
		cmd = "UrlView",
		dependencies = "nvim-telescope/telescope.nvim",
		config = function() require("urlview").setup{
			default_picker = "telescope",
			default_action = "system",
			sorted = false,
		} end,
	},

	-- Filetype-specific
	{"mityu/vim-applescript", ft = "applescript"}, -- syntax highlighting
	{"hail2u/vim-css3-syntax", ft = "css"}, -- better syntax highlighting (until treesitter css looks decent…)
	{"iamcco/markdown-preview.nvim", ft = "markdown", build = "cd app && npm install"},
}
