require("utils")

--------------------------------------------------------------------------------

-- THEME
-- keep using terminal colorscheme in the Terminal, for consistency with
-- Alacritty looks
if fn.has('gui_running') == 1 then -- https://www.reddit.com/r/neovim/comments/u1998d/comment/i4asi0h/?utm_source=share&utm_medium=web2x&context=3
	cmd[[colorscheme tokyonight]]
end

--------------------------------------------------------------------------------
-- UI ELEMENTS
-- partially overriden when using a theme

-- Ruler
cmd[[highlight ColorColumn ctermbg=DarkGrey guibg=black]] -- https://www.reddit.com/r/neovim/comments/me35u9/lua_config_to_set_highlight/

-- Active Line
cmd[[highlight CursorLine term=bold cterm=bold guibg=black ctermbg=black]]

cmd[[syn match matchURL '/http[s]\?:\/\/[[:alnum:]%\/_#.-]*/'
hi matchURL ctermfg=14]]

--------------------------------------------------------------------------------
-- GUTTER
-- Sign Column ( = Gutter)
cmd[[highlight clear SignColumn]] -- transparent

-- Git Gutter
-- https://github.com/airblade/vim-gitgutter#signs-colours-and-symbols
cmd[[highlight GitGutterAdd    guifg=Green ctermfg=Green]]
cmd[[highlight GitGutterChange guifg=Yellow ctermfg=Yellow]]
cmd[[highlight GitGutterDelete guifg=Red ctermfg=Red]]

-- INFO: Look of the Coc Gutter indicators is set in coc-settings.json

--------------------------------------------------------------------------------
-- STATUS LINE (Lua Line)
local function alternateFile()
	local bufferCount = fn.bufnr("$")
	if bufferCount == 1 then return "" end

	local altFile = api.nvim_exec('echo expand("#:t")', true)
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



