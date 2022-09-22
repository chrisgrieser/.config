-- https://bryankegley.me/posts/nvim-getting-started/
--------------------------------------------------------------------------------

-- SETTINGS
local opt = vim.opt

-- search
opt.incsearch = true
opt.showmatch = true
opt.hlsearch = true

-- tabs & indentation
opt.autoindent = true
opt.smartindent = true
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3

-- gutter
opt.relativenumber = true
opt.signcolumn = 'yes'
opt.fillchars = 'eob: ' -- hide the ~

-- ruler
opt.colorcolumn = '80'
opt.textwidth = 80 -- mostly used by `gq`

-- editor
-- opt.cursorline = true -- doesn't look good, investigate later
opt.autowrite = true
opt.scrolloff = 12

-- status bar
opt.showcmd = true
opt.showmode = true

-- clipboard
opt.clipboard = 'unnamedplus'


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
keymap("", "ä", "`") -- Goto Mark

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


--------------------------------------------------------------------------------

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

-- Switch Case of first letter of the word = (toggle between Capital and lower case)
keymap("n", "ü", "mzlblgueh~`z")

-- Transpose
keymap("n", "ö", "xp") -- current & next char
keymap("n", "Ö", "xhhp") -- current & previous char
keymap("n", "Ä", "dawelpb") -- current & next word

-- <leader>{punctuation-char} → Append punctuation to end of line
trailingKeys = {".", ",", ";", ":", '"', "'", "(", ")", "[", "]", "{", "}", "|", "/", "\\", "`" }
for i = 1, #trailingKeys do
	keymap("n", "<leader>"..trailingKeys[i], "mzA"..trailingKeys[i].."<Esc>`z")
end

--------------------------------------------------------------------------------
-- EMULATING MAC BINDINGS (for consistency)
keymap("", "<D-v>", "p") -- cmd+v
keymap("n", "<D-c>", "yy") -- cmd+c: copy line
keymap("v", "<D-c>", "y") -- cmd+c: copy selection
keymap("n", "<D-x>", "dd") -- cmd+x: cut line
keymap("v", "<D-x>", "d") -- cmd+x: cut selection
keymap("n", "<D-s>", ":write<CR>") -- cmd+s
keymap("n", "<D-a>", "ggvG") -- cmd+a
keymap("n", "<D-w>", ":bd") -- cmd+w
keymap("n", "<D-2>", "[e") -- move line up (vim.unimpaired)
keymap("n", "<D-3>", "]e") -- move line down (vim.unimpaired)
