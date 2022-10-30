require("utils")
--------------------------------------------------------------------------------

-- netrw
g.netrw_browse_split = 0
g.netrw_list_hide = '.*\\.DS_Store$,^./$,^../$' -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner
g.netrw_liststyle = 3 -- tree style as default
g.netrw_winsize = 30
g.netrw_localcopydircmd = 'cp -r' -- makes copy work with directories
cmd[[highlight! def link netrwTreeBar IndentBlankLineChar]]

-- Sneak
-- cmd[[let g:sneak#s_next = 1]] -- "s" repeats, like with clever-f
-- cmd[[let g:sneak#use_ic_scs = 1]] -- smart case
-- cmd[[let g:sneak#prompt = '👟 ']]

-- Hop.nvim
require('hop').setup { multi_windows = true }

-- indention lines
g.indent_blankline_filetype_exclude = {"undotree"}
g.indent_blankline_strict_tabs = true

-- undotree
-- also requires persistent undos in the options
g.undotree_WindowLayout = 3 -- split to the right
g.undotree_SplitWidth = 30
g.undotree_DiffAutoOpen = 0
g.undotree_SetFocusWhenToggle = 1
g.undotree_ShortIndicators = 1 -- for the relative date
g.undotree_HelpLine = 0 -- 0 hides the "Press ? for help"
cmd[[ function! g:Undotree_CustomMap()
nmap <buffer> <C-j> <plug>UndotreePreviousState
nmap <buffer> <C-k> <plug>UndotreeNextState
nmap <buffer> J jjjjjjj
nmap <buffer> K 7k
nmap <buffer> U <plug>UndotreeRedo
endfunc
]]

require('indent-o-matic').setup {
	max_lines = 2048,
	standard_widths = { 2, 4, 8 }, -- Space indentations that should be detected
	skip_multiline = true, -- Skip multi-line comments and strings (more accurate detection but less performant)
}
