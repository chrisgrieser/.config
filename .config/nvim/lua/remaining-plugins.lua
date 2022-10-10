-- netrw
g.netrw_list_hide= '.*\\.DS_Store$,^./$' -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner

-- Sneak
cmd[[let g:sneak#s_next = 1]] -- "s" repeats, like with clever-f
cmd[[let g:sneak#use_ic_scs = 1]] -- smart case
cmd[[let g:sneak#prompt = '👟']] -- the sneak in command line :P

-- Emmet: use only in CSS insert mode
g.user_emmet_install_global = 0
g.user_emmet_mode='i'
autocmd("FileType", {
	pattern = "css",
	command = "EmmetInstall"
})

-- indention lines
g.indent_blankline_filetype_exclude = {"undotree"}

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
	endfunc ]]


-- use vim.notify for all messages
vim.notify = require("notify")



require("symbols-outline").setup{
	highlight_hovered_item = true,
	show_guides = false,
	auto_preview = false,
	position = 'right',
	width = 30,
	show_symbol_details = false,
	autofold_depth = 1,
	auto_unfold_hover = true,
	wrap = false,
	keymaps = {
		goto_location = "<CR>",
		focus_location = "f",
		toggle_preview = "p",
		rename_symbol = "r",
		code_actions = "a",
		fold = "l",
		unfold = "h",
		fold_all = "L",
		unfold_all = "H",
	},
	lsp_blacklist = {},
	symbol_blacklist = {},
}
