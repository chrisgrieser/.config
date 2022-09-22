-- https://bryankegley.me/posts/nvim-getting-started/
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
vim.opt.relativenumber = true
vim.opt.signcolumn = 'yes'
vim.opt.fillchars = 'eob: ' -- hide the ~

-- ruler
vim.opt.colorcolumn = '80'
vim.opt.textwidth = 80 -- mostly used by `gq`

-- editor
-- vim.opt.cursorline = true -- doesn't look good, investigate later
vim.opt.autowrite = true
vim.opt.scrolloff = 12

-- status bar
vim.opt.showcmd = true
vim.opt.showmode = true

-- clipboard
vim.opt.clipboard = 'unnamedplus'


--------------------------------------------------------------------------------

-- KEYBINDINGS META
vim.g.mapleader = ','

local function keymap (mode, key, result)
	vim.keymap.set(
			mode,
			key,
			result,
			{noremap = true}
		)
end

-- reload vimrc
keymap("n", "<leader>r", ":source $MYVIMRC<CR>")

--------------------------------------------------------------------------------

-- NAVIGATION
keymap("", "-", "/") -- German Keyboard consistent with US Keyboard layout
keymap("", "+", "*") -- no more modifier key on German Keyboard

-- Have j and k navigate visual lines rather than logical ones
-- (useful if wrapping is on)
keymap("n", "j", "gj")
keymap("n", "k", "gk")
keymap("n", "gj", "j")
keymap("n", "gk", "k")

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap("", "H", "0^") -- ensures scrolling to the left
keymap("", "L", "$")
keymap("", "J", "7j")
keymap("", "K", "7k")
keymap("", "L", "$")
keymap("", "[", "{") -- easier to press
keymap("", "]", "}")


-- EDITING
keymap("n", "<Space>", '"_ciw')
keymap("n", "<S-Space>", '"_daw')
keymap("v", "<Space>", '"_c')
keymap("v", "<S-Space>", '"_d')
keymap("v", "<BS>", '"_d') -- consistent with insert mode selection


keymap("n", "!", "a <Esc>h") -- append space
keymap("n", "X", 'mz$"_x`z') -- Remove last character from line

keymap("n", "U", "<C-r>") -- undo consistent

keymap("n", "M", "J") -- [M]erge Lines

-- Add Blank Line above/below
keymap("n", "=", "mzO<Esc>`z")
keymap("n", "_", "mzo<Esc>`z")

-- [R]eplace Word with register content
keymap("n", "R", 'viw"0p')
keymap("v", "R", '"0p')

-- Make indention work like in other editors
keymap("n", "<Tab>", ">>")
keymap("n", "<S-Tab>", "<<")
keymap("v", "<Tab>", ">gv")
keymap("v", "<S-Tab>", "<gv")

-- Append punctuation to end of line
trailingKeys = {",", ";", ":", '"', "'", "(", ")", "[", "]", "{", "}"}
for i = 1, #trailingKeys do
	keymap("n", "<leader>"..trailingKeys[i], "mzA"..trailingKeys[i].."<Esc>`z")
end
