return {
	-- EDITING-SUPPORT
	{ "numToStr/Comment.nvim" }, -- comment operator
	{ "kylechui/nvim-surround" },

	{ "mg979/vim-visual-multi", keys = { "<D-j>", { "<D-j>", mode = "x" } } },
	{ "chrisgrieser/nvim-various-textobjs", dev = true, lazy = true }, -- custom textobjects

	{
		"mizlan/iswap.nvim", -- swapping of nodes
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function() require("iswap").setup { autoswap = true } end,
		cmd = "ISwapWith",
	},
	{
		"Wansmer/treesj", -- split-join
		dependencies = "nvim-treesitter/nvim-treesitter",
		config = function() require("treesj").setup { use_default_keymaps = false } end,
		cmd = "TSJToggle",
	},
	-- TODO checkout later if they added support for more filetypes
	-- {
	-- 	"ckolkey/ts-node-action",
	-- 	dependencies = { "nvim-treesitter" },
	-- 	lazy = true,
	-- 	config = function() require("ts-node-action").setup() end,
	-- },
	{
		"cshuaimin/ssr.nvim", -- structural search & replace
		lazy = true,
		config = function()
			require("ssr").setup {
				keymaps = { close = "Q" },
			}
		end,
	},
	{
		"andymass/vim-matchup",
		init = function()
			vim.g.matchup_text_obj_enabled = 0
			vim.g.matchup_matchparen_enabled = 1 -- highlight
		end,
		event = "BufReadPost", -- other lazyloading methods do not seem to work
	},
	{
		"nacro90/numb.nvim", -- line previews when ":n"
		config = function() require("numb").setup() end,
		keys = ":",
	},
	{
		"ThePrimeagen/refactoring.nvim",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
		config = function() require("refactoring").setup() end,
	},
	{ "ggandor/leap.nvim", event = "VeryLazy" },
	{
		"unblevable/quick-scope",
		keys = { "f", "F", "t", "T" },
		init = function()
			vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" }
			vim.cmd.highlight { "def link QuickScopePrimary CurSearch", bang = true }
			vim.cmd.highlight { "QuickScopePrimary gui=underline", bang = true }
		end,
	},
	{
		"gbprod/substitute.nvim", -- substitution & exchange operator
		lazy = true,
		config = function() require("substitute").setup() end,
	},
	{
		"smjonas/duplicate.nvim",
		keys = { "yd", { "R", mode = "x" } },
		config = function()
			require("duplicate").setup {
				textobject = "yd", -- duplicate in normal mode, expects an operator
				textobject_visual_mode = "R", 
				textobject_cur_line = nil, 
			}
		end,
	},
}
