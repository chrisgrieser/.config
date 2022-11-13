require("utils")
--------------------------------------------------------------------------------

-- netrw
g.netrw_browse_split = 0
g.netrw_list_hide = ".*\\.DS_Store$,^./$,^../$" -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner
g.netrw_liststyle = 3 -- tree style as default
g.netrw_winsize = 30
g.netrw_localcopydircmd = "cp -r" -- so copy work with directories
cmd [[highlight! def link netrwTreeBar IndentBlankLineChar]]

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
-- Diffview
local actions = require("diffview.actions")
require("diffview").setup {
	view = {
		file_history = {layout = "diff2_horizontal"},
	},
	file_history_panel = {
		win_config = { height = 8, },
	},
	keymaps = {
		view = {
			["<tab>"] = actions.select_next_entry, 
			["<s-tab>"] = actions.select_prev_entry, 
		},
		file_history_panel = {
			["o"] = actions.options, -- Open the option panel
		},
		option_panel = {
			["<CR>"] = actions.select_entry,
		},
	},
}
