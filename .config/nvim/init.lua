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
vim.opt.showmatch = true
vim.opt.hlsearch = true

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

-- ruler
vim.opt.colorcolumn = '80'

-- editor
-- vim.opt.cursorline = true -- doesn't look good, investigate later
vim.opt.autowrite = true
vim.opt.fillchars = 'eob: ' -- hide the ~
vim.opt.scrolloff = 5
vim.opt.ruler = true

-- status bar
vim.opt.showcmd = true

-- clipboard
vim.opt.clipboard = 'unnamedplus'


--------------------------------------------------------------------------------

-- KEYBINDINGS

vim.g.mapleader = ','

local function keymap (mode, key, result)
	vim.keymap.set(
			mode,
			key,
			result,
			{noremap = true}
		)
end

--------------------------------------------------------------------------------

keymap("n", "<Space>", "ciw")
keymap("n", "<S-Space>", "daw")

keymap("i", "jj", "<ESC>")

-- reload vimrc
keymap("n", "<leader>r", ":source $MYVIMRC<CR>")
