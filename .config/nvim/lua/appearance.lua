require("utils")
-- see also gui-settings.lua

--------------------------------------------------------------------------------
-- UI ELEMENTS

-- cursor
opt.guicursor = "n-sm:block,i-ci-c-ve:ver25,r-cr-o-v:hor10,a:blinkwait400-blinkoff500-blinkon700"
opt.linespace = 3 -- px, similar to line height

-- Ruler
cmd[[highlight ColorColumn ctermbg=DarkGrey]]

-- Active Line
cmd[[highlight CursorLine term=none cterm=none  ctermbg=black]]

-- Current Word Highlight (from Coc)
cmd[[highlight CocHighlightText term=underline cterm=underline]]

-- TreeSitter Context Line
cmd[[highlight TreesitterContext ctermbg=black]]

-- Indentation Lines
cmd[[highlight IndentBlanklineChar ctermfg=DarkGrey guifg=DarkGrey]]

-- Comments
cmd[[highlight Comment ctermfg=grey]]

-- Popup Menus
cmd[[highlight Pmenu ctermbg=DarkGrey]]

-- Line Numbers
cmd[[highlight LineNr ctermfg=DarkGrey]]
cmd[[highlight CursorLineNr ctermfg=Grey]]


--------------------------------------------------------------------------------
-- custom highlights

-- leading spaces
cmd[[highlight WhiteSpaceBol guibg=DarkGrey ctermbg=DarkGrey]]
cmd[[call matchadd('WhiteSpaceBol', '^ \+')]]

-- Annotations
cmd[[highlight def link myAnnotations Todo]] -- use same styling as "TODO"
cmd[[call matchadd('myAnnotations', 'INFO\|TODO\|NOTE\|WARNING\|WARN\|REQUIRED') ]]

cmd[[highlight urls cterm=underline term=underline gui=underline]]
cmd[[call matchadd('urls', 'http[s]\?:\/\/[[:alnum:]%\/_#.-]*') ]]

--------------------------------------------------------------------------------

-- GUTTER
opt.signcolumn = "yes:1"
cmd[[highlight clear SignColumn]] -- transparent

-- Git Gutter
g.gitgutter_map_keys = 0 -- disable gitgutter mappings I don't use anyway

cmd[[highlight GitGutterAdd    guifg=Green  ctermfg=Green]]
cmd[[highlight GitGutterChange guifg=Yellow ctermfg=Yellow]]
cmd[[highlight GitGutterDelete guifg=Red    ctermfg=Red]]
g.gitgutter_sign_added = '│'
g.gitgutter_sign_modified = '│'
g.gitgutter_sign_removed = '–'
g.gitgutter_sign_removed_first_line = '–'
g.gitgutter_sign_removed_above_and_below = '–'
g.gitgutter_sign_modified_removed = '│'
g.gitgutter_sign_priority = 10

-- ▪︎▴•  
-- https://www.reddit.com/r/neovim/comments/qpymbb/lsp_sign_in_sign_columngutter/
local signs = { 
	Error = "",
	Warn = "",
	Hint = "", 
	Info = "" 
}
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

--------------------------------------------------------------------------------

-- STATUS LINE (LuaLine)
local function alternateFile()
	local altFile = api.nvim_exec('echo expand("#:t")', true)
	local curFile = api.nvim_exec('echo expand("%:t")', true)
	if altFile == curFile or altFile == "" then return "" end
	return "# "..altFile
end

local function currentFile() -- using this function instead of default filename, since this does not show "[No Name]" for Telescope
	local curFile = api.nvim_exec('echo expand("%:t")', true)
	if not(curFile) or curFile == "" then return "" end
	return "%% "..curFile -- "%" is lua's escape character and therefore needs to be escaped itself
end

require('lualine').setup {
	sections = {
		lualine_a = {'mode'},
		lualine_b = {{ currentFile }},
		lualine_c = {{ alternateFile }},
		lualine_x = {'diagnostics', 'diff'},
		lualine_y = {'branch'},
		lualine_z = {'location', 'progress'},
	},
	options = {
		theme  = 'auto',
		globalstatus = true,
		component_separators = { left = '', right = ''},
		section_separators = { left = ' ', right = ' '}, -- nerd font: 'nf-ple'
	},
}

