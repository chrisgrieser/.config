-- stylua: ignore
return {

	-- Package Management
	{"williamboman/mason.nvim", dependencies = "RubixDev/mason-update-all"},

	-- Themes
	-- "savq/melange", -- like Obsidian's Primary color scheme
	"folke/tokyonight.nvim",
	"EdenEast/nightfox.nvim",
	-- "nyoom-engineering/oxocarbon.nvim",
	-- "rebelot/kanagawa.nvim",

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
	{"m-demare/hlargs.nvim", -- highlight function args
		config = function() require("hlargs").setup() end,
	},
	{"Wansmer/treesj", -- split-join
		dependencies = "nvim-treesitter/nvim-treesitter" ,
		config = function () require("treesj").setup { use_default_keymaps = false } end,
		cmd = "TSJToggle",
	},
	{"cshuaimin/ssr.nvim", -- structural search & replace
		commit = "4304933", -- TODO: update to newest version with nvim 0.9 https://github.com/cshuaimin/ssr.nvim/issues/11#issuecomment-1340671193
		pin = true,
		config = function()
			require("ssr").setup {
				keymaps = {close = "Q"},
			}
		end
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
		lazy = true,
		dependencies = {
			"jayp0521/mason-nvim-dap.nvim",
			"theHamsta/nvim-dap-virtual-text",
			"rcarriga/nvim-dap-ui",
			"jbyuki/one-small-step-for-vimkind", -- lua debugger specifically for neovim config
		}
	},

	-- Completion & Suggestion
	{"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-buffer", -- completion sources
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"dmitmel/cmp-cmdline-history",
			"hrsh7th/cmp-emoji",
			{"chrisgrieser/cmp-nerdfont", dev = true},
			"tamago324/cmp-zsh",
			"ray-x/cmp-treesitter",
			"hrsh7th/cmp-nvim-lsp", -- lsp
			"L3MON4D3/LuaSnip", -- snippet engine
			"saadparwaiz1/cmp_luasnip", -- adapter for snippet engine
			"windwp/nvim-autopairs", -- auto pair brackets/quotes
		}
	},

	-- AI-Support
	{ "tzachar/cmp-tabnine",
		build = "./install.sh",
		dependencies = "hrsh7th/nvim-cmp",
	},
	{"jackMort/ChatGPT.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		cmd = {"ChatGPTEditWithInstructions", "ChatGPT"}
	},

	-- Appearance
	"lukas-reineke/indent-blankline.nvim", -- indentation guides
	"nvim-lualine/lualine.nvim", -- status line
	"lewis6991/gitsigns.nvim", -- gutter signs
	{"rcarriga/nvim-notify", event = "VeryLazy"}, -- notifications
	"uga-rosa/ccc.nvim", -- color previews & color utilities
	"dstein64/nvim-scrollview", -- "petertriho/nvim-scrollbar" has more features, but is also more buggy atm
	{"anuvyklack/windows.nvim", dependencies = "anuvyklack/middleclass"}, -- auto-resize splits
	"xiyaowong/virtcolumn.nvim", -- nicer color column

	-- File Switching & File Operation
	{"stevearc/dressing.nvim",
		event = "VeryLazy",
		dependencies = {
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-omni", -- for autocompletion in input prompts
	}},
	{"chrisgrieser/nvim-genghis",
		dev = true,
		lazy = true,
		dependencies = "stevearc/dressing.nvim",
	},
	{"nvim-telescope/telescope.nvim",
		lazy = true,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"debugloop/telescope-undo.nvim",
		},
	},
	{"ghillb/cybu.nvim", -- Cycle Buffers
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim"},
		keys = "<BS>",
	},

	-- Terminal & Git
	{"akinsho/toggleterm.nvim",
		cmd = {"ToggleTerm", "ToggleTermSendVisualSelection"},
		config = function() require("toggleterm").setup() end
	},
	{"sindrets/diffview.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = {"DiffviewFileHistory", "DiffviewOpen"},
		config = function() require("diffview").setup {
			file_history_panel = {win_config = {height = 4}},
		} end,
	},
	{"ruifm/gitlinker.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		lazy = true,
		config = function() require("gitlinker").setup {
			mappings = nil,
			opts = {print_url = false},
		} end,
	},

	-- EDITING-SUPPORT
	"kylechui/nvim-surround", -- surround operator
	"gbprod/substitute.nvim", -- substitution & exchange operator
	"numToStr/Comment.nvim", -- comment operator
	{"mg979/vim-visual-multi", keys = "<D-j>"},
	"Darazaki/indent-o-matic", -- auto-determine indents
	{"gbprod/yanky.nvim"}, -- register manager
	{"chrisgrieser/nvim-recorder", dev = true}, -- better macros
	{"chrisgrieser/nvim-various-textobjs", dev = true}, -- custom textobjects
	{"nacro90/numb.nvim", -- line previews when ":n"
		config = function() require("numb").setup() end,
		keys = ":",
	},
	{"kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async"}, -- better folding
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
	{"bennypowers/nvim-regexplainer",
		ft = {"javascript", "typescript"},
		dependencies = {"nvim-treesitter/nvim-treesitter", "MunifTanjim/nui.nvim"},
		-- INFO: config set in javascript/typescript ftplugin, since not working
		-- from here
	},

}
