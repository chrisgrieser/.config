require("utils")
--------------------------------------------------------------------------------

-- GUI
-- keep using terminal colorscheme in the Terminal, for consistency with Alacritty
if fn.has('gui_running') == 1 then -- https://www.reddit.com/r/neovim/comments/u1998d/comment/i4asi0h/?utm_source=share&utm_medium=web2x&context=3
	cmd[[colorscheme tokyonight]]
end

--------------------------------------------------------------------------------
-- UI ELEMENTS
-- partially overriden when using a theme

-- Ruler
cmd[[highlight ColorColumn ctermbg=DarkGrey guibg=black]] -- https://www.reddit.com/r/neovim/comments/me35u9/lua_config_to_set_highlight/

-- Active Line
cmd[[highlight CursorLine term=none cterm=none guibg=black ctermbg=black]]

-- Annotations
cmd[[match myAnnotations /INFO/ ]]
cmd[[highlight def link myAnnotations Todo]] -- use same color as "TODO"

-- Current Word Highlight (from Coc)
cmd[[highlight CocHighlightText term=underdotted cterm=underdotted]]

-- TreeSitter Context Line
cmd[[highlight TreesitterContext ctermbg=black guibg=black]]

-- Indentation Lines
cmd[[highlight IndentBlanklineChar ctermfg=DarkGrey guifg=DarkGrey]]

-- leading spaces
-- https://vi.stackexchange.com/questions/26825/conceal-markdown-links-and-extensions
cmd[[highlight WhiteSpaceBol guibg=DarkGrey ctermbg=DarkGrey]]
cmd[[match WhiteSpaceBol /^ \+/]]

-- Comments
cmd[[highlight Comment ctermfg=grey]] -- since they badly colored in the terminal with some themes

-- Underline URLs
-- (must come after Comments so URLs in comments are displayed correctly)
cmd[[match urls /http[s]\?:\/\/[[:alnum:]%\/_#.-]*/ ]]
cmd[[highlight urls cterm=underline]]

-- Popups
cmd[[highlight Pmenu ctermbg=Grey]]

--------------------------------------------------------------------------------

-- GUTTER
-- Sign Column ( = Gutter)
cmd[[highlight clear SignColumn]] -- transparent

-- Git Gutter
-- https://github.com/airblade/vim-gitgutter#signs-colours-and-symbols
cmd[[highlight GitGutterAdd    guifg=Green ctermfg=Green]]
cmd[[highlight GitGutterChange guifg=Yellow ctermfg=Yellow]]
cmd[[highlight GitGutterDelete guifg=Red ctermfg=Red]]
g.gitgutter_sign_priority = 9 -- lower to not overwrite when in conflict with other icons

-- INFO: Look of the Coc Gutter indicators is set in coc-settings.json

--------------------------------------------------------------------------------

-- STATUS LINE
-- status bar
opt.showcmd = true -- keychords pressed
opt.showmode = false -- don't show "-- Insert --"
-- opt.cmdheight = 0 -- hide message line if there is no content (requires nvim 0.8)
-- glitches: https://github.com/nvim-lualine/lualine.nvim/issues/853

-- deactivate in firenvim
if g.started_by_firenvim then
	opt.laststatus = 0
else
	opt.laststatus = 2
end

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

