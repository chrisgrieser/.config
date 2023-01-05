return {
	-- EDITING-SUPPORT
	"numToStr/Comment.nvim", -- comment operator
	{ "mg979/vim-visual-multi", keys = { "<D-j>", { "<D-j>", mode = "x" } } },
	{ "chrisgrieser/nvim-various-textobjs", dev = true, lazy = true }, -- custom textobjects
	"kylechui/nvim-surround",

	{
		"mizlan/iswap.nvim", -- swapping of notes
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
		init = function() vim.g.qs_highlight_on_keys = { "f", "F", "t", "T" } end,
		config = function() vim.cmd.highlight { "def link QuickScopePrimary CurSearch", bang = true } end,
	},
	{
		"gbprod/substitute.nvim", -- substitution & exchange operator
		lazy = true,
		config = function() require("substitute").setup() end,
	},
	{
		"chrisgrieser/nvim-recorder", -- better macros
		dev = true,
		keys = { "0", "9" },
		config = function()
			require("recorder").setup {
				clear = true,
				logLevel = logTrace,
				mapping = {
					startStopRecording = "0",
					playMacro = "9",
					editMacro = "c0",
					switchSlot = "<C-0>",
					addBreakPoint = "!",
				},
			}
		end,
	},
	{
		-- INFO has to be disabled during macro execution https://github.com/ja-ford/delaytrain.nvim/issues/8
		"ja-ford/delaytrain.nvim",
		enabled = false,
		keys = { "h", "l" },
		config = function()
			require("delaytrain").setup {
				delay_ms = 1000, -- How long repeated usage of a key should be prevented
				grace_period = 7, -- How many repeated keypresses are allowed
				keys = { -- Which keys (in which modes) should be delayed
					["nv"] = { "h", "l" },
				},
			}
		end,
	},
}
