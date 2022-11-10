require("utils")
--------------------------------------------------------------------------------

-- netrw
g.netrw_browse_split = 0
g.netrw_list_hide = ".*\\.DS_Store$,^./$,^../$" -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner
g.netrw_liststyle = 3 -- tree style as default
g.netrw_winsize = 30
g.netrw_localcopydircmd = "cp -r" -- makes copy work with directories
cmd [[highlight! def link netrwTreeBar IndentBlankLineChar]]

--------------------------------------------------------------------------------

-- Hop.nvim
require("hop").setup {
	uppercase_labels = true,
	multi_windows = true,
	hint_position = require "hop.hint".HintPosition.END,
	hint_offset = 0,
}

--------------------------------------------------------------------------------

-- undotree
-- also requires persistent undos in the options
g.undotree_WindowLayout = 3 -- split to the right
g.undotree_SplitWidth = 30
g.undotree_DiffAutoOpen = 0
g.undotree_SetFocusWhenToggle = 1
g.undotree_ShortIndicators = 1 -- for the relative date
g.undotree_HelpLine = 0 -- 0 hides the "Press ? for help"

function g.Undotree_CustomMap()
	local opts = {buffer = true, silent = true}
	keymap("n", "<C-j>", "<Plug>UndotreePreviousState", opts)
	keymap("n", "<C-k>", "<Plug>UndotreeNextState", opts)
	keymap("n", "J", "7j", opts)
	keymap("n", "K", "7k", opts)
	setlocal("list", false)
end

--------------------------------------------------------------------------------

require("indent-o-matic").setup {
	max_lines = 2048,
	standard_widths = {2, 4, 8}, -- Space indentations that should be detected
	skip_multiline = true, -- Skip multi-line comments and strings (more accurate detection but less performant)
}

--------------------------------------------------------------------------------

-- Quick Scope
g.qs_highlight_on_keys = {"f", "F", "t", "T"}
g.qs_max_chars = 200
cmd [[highlight def link QuickScopePrimary CurSearch]]

--------------------------------------------------------------------------------
-- Calendar
g.calendar_google_calendar = 1
g.calendar_google_api_key = "..."
g.calendar_google_client_id = "....apps.googleusercontent.com"
g.calendar_google_client_secret = "..."
g.calendar_first_day = "monday"

--------------------------------------------------------------------------------
-- Diffview
local actions = require("diffview.actions")
require("diffview").setup {
	view = {
		-- Available layouts: 'diff1_plain' |'diff2_horizontal' |'diff2_vertical' |'diff3_horizontal' |'diff3_vertical' |'diff3_mixed' |'diff4_mixed' For more info, see ':h diffview-config-view.x.layout'.
		file_history = {layout = "diff2_horizontal"},
	},
	file_history_panel = {
		win_config = {
			position = "bottom",
			height = 10,
		},
	},
	keymaps = {
		view = {
			-- The `view` bindings are active in the diff buffers, only when the current
			-- tabpage is a Diffview.
			["<tab>"] = actions.select_next_entry, -- Open the diff for the next file
			["<s-tab>"] = actions.select_prev_entry, -- Open the diff for the previous file
		},
		file_history_panel = {
			["o"] = actions.options, -- Open the option panel
		},
		option_panel = {
			["<CR>"] = actions.select_entry,
		},
	},
}
