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

-- whichkey
opt.timeoutlen = 1000 -- controls when whichkey shows up
require("which-key").setup {
	plugins = {
		marks = true, -- shows a list of your marks on ' and `
		registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
		presets = {
			operators = true,
			motions = true,
			text_objects = true,
			windows = true, -- default bindings on <c-w>
			nav = true, -- misc bindings to work with windows
			z = true, -- bindings for folds, spelling and others prefixed with z
			g = true, -- bindings for prefixed with g
		},
	},
	-- add operators that will trigger motion and text object completion
	-- to enable all native operators, set the preset / operators plugin above
	operators = {
		gc = "Comment",
		['ö'] = "Override",
	},
	key_labels = {
		["<space>"] = "␣",
		["<cr>"] = "↵",
		["<tab>"] = "↹",
		["<BS>"] = "⌫",
	},
	icons = {
		breadcrumb = "➜", -- symbol used in the command line area that shows your active key combo
		separator = ":", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	},
	popup_mappings = {
		scroll_down = '<c-d>', -- binding to scroll down inside the popup
		scroll_up = '<c-u>', -- binding to scroll up inside the popup
	},
	window = {
		border = borderStyle,
		position = "bottom", -- bottom, top
		margin = { 0, 0, 0, 0 },
		padding = { 0, 0, 0, 0 },
	},
	layout = {
		height = { min = 5, max = 20 }, -- min and max height of the columns
		width = { min = 20, max = 50 }, -- min and max width of the columns
		spacing = 2, -- spacing between columns
		align = "left", -- align columns left, center or right
	},
	show_help = true, -- show help message on the command line when the popup is visible
	triggers = "auto", -- automatically setup triggers
	-- triggers = {"<leader>"} -- or specify a list manually
	triggers_blacklist = {
		-- list of mode / prefixes that should never be hooked by WhichKey
		-- this is mostly relevant for key maps that start with a native binding
		-- most people should not need to change this
		i = { "j", "k" },
		v = { "j", "k" },
	},

}
