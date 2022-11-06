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
	keymap("n", "<C-j>", "<plug>UndotreePreviousState", {buffer = true})
	keymap("n", "<C-k>", "<plug>UndotreeNextState", {buffer = true})
	keymap("n", "J", "jjjjjjj", {buffer = true})
	keymap("n", "K", "7k", {buffer = true})
	keymap("n", "U", "<plug>UndotreeRedo", {buffer = true})
end

--------------------------------------------------------------------------------

require("indent-o-matic").setup {
	max_lines = 2048,
	standard_widths = {2, 4, 8}, -- Space indentations that should be detected
	skip_multiline = true, -- Skip multi-line comments and strings (more accurate detection but less performant)
}

--------------------------------------------------------------------------------
