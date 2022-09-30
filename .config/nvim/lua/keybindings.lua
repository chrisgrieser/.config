require("utils")
--------------------------------------------------------------------------------
-- META
g.mapleader = ','

-- [r]eload current config file
keymap("n", "<leader>r", ':write<CR>:source %<CR>:echo "Reloaded."<CR>') -- alternative: https://www.reddit.com/r/neovim/comments/puuskh/how_to_reload_my_lua_config_while_using_neovim/

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", ':let @+=@:<CR>:echo "Copied:"@:<CR>')

-- search normal mode mappings
keymap("n", "?", function() telescope.keymaps() end)

-- search vim docs
keymap("n", "<leader>?", function() telescope.help_tags() end)

-- Theme Picker
keymap("n", "<leader>T", function() telescope.colorscheme() end)

-- Update [P]lugins
keymap("n", "<leader>p", function()
	cmd[[write!]]
	package.loaded["plugin-list"] = nil -- empty the cache for lua
	require("plugin-list")
	local packer = require("packer")
	packer.startup(PluginList)
	packer.sync()
end)
keymap("n", "<leader>P", ":PackerStatus<CR>")

--------------------------------------------------------------------------------
-- NAVIGATION

-- Have j and k navigate visual lines rather than logical ones
-- (useful if wrapping is on)
keymap("n", "j", "gj")
keymap("n", "k", "gk")
keymap("n", "gj", "j")
keymap("n", "gk", "k")
keymap({"n", "v"}, "G", "Gzz") -- "overscroll" when going to bottom of editor

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap("", "H", "0^") -- 0^ ensures scrolling to the left on long lines
keymap("", "L", "$")
keymap("", "J", "7j")
keymap("", "K", "7k")

-- Multi-Cursor, https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
-- changing these seems to require full restart (not only re-sourcing)
cmd[[
	let g:VM_maps = {}
	let g:VM_maps['Find Under'] = '*'
]]

-- Jump History
keymap("n", "<Left>", "<C-o>") -- Back
keymap("n", "<Right>", "<C-i>") -- Forward

-- Search
keymap("", "-", "/") -- German Keyboard consistent with US Keyboard layout
keymap("", "+", "*") -- no more modifier key on German Keyboard
keymap("", "ä", "`") -- Goto Mark
keymap("n", "<Esc>", ":nohl<CR>", {silent = true}) -- [m]ute highlights with Esc
keymap("n", "g-", function() telescope.current_buffer_fuzzy_find() end) -- alternative search
keymap("n", "gs", ":CocList outline<CR>") -- equivalent to Sublime's goto-symbol

--------------------------------------------------------------------------------
-- EDITING

-- don't pollute the register
keymap({"n", "v"}, "x", '"_x')
keymap({"n", "v"}, "c", '"_c')
keymap({"n", "v"}, "C", '"_C')

-- Text Objects
-- for some reason, recursive remap does not seem to work properly, therefore
-- the text-objects below need "_
keymap("n", "<Space>", '"_ciw') -- change word
keymap("n", "<S-Space>", '"_daw')
keymap("v", "<Space>", '"_c')
keymap("v", "<S-Space>", '"_d')
keymap("n", "q", "cib") -- requires vim-textobj-anyblock
keymap("n", "Q", "cab") -- vim vim-textobj-anyblock
keymap("o", "r", '}') -- [r]est of the paragraph


