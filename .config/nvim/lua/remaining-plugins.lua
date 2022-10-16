require("utils")
--------------------------------------------------------------------------------

-- netrw
g.netrw_list_hide= '.*\\.DS_Store$,^./$' -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner

-- Sneak
cmd[[let g:sneak#s_next = 1]] -- "s" repeats, like with clever-f
cmd[[let g:sneak#use_ic_scs = 1]] -- smart case
cmd[[let g:sneak#prompt = '👟 ']]

-- Emmet: use only in CSS insert mode
g.user_emmet_install_global = 0
g.user_emmet_mode='i'
autocmd("FileType", {
	pattern = "css",
	command = "EmmetInstall"
})

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

-- Symbol outline
require("symbols-outline").setup{
	width = 40,
	autofold_depth = 2,
	keymaps = {
		close = {"<Esc>", "gS"}, -- q mapped via filetype-spefic binding for "nowait"
		goto_location = "<CR>",
		focus_location = "f",
		toggle_preview = "p",
		rename_symbol = "r",
		code_actions = "a",
		fold = "h",
		unfold = "l",
		fold_all = "H",
		unfold_all = "L",
	},
	lsp_blacklist = {},
	symbol_blacklist = {"Enum", "EnumMember"},
}


require("nvim-surround").setup{
	move_cursor = false,
	keymaps = {
		insert = "<C-g>s",
		visual = "s",
	},
}
