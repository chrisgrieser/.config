return {
	-- EDITING-SUPPORT
	"numToStr/Comment.nvim", -- comment operator
	"kylechui/nvim-surround",

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
		keys = {
			{ "9", nil, desc = " Play Macro" },
			{ "0", nil, desc = " Start/Stop Recording" },
			{ "8", nil, desc = "/ Breakpoint" },
		},
		config = function()
			require("recorder").setup {
				clear = true,
				logLevel = vim.log.levels.TRACE,
				mapping = {
					startStopRecording = "0",
					playMacro = "9",
					editMacro = "c0",
					switchSlot = "<C-0>",
					addBreakPoint = "8",
				},
				-- if true, `addBreakPoint` will map to `dap.toggle_breakpoint()` outside
				-- a recording. During a recording, it will add a macro breakpoint instead.
				dapBreakpoint = true,
			}
			local topSeparators = isGui() and { left = "", right = "" } or { left = "", right = "" }
			require("lualine").setup {
				winbar = {
					lualine_y = {
						{ require("recorder").displaySlots, section_separators = topSeparators },
					},
					lualine_z = {
						{ require("recorder").recordingStatus, section_separators = topSeparators },
					},
				},
			}
		end,
	},
}
