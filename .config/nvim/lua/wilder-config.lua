-- INFO: "UpdateRemotePlugins" may be necessary to make wilder work correctly
-- https://github.com/gelguy/wilder.nvim/issues/158

local wilder = require('wilder')
wilder.setup({modes = {':', '/', '?'}})
wilder.set_option('renderer', wilder.popupmenu_renderer(
	wilder.popupmenu_border_theme({
		highlighter = wilder.basic_highlighter(),
		min_width = '30%',
		min_height = '30%',
		max_height = '50%',
		left = {' ', wilder.popupmenu_devicons()},
		reverse = 0,
		border = 'rounded',
		highlights = {
			accent = wilder.make_hl('WilderAccent', 'Pmenu', {
				{foreground = 'Magenta'}, -- term
				{foreground = 'Magenta'}, -- cterm
				{foreground = '#f4468f'} -- gui
			}),
		},
	})
))



