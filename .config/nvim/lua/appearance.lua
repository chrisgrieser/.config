-- THEME

-- keep using terminal colorscheme in the Terminal, for consistency with
-- Alacritty looks
if vim.fn.has('gui_running') == 1 then -- https://www.reddit.com/r/neovim/comments/u1998d/comment/i4asi0h/?utm_source=share&utm_medium=web2x&context=3
	vim.cmd[[colorscheme tokyonight]]
end

--------------------------------------------------------------------------------
-- UI ELEMENTS
-- partially overriden when using theme

-- Ruler
vim.cmd('highlight ColorColumn ctermbg=0 guibg=black') -- https://www.reddit.com/r/neovim/comments/me35u9/lua_config_to_set_highlight/

-- Active Line
vim.cmd('highlight CursorLine term=bold cterm=bold guibg=black ctermbg=black')

--------------------------------------------------------------------------------
-- LUA LINE

local function alternateFile()
	local altFile = vim.api.nvim_exec('echo expand("#:t")', true)
	local currentFile = vim.api.nvim_exec('echo expand("%:t")', true)
	if altFile ~= currentFile then
		return altFile
	else
		return ""
	end
end

require('lualine').setup {
	sections = {
		lualine_a = {{ 'mode', fmt = function(str) return str:sub(1,1) end }},
		lualine_b = {
			{'filetype', icon_only = true, colored = false  },
			{'filename', symbols = {modified = "+"}, padding = 0 }
		},
		lualine_c = {{ alternateFile }},
		lualine_x = {''},
		lualine_y = {'diagnostics'},
		lualine_z = { {'location', padding = {left = 0, right = 1}}, 'progress' }
	},
	options = {
		theme  = 'auto',
		component_separators = { left = '', right = ''},
		section_separators = { left = '', right = '' },
	},
}



