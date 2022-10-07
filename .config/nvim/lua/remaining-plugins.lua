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

-- registers.nvim
require("registers").setup({
	show = '*"0123456789abcdefghijklmnopqrstuvwxy',
	show_empty = false,
	window = {
		max_width = 50,
		border = "rounded",
		transparency = 0,
	},
})

-- comments.nvim
require("Comment").setup({
	extra = { eol = "gcA" } -- so the binding does not require a shift...
})

--------------------------------------------------------------------------------
opt.termguicolors = true

local ccc = require("ccc")
ccc.setup({
	highlighter = { auto_enable = true },
	inputs = { ccc.input.hsl, ccc.input.rgb },
	outputs = { ccc.output.css_hsl, ccc.output.css_rgb }
	convert = {
	{ ccc.picker.hex, ccc.output.css_rgb },
	{ ccc.picker.css_rgb, ccc.output.css_hsl },
	{ ccc.picker.css_hsl, ccc.output.hex },
}

})

keymap("n", "<leader>#", ":CccPick<CR>")
-- #355048 
