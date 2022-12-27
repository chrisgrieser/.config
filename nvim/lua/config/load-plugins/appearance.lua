return {

	{"m-demare/hlargs.nvim", -- highlight function args
		config = function() require("hlargs").setup() end,
		event = "VeryLazy",
	},

	{"lukas-reineke/indent-blankline.nvim", config = function ()
require("indent_blankline").setup {
	show_current_context = true,
	use_treesitter = true,
	strict_tabs = false,
	filetype_exclude = {},
}
	end},

	{"lewis6991/gitsigns.nvim", config = function ()
		
	end} ,

	-- scrollbar
	{"lewis6991/satellite.nvim", config = function ()
		
require("satellite").setup {
	current_only = true,
	winblend = 30,
	excluded_filetypes = {},
	handlers = {
		marks = { enable = false },
	},
}

	end},

	{"xiyaowong/virtcolumn.nvim", event = "VeryLazy"}, -- nicer colorcolumn
	{ "anuvyklack/windows.nvim", dependencies = "anuvyklack/middleclass" }, -- auto-resize splits
	{"stevearc/dressing.nvim",
		dependencies = { "hrsh7th/nvim-cmp", "hrsh7th/cmp-omni" }, -- omni for autocompletion in input prompts
	},
	{"ghillb/cybu.nvim", -- Cycle Buffers
		dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
		config = function ()
require("cybu").setup {
	display_time = 1000,
	position = {
		anchor = "bottomcenter",
		max_win_height = 12,
		vertical_offset = 3,
	},
	style = {
		border = borderStyle,
		padding = 7,
		path = "tail",
		hide_buffer_id = true,
		highlights = {
			current_buffer = "CursorLine",
			adjacent_buffers = "Normal",
		},
	},
	behavior = {
		mode = {
			default = {
				switch = "immediate",
				view = "paging",
			},
		},
	},
	exclude = {},
}
		end
	},
}

--------------------------------------------------------------------------------
-- virtual color column --- '│'
g.virtcolumn_char = "║"

--------------------------------------------------------------------------------
-- GUTTER
require("gitsigns").setup {
	max_file_length = 10000,
	preview_config = { border = borderStyle },
}

--------------------------------------------------------------------------------
-- AUTO-RESIZE WINDOWS/SPLITS
require("windows").setup {
	autowidth = {
		enable = true,
		winwidth = 0.7, -- active window gets 70% of total width
	},
	ignore = {
		filetype = { "netrw" }, -- BUG https://github.com/anuvyklack/windows.nvim/issues/30
	},
}

--------------------------------------------------------------------------------
-- DRESSING
require("dressing").setup {
	input = {
		border = borderStyle,
		relative = "win",
		max_width = 50, -- length git commit msg
		min_width = 50,
		win_options = {
			sidescrolloff = 0,
			winblend = 0,
		},
		insert_only = false, -- enable normal mode
		mappings = {
			n = { ["q"] = "Close" },
		},
	},
	select = {
		backend = { "builtin" }, -- Priority list of preferred vim.select implementations
		trim_prompt = true, -- Trim trailing `:` from prompt
		builtin = {
			border = borderStyle,
			relative = "cursor",
			max_width = 60,
			min_width = 18,
			max_height = 12,
			min_height = 4,
			mappings = {
				["q"] = "Close",
				["Esc"] = "Close",
			},
		},
	},
}
