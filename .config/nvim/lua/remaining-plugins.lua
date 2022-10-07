-- netrw
g.netrw_list_hide= '.*\\.DS_Store$,^./$' -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner

-- wildfire
-- https://github.com/gcmt/wildfire.vim#advanced-usage
g.wildfire_objects = {"iw", "iW", "i'", 'i"', "i)", "i]", "i}", "ii", "aI", "ip", "ap"}

-- Sneak
cmd[[let g:sneak#s_next = 1]] -- "s" repeats, like with clever-f
cmd[[let g:sneak#use_ic_scs = 1]] -- smart case
cmd[[let g:sneak#prompt = '👟']] -- the sneak in command line :P

-- Emmet: use only in CSS insert mode
g.user_emmet_install_global = 0
autocmd("FileType", {
	pattern = "css",
	command = "EmmetInstall"
})
g.user_emmet_mode='i'

-- comments.nvim
require("Comment").setup({
	extra = {
		above = 'gab', -- [ab]ove
		eol = 'gaf', -- [af]ter
	},
	mappings = { basic = false } -- since the basic one's are done with commentary
})

-- undotree
g.undotree_WindowLayout = 3
g.undotree_SplitWidth = 40
g.undotree_DiffAutoOpen = 0 
g.undotree_SetFocusWhenToggle = 1
g.undotree_ShortIndicators = 1
g.undotree_HelpLine = 1 -- 0 hides the "Press ? for help"
