-- https://bryankegley.me/posts/nvim-getting-started/
--------------------------------------------------------------------------------

-- vim.o: global-scoped
-- vim.bo: buffer-scoped
-- vim.wo: window-scoped
-- vim.opt: set option
-- vim.g: global variables

--------------------------------------------------------------------------------
-- SETTINGS

-- search
vim.opt.smartcase = true
vim.opt.incsearch = true

-- tabs & indentation
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 3
vim.opt.softtabstop = 3
vim.opt.shiftwidth = 3

-- gutter
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'

-- status bar

--------------------------------------------------------------------------------

-- KEYBINDINGS

vim.g.mapleader = ','

local key_mapper = function(mode, key, result)
	vim.opt.nvim_set_keymap(
			mode,
			key,
			result,
			{noremap = true, silent = true}
		)
end
