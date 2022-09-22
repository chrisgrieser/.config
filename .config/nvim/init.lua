-- https://bryankegley.me/posts/nvim-getting-started/
-- https://neovim.io/doc/user/vim_diff.html
--------------------------------------------------------------------------------

-- SETTINGS
local opt = vim.opt

-- search
opt.showmatch = true
opt.smartcase = true
opt.ignorecase = true

-- tabs & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3

-- gutter
opt.relativenumber = false
opt.signcolumn = 'no'
opt.fillchars = 'eob: ' -- hide the "~" marking non-existend lines

-- ruler
opt.textwidth = 80 -- used by `gq`
opt.colorcolumn = '+1' -- column next to text-line
vim.cmd[[highlight ColorColumn ctermbg=0 guibg=black]] -- https://www.reddit.com/r/neovim/comments/me35u9/lua_config_to_set_highlight/

-- editor
-- opt.cursorline = true -- doesn't look good, investigate later
opt.autowrite = true
opt.scrolloff = 10
opt.wrap = false

-- status bar
opt.showcmd = true
opt.showmode = true
opt.laststatus = 0

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
keymap("n", "<leader>r", ":w<CR> :source $MYVIMRC<CR>")

--------------------------------------------------------------------------------

-- NAVIGATION
keymap("", "-", "/") -- German Keyboard consistent with US Keyboard layout
keymap("", "+", "*") -- no more modifier key on German Keyboard
keymap("", "ä", "`") -- Goto Mark
keymap("", "Q", "mz0`z") -- Scroll horizontally back

-- Have j and k navigate visual lines rather than logical ones
-- (useful if wrapping is on)
keymap("n", "j", "gj")
keymap("n", "k", "gk")
keymap("n", "gj", "j")
keymap("n", "gk", "k")

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap("", "H", "0^") -- 0^ ensures scrolling to the left on long lines
keymap("", "L", "$")
keymap("", "J", "7j")
keymap("", "K", "7k")
keymap("", "[", "{") -- easier to press
keymap("", "]", "}")

-- Misc
--
-- TODO: investigate why this one isn't working
-- keymap("n", "gf", "gx") -- [f]ollow link under cursor

--------------------------------------------------------------------------------

-- EDITING
-- 
-- don't pollute the register
keymap("n", "x", '"_x')
keymap("n", "c", '"_c')
keymap("n", "C", '"_C')
keymap("v", "c", '"_c')
keymap("v", "C", '"_C')
keymap("v", "x", '"_x')

-- Spacebar
keymap("n", "<Space>", '"_ciw')
keymap("n", "<S-Space>", '"_daw')
keymap("v", "<Space>", '"_c')
keymap("v", "<S-Space>", '"_d')

-- Misc
keymap("v", "<BS>", '"_d') -- consistent with insert mode selection
keymap("n", "!", "a <Esc>h") -- append space
keymap("n", "X", 'mz$"_x`z') -- Remove last character from line
keymap("n", "U", "<C-r>") -- undo consistent
keymap("v", "U", "<C-r>")
keymap("v", "p", "_dP") -- do not override register when pasting on selection (still able to do so with P)
keymap("n", "M", "J") -- [M]erge Lines
keymap("v", "M", "J")

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
-- INSERT MODE
-- consistent with insert mode / emacs bindings
keymap("i", "<C-e>", '<Esc>A')
keymap("i", "<C-a>", '<Esc>I')

--------------------------------------------------------------------------------
-- LANGUAGE-SPECIFIC BINDINGS

-- Markdown
keymap("n", "<CR>", 'A') -- So Double return keeps list syntax
keymap("n", "<leader>x", 'mz^lllrx`z') -- check tasks

-- CSS
keymap("n", "<leader>v", '^Ellct;') -- change [v]alue key
keymap("n", "<leader>c", 'mzlEF.yEEp`z') -- double [c]lass under cursor
keymap("n", "<leader>C", 'lF.d/[.\\s]<CR>') -- remove [C]lass under cursor

-- JS
keymap("n", "<leader>t", 'ysiw}i$<Esc>f}') -- make template string variable

--------------------------------------------------------------------------------
-- EMULATING MAC BINDINGS (requires GUI app like Neovide)
keymap("", "<D-v>", "p") -- cmd+v
keymap("n", "<D-c>", "yy") -- cmd+c: copy line
keymap("v", "<D-c>", "y") -- cmd+c: copy selection
keymap("n", "<D-x>", "dd") -- cmd+x: cut line
keymap("v", "<D-x>", "d") -- cmd+x: cut selection

keymap("n", "<D-n>", ":tabnew") -- cmd+n
keymap("n", "<D-t>", ":tabnew") -- cmd+t
keymap("n", "<D-s>", ":write<CR>") -- cmd+s
keymap("n", "<D-a>", "ggvG") -- cmd+a
keymap("n", "<D-w>", ":bd") -- cmd+w
keymap("n", "<D-2>", "[e") -- move line up (vim.unimpaired)
keymap("n", "<D-3>", "]e") -- move line down (vim.unimpaired)
keymap("n", "<D-,>", ":e $HOME/.config/nvim/init.lua <CR>") -- cmd+,
keymap("n", "<D-;>", ":e $HOME/.config/nvim/init.lua <CR>") -- cmd+shift+,

keymap("n", "<C-p>", ":let @+=@%<CR>") -- copy path of current file
keymap("n", "<C-n>", ':let @+ = expand("%:t")') -- copy name of current file
keymap("n", "<C-r>", ':Rename') -- rename of current file, requires eunuch.vim

--------------------------------------------------------------------------------
-- MISC
-- Shortcuts from vim.unimpaired
keymap("n", "<leader>on", "yon") -- [O]ption: line [n]umbers
keymap("n", "<leader>os", "yos") -- [O]ption: [s]pellcheck
keymap("n", "<leader>ow", "yow") -- [O]ption: line [w]rap

-- Sorting
keymap("n", "<leader>ss", ":'<,'>sort<CR>") -- [s]ort [s]election
keymap("n", "<leader>sa", "vi]:sort u<CR>") -- [s]ort [a]rray, if multi-line (+ remove duplicates)
keymap("n", "<leader>sg", ":sort<CR>") -- [s]ort [g]lobally
keymap("n", "<leader>sp", "vip:sort<CR>") -- [s]ort [p]aragraph

