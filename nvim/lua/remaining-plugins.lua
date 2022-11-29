require("utils")
--------------------------------------------------------------------------------

-- netrw
g.netrw_browse_split = 0
g.netrw_list_hide = ".*\\.DS_Store$,^./$,^../$" -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner
g.netrw_liststyle = 3 -- tree style as default
g.netrw_winsize = 30 -- width
g.netrw_localcopydircmd = "cp -r" -- so copy work with directories
cmd [[highlight! def link netrwTreeBar IndentBlankLineChar]]

--------------------------------------------------------------------------------

-- undotree
-- also requires persistent undos in the options
g.undotree_WindowLayout = 4 -- split to the right
g.undotree_SplitWidth = 25
g.undotree_DiffpanelHeight = 10

g.undotree_DiffCommand = "diff --unified"
g.undotree_DiffAutoOpen = 0

g.undotree_SetFocusWhenToggle = 1
g.undotree_ShortIndicators = 1 -- short relative dates
g.undotree_HelpLine = 1 -- 0 = hides the "Press ? for help"

function g.Undotree_CustomMap()
	local opts = {buffer = true, silent = true, nowait = true}
	keymap("n", "<C-j>", "<Plug>UndotreePreviousState", opts)
	keymap("n", "<C-k>", "<Plug>UndotreeNextState", opts)
	keymap("n", "d", "<Plug>UndotreeDiffToggle", opts)
	keymap("n", "J", "7j", opts)
	keymap("n", "K", "7k", opts)
	setlocal("list", false)
end
