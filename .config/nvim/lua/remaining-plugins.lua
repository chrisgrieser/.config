-- netrw
g.netrw_list_hide= '.*\\.DS_Store$,^./$' -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner

-- wildfire
-- https://github.com/gcmt/wildfire.vim#advanced-usage
g.wildfire_objects = {"iw", "iW", "i'", 'i"', "i)", "i]", "i}", "ii", "aI", "ip"}

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

-- Wilder
-- INFO: "UpdateRemotePlugins" may be necessary https://github.com/gelguy/wilder.nvim/issues/158

local wilder = require('wilder')
wilder.setup({modes = {':', '/', '?'}})
wilder.set_option('renderer', wilder.popupmenu_renderer(
	wilder.popupmenu_border_theme({
		highlighter = wilder.basic_highlighter(),
		min_width = '30%',
		min_height = '50%',
		max_height = '50%',
		left = {' ', wilder.popupmenu_devicons()},
		reverse = 0,
		border = 'rounded',
		highlights = {
			accent = wilder.make_hl('WilderAccent', 'Pmenu', {{foreground = 'Magenta'}, {foreground = 'Magenta'}, {foreground = '#f4468f'}}),
		},
	})
))

cmd[[highlight WilderAccent ctermfg=LightMagenta]]



