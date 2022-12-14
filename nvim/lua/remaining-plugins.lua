require("utils")
--------------------------------------------------------------------------------

-- netrw
g.netrw_browse_split = 0
g.netrw_list_hide = ".*\\.DS_Store$,^./$,^../$" -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner
g.netrw_liststyle = 3 -- tree style as default
g.netrw_winsize = 30 -- width
g.netrw_localcopydircmd = "cp -r" -- so copy work with directories
cmd.highlight {"def link netrwTreeBar IndentBlankLineChar", bang = true}

--------------------------------------------------------------------------------
-- Mundo
g.mundo_width = 30
g.mundo_preview_height = 15
g.mundo_preview_bottom = 0
g.mundo_auto_preview = 1
g.mundo_right = 1 -- right side, not left

augroup("MundoConfig", {})
autocmd("FileType", {
	group = "MundoConfig",
	pattern = {"Mundo", "MundoDiff"},
	callback = function()
		keymap("n", "-", "/", {remap = true, buffer = true})
		keymap("n", "q", ":MundoToggle<CR>", {remap = true, buffer = true, nowait = true})
	end
})

--------------------------------------------------------------------------------
-- Discord Rich Presence
require("presence"):setup {
	blacklist = {}, -- A list of strings or Lua patterns that disable Rich Presence if the current file name, path, or workspace matches
	show_time = false,
}

--------------------------------------------------------------------------------

-- Cycle Buffer
require("cybu").setup {
	display_time = 1000,
	position = {
		anchor = "bottomcenter",
		max_win_height = 12,
		vertical_offset = 3,
	},
	style = {
		border = borderStyle,
		padding = 7,
		path = "tail",
		hide_buffer_id = true,
		highlights = {
			current_buffer = "CursorLine",
			adjacent_buffers = "Normal",
		},
	},
	behavior = {
		mode = {
			default = {
				switch = "immediate",
				view = "paging",
			},
		},
	},
	exclude = {},
}
