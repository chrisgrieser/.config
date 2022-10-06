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
opt.termguicolors = true -- required for colorizer plugins

require("colorizer").setup {}

autocmd("FileType", {
	pattern = {"css"},
	callback = function ()
		require("colorizer").attach_to_buffer(0, {
			mode = "background",
			css = true,
		})
	end
})