-- change small word (i.e. a simpler version of vim-textobj-variable-segment)
-- (not supporting CamelCase though)
keymap("n", "<leader><Space>", function ()
	opt.iskeyword = opt.iskeyword - {"_", "-"}
	cmd[[normal! "_diw]]
	cmd[[startinsert]] -- :Normal does not allow to end in insert mode
	opt.iskeyword = opt.iskeyword - {"_", "-"}
end)

-- Whitespace Control
keymap("n", "!", "a <Esc>h") -- append space
keymap("n", "\\", "i <Esc>l", {nowait = true}) -- prepend space
keymap("n", "=", "mzO<Esc>`z") -- add blank above
keymap("n", "_", "mzo<Esc>`z") -- add blank below
keymap("n", "<BS>", "dipO<Esc>") -- reduce multiple blank lines to exactly one
keymap("n", "|", "i<CR><Esc>k$") -- Split line here

-- Indention
keymap("n", "<Tab>", ">>")
keymap("n", "<S-Tab>", "<<")
keymap("v", "<Tab>", ">gv")
keymap("v", "<S-Tab>", "<gv")
keymap({"n", "v"}, "^", "=") -- auto-indent
keymap("n", "^p", "`[v`]=") -- auto-indent last paste

-- toggle word between Capital and lower case
keymap("n", "ü", "mzlblgueh~`z")

-- Transpose
-- (meant to be pressed repeatedly to move characters)
keymap("n", "ö", "xp") -- current & next char
keymap("n", "Ö", "xhhp") -- current & previous char
keymap("n", "Ä", "dawelpb") -- current & next word

-- <leader>{char} → Append {char} to end of line
local trailingKeys = {".", ",", ";", ":", '"', "'", "(", ")", "[", "]", "{", "}", "|", "/", "\\", "`" }
for i = 1, #trailingKeys do
	keymap("n", "<leader>"..trailingKeys[i], "mzA"..trailingKeys[i].."<Esc>`z")
end

keymap("n", "X", 'mz$"_x`z') -- Remove last character from line

-- Spellling
keymap("n", "zl", function() telescope.spell_suggest() end)
keymap("n", "gz", "]s") -- next misspelling
keymap("n", "gZ", "[s") -- prev misspelling

-- Misc
keymap({"n", "v"}, "U", "<C-r>") -- undo consistent on one key
keymap({"n", "v"}, "M", "J") -- [M]erge line up
keymap({"n", "v"}, "gm", "ddpkJ") -- [m]erge line down
keymap("n", "P", '"0p') -- paste what was yanked
keymap("n", "<leader>q" ,"q") -- needs to be remapped, since used as text object

-- s for substitute (vim.subversive)
keymap("n", "s", "<plug>(SubversiveSubstitute)")
keymap("n", "ss", "<plug>(SubversiveSubstituteLine)")
keymap("n", "S", "<plug>(SubversiveSubstituteToEndOfLine)")

--------------------------------------------------------------------------------
-- INSERT MODE & COMMAND MODE
keymap("i", "<C-e>", '<Esc>A') -- EoL
keymap("i", "<C-k>", '<Esc>lDi') -- kill line
keymap("i", "<C-a>", '<Esc>I') -- BoL
keymap("n", "<C-e>", 'A')
keymap("n", "<C-a>", 'I')
keymap("c", "<C-a>", '<Home>')
keymap("c", "<C-e>", '<End>')
keymap("c", "<C-u>", '<C-e><C-u>') -- clear

-- quicker typing
keymap("i", "!!", '{}<Left><CR><Esc>O') -- {}

--------------------------------------------------------------------------------
-- VISUAL MODE
keymap("v", "V", "j") -- so double "V" selects two lines
keymap("v", "p", 'P') -- do not override register when pasting
keymap("v", "P", 'p') -- override register when pasting
keymap({"n", "v"}, "v", '<Plug>(wildfire-fuel)') -- start visual mode with a sensitve selection

--------------------------------------------------------------------------------
-- LANGUAGE-SPECIFIC BINDINGS

-- Markdown
keymap("n", "<CR>", 'A') -- So double return keeps markdown list syntax
keymap("n", "<leader>x", 'mz^lllrx`z') -- check markdown tasks

-- CSS
keymap("n", "<leader>v", '^Ellct;') -- change [v]alue key (also works for JSON, actually)
keymap("n", "<leader>c", 'mzlEF.yEEp`z') -- double [c]lass under cursor
keymap("n", "<leader>C", 'lF.d/[.\\s]<CR>') -- remove [C]lass under cursor
keymap("n", "gS", function() telescope.current_buffer_fuzzy_find{default_text='< ', prompt_prefix='🪧'} end) -- Navigation Markers

-- JS
keymap("n", "<leader>t", 'ysiw}i$<Esc>f}') -- make template string variable, requires vim.surround

--------------------------------------------------------------------------------
-- EMULATING MAC BINDINGS
-- - requires GUI app like Neovide (called "Logo Key" there)
-- - mostly done for consistency with other apps
keymap({"n", "v"}, "<D-v>", "p") -- cmd+v
keymap("n", "<D-c>", "yy") -- cmd+c: copy line
keymap("v", "<D-c>", "y") -- cmd+c: copy selection
keymap("n", "<D-x>", "dd") -- cmd+x: cut line
keymap("v", "<D-x>", "d") -- cmd+x: cut selection

keymap("n", "<D-n>", ":e ") -- cmd+n
keymap("n", "<D-s>", ":write<CR>") -- cmd+s
keymap("n", "<D-a>", "mzggvGy`z") -- cmd+a & cmd+c
keymap("n", "<D-w>", ":w<CR>:bd<CR>") -- cmd+w

keymap("n", "<D-D>", "yyp") -- cmd+shift+d: duplicate lines
keymap("v", "<D-D>", "yp") -- cmd+shift+d: duplicate selected lines
keymap("n", "<D-2>", "ddkkp") -- line up
keymap("n", "<D-3>", "ddp") -- line down
keymap("v", "<D-2>", "dkkp") -- selected lines up
keymap("v", "<D-3>", "dp") -- selected lines down
keymap("n", "<D-7>", "gcc") -- comment line
keymap("v", "<D-7>", "gc") -- comment selection
keymap("n", "<D-l>", ":!open %:h <CR><CR>") -- show file in default GUI file explorer
keymap("n", "<D-,>", ":e $HOME/.config/nvim/init.lua <CR>") -- cmd+,

--------------------------------------------------------------------------------
-- FILES AND WINDOWS
keymap("n", "ZZ", ":wall<CR>:q<CR>") -- quicker quitting

-- File switchers
keymap("n", "go", function() telescope.find_files() end) -- [o]pen file in parent-directory
keymap("n", "gO", function() telescope.find_files{cwd='%:p:h:h', prompt_prefix='🆙📂'} end) -- [o]pen file in grandparent-directory
keymap("n", "gr", function() telescope.oldfiles() end) -- [r]ecent files
keymap("n", "gb", function() telescope.buffers() end) -- open [b]uffer
keymap("n", "gF", function() telescope.live_grep() end) -- open [b]uffer
keymap("n", "<leader>V", function() telescope.git_bcommits() end) -- Version History of current file

-- Buffers
keymap("", "<C-Tab>", "<C-^>")
keymap("n", "gw", "<C-w><C-w>") -- switch to next split
keymap({"n", "v"}, "gt", ":nohl<CR><C-^>", {silent = true}) -- switch to alt-file (use vim's buffer model instead of tabs)

-- File Operations
-- <C-R>=expand("%:t")<CR> -> expands the current filename in the command line
keymap("n", "<C-p>", ':let @+=@%<CR>:echo "Copied:"expand("%")<CR>') -- copy path of current file
keymap("n", "<C-n>", ':let @+ = expand("%:t")<CR>:echo "Copied:"expand("%:t")<CR>') -- copy name of current file
keymap("n", "<C-r>", ':Rename ') -- rename of current file, requires eunuch.vim
keymap("n", "<C-l>", ":!open %:h<CR><CR>") -- show file in default GUI file explorer
keymap("n", "<C-d>", ':Duplicate <C-R>=expand("%:t")<CR>') -- duplicate current file
keymap("n", "<leader>X", ":Chmod +x<CR>") -- execution permission, requires eunuch.vim
keymap("n", "<leader><BS>", ":Remove") -- undoable deletion of the file, requires eunuch.vim

-- Sorting
keymap("n", "<leader>ss", ":'<,'>sort<CR>") -- [s]ort [s]election
keymap("n", "<leader>sa", "vi]:sort u<CR>") -- [s]ort [a]rray, if multi-line (+ remove duplicates)
keymap("n", "<leader>sg", ":sort<CR>") -- [s]ort [g]lobally
keymap("n", "<leader>sp", "vip:sort<CR>") -- [s]ort [p]aragraph

