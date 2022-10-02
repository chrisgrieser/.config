require("utils")
--------------------------------------------------------------------------------
-- GUI
-- keep using terminal colorscheme in the Terminal, for consistency with Alacritty
if fn.has('gui_running') == 1 then -- https://www.reddit.com/r/neovim/comments/u1998d/comment/i4asi0h/?utm_source=share&utm_medium=web2x&context=3
	cmd[[colorscheme tokyonight]]
else
	cmd[[highlight clear Pmenu]]
end

--------------------------------------------------------------------------------
-- UI ELEMENTS
-- partially overriden when using a theme

-- Ruler
cmd[[highlight ColorColumn ctermbg=DarkGrey guibg=black]] -- https://www.reddit.com/r/neovim/comments/me35u9/lua_config_to_set_highlight/

-- Active Line
cmd[[highlight CursorLine term=none cterm=none guibg=black ctermbg=black]]

-- Current Word Highlight (from Coc)
cmd[[highlight CocHighlightText term=underdotted cterm=underdotted]]

-- TreeSitter Context Line
cmd[[highlight TreesitterContext guibg=black]]

-- Indentation Lines
cmd[[highlight IndentBlanklineChar ctermfg=DarkGrey guifg=DarkGrey]]

-- Comments
cmd[[highlight Comment ctermfg=grey]]

-- leading spaces
-- https://vi.stackexchange.com/questions/26825/conceal-markdown-links-and-extensions
cmd[[highlight WhiteSpaceBol guibg=DarkGrey ctermbg=DarkGrey]]
cmd[[match WhiteSpaceBol /^ \+/]]

-- Annotations INFO
cmd[[highlight def link myAnnotations Todo]] -- use same color as "TODO"
cmd[[2match myAnnotations /INFO/ ]]

-- Underline URLs
cmd[[highlight urls cterm=underline]]
cmd[[3match urls /http[s]\?:\/\/[[:alnum:]%\/_#.-]*/ ]]

-- TODO: figure out how to use multiple match patterns, not
--------------------------------------------------------------------------------

-- GUTTER
-- Sign Column ( = Gutter)
cmd[[highlight clear SignColumn]] -- transparent

-- Git Gutter
cmd[[highlight GitGutterAdd    guifg=Green  ctermfg=Green]]
cmd[[highlight GitGutterChange guifg=Yellow ctermfg=Yellow]]
cmd[[highlight GitGutterDelete guifg=Red    ctermfg=Red]]
g.gitgutter_sign_added = '│'
g.gitgutter_sign_modified = '│'
g.gitgutter_sign_removed = '␥'
g.gitgutter_sign_removed_first_line = '␥'
g.gitgutter_sign_removed_above_and_below = '␥'
g.gitgutter_sign_modified_removed = '│'
g.gitgutter_sign_priority = 9 -- lower to not overwrite when in conflict with other icons

-- INFO: Coc Gutter indicators set in coc-settings.json

--------------------------------------------------------------------------------

-- STATUS LINE

-- Lua Line
local function alternateFile()
	local altFile = api.nvim_exec('echo expand("#:t")', true)
	local curFile = api.nvim_exec('echo expand("%:t")', true)
	if altFile == curFile then return "" end
	return "# "..altFile
end

require('lualine').setup {
	sections = {
		lualine_a = {{ 'mode', fmt = function(str) return str:sub(1,1) end }},
		lualine_b = {{'filename', file_status = false, fmt = function(str) return "%% "..str end}}, -- "%" is lua's escape character and therefore needs to be escaped itself
		lualine_c = {{ alternateFile }},
		lualine_x = {''},
		lualine_y = {'diagnostics'},
		lualine_z = {'location', 'progress'}
	},
	options = {
		theme  = 'auto',
		component_separators = { left = '', right = ''},
		section_separators = { left = '', right = ''},
	},
}

