require("utils")
--------------------------------------------------------------------------------
-- META
g.mapleader = ','

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", ':let @+=@:<CR>:echo "Copied:"@:<CR>')

-- search keymaps
keymap("n", "?", function() telescope.keymaps() end)
keymap("n", "<leader>?", function() telescope.help_tags() end)

-- Theme Picker
keymap("n", "<leader>T", function() telescope.colorscheme() end)

-- Highlights
keymap("n", "<leader>G", function() telescope.highlights() end)

-- Update [P]lugins
keymap("n", "<leader>p", function()
	cmd[[update! ~/.config/nvim/lua/plugin-list.lua]]
	package.loaded["plugin-list"] = nil -- empty the cache for lua
	require("plugin-list")
	local packer = require("packer")
	packer.startup(PluginList)
	packer.sync()
end)
keymap("n", "<leader>P", ":PackerStatus<CR>")

-- Utils
keymap("n", "ZZ", ":w<CR>:q<CR>") -- quicker quitting
keymap("n", "zz", ":w<CR>:!acp ")

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap("", "H", "0^") -- 0^ ensures scrolling to the left on long lines
keymap("", "L", "$")
keymap({"v", "o"}, "J", "7j")
keymap("", "K", "7k")

-- when reaching the last line, scroll down (since scrolloff does not work at EOF)
local function overscroll (action)
	local curLine = fn.line(".")
	local lastLine = fn.line("$")
	if curLine == lastLine then
		cmd[[normal! zz]]
	else
		cmd("normal! "..action)
	end
end
keymap("n", "j", function () overscroll("j") end)
keymap("n", "J", function () overscroll("7j") end)
keymap({"n", "v"}, "G", "Gzz")

-- Multi-Cursor, https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
-- changing these seems to require full restart (not only re-sourcing)
cmd[[
	let g:VM_maps = {}
	let g:VM_maps['Find Under'] = '*'
]]

-- Jump History
keymap("n", "<C-h>", "<C-o>") -- Back
keymap("n", "<C-l>", "<C-i>") -- Forward

-- Sneak: enable clever-f-style movement
keymap("", "f", "<Plug>Sneak_f")
keymap("", "F", "<Plug>Sneak_F")
keymap("", "t", "<Plug>Sneak_t")
keymap("", "T", "<Plug>Sneak_T")

-- Search
keymap("", "-", "/") -- German Keyboard consistent with US Keyboard layout
keymap("n", "/", "/\v") -- more PCRE-like regex patterns (:h magic)
keymap("n", "<Esc>", ":nohl<CR>:echo<CR>", {silent = true}) -- clear highlights & shortmessage
keymap("", "+", "*") -- no more modifier key on German Keyboard

-- URLs
keymap("n", "gü", "/http.*<CR>") -- goto next
keymap("n", "gÜ", "?http.*<CR>") -- goto prev

-- Marks
keymap("", "ä", "`") -- Goto Mark

--------------------------------------------------------------------------------
-- EDITING

-- CLIPBOARD
keymap({"n", "v"}, "x", '"_x')
keymap({"n", "v"}, "c", '"_c')
keymap({"n", "v"}, "C", '"_C')
keymap("n", "P", '"0p') -- paste what was yanked

-- TEXT OBJECTS
-- the text-objects below need "_
keymap("n", "<Space>", '"_ciw') -- change word
keymap("n", "<C-A-Space>", '"_daw') -- wordaround, since <S-Space> not fully supported, requires karabiner remapping it
keymap("v", "<Space>", '"_c')

-- change small word (i.e. a simpler version of vim-textobj-variable-segment,
-- but not supporting CamelCase)
keymap("n", '<leader><Space>', function ()
	opt.iskeyword = opt.iskeyword - {"_", "-"}
	cmd[[normal! "_diw]]
	cmd[[startinsert]] -- :Normal does not allow to end in insert mode
	opt.iskeyword = opt.iskeyword - {"_", "-"}
end)

keymap("o", "q", 'i"') -- change double [q]uote
keymap("o", "Q", "i'") -- change single [Q]uote
keymap("o", "p", '}') -- rest of the [p]aragraph
keymap("o", "P", '{') -- beginning of the [P]aragraph

-- COMMENTS (mnemonic: [q]uiet text)
keymap({"n", "v"}, "q" ,"<Plug>Commentary")
keymap("n", "qq" ,"mz<Plug>CommentaryLine`z")
keymap("n", "qu" ,"<Plug>Commentary<Plug>Commentary") -- undo comment
keymap("o", "aq" ,"<Plug>Commentary") -- better text object than from treesitter
keymap({"n", "v"}, "Ä" ,"q") -- macro needs to be remapped as result
-- INFO gq and gQ mapped as goto next/prev comment via treesitter textobj

-- append comment to current line (equivalent to gcA from comments.nvim)
keymap("n", "Q" , function()
	local lineContent = fn.getline(".")
	local eolCol = #lineContent
	local emptyLine = lineContent == ""

	local lineNum = api.nvim_win_get_cursor(0)[1]
	local commentPos, _ = bo.commentstring:find("%%s")
	local newCol = eolCol + commentPos + 1

	if bo.filetype == "css" then
		if emptyLine then
			newLineContent = lineContent..bo.commentstring:gsub("%%s", "  ")
			newCol = newCol - 2
		else
			newLineContent = lineContent.." "..bo.commentstring:gsub("%%s", "  ")
			newCol = newCol - 1
		end
	else
		if emptyLine then
			newLineContent = lineContent..bo.commentstring:gsub("%%s", " ")
		else
			newLineContent = lineContent.." "..bo.commentstring:gsub("%%s", " ")
		end
	end

	fn.setline(".", newLineContent)
	api.nvim_win_set_cursor(0, {lineNum, newCol + 1})
	cmd[[startinsert]]
end)


-- Whitespace Control
keymap("n", "!", "a <Esc>h") -- append space
keymap("n", "=", "mzO<Esc>`z") -- add blank above
keymap("n", "_", "mzo<Esc>`z") -- add blank below
keymap("n", "<BS>", '"_dipO<Esc>') -- reduce multiple blank lines to exactly one
keymap("n", "|", "a<CR><Esc>k$") -- Split line at cursor

-- Indention
keymap("n", "<Tab>", ">>")
keymap("n", "<S-Tab>", "<<")
keymap("v", "<Tab>", ">gv")
keymap("v", "<S-Tab>", "<gv")

keymap({"n", "v"}, "^", "=") -- auto-indent
keymap("n", "^^", "mz=ip`z") -- since indenting paragraph more common than line
keymap("n", "^p", "mz`[v`]=`z") -- last paste
keymap("n", "^A", "mzgg=G`z") -- entire file

-- toggle word between Capital and lower case
keymap("n", "ü", "mzlblgueh~`z")

-- <leader>{char} → Append {char} to end of line
local trailingKeys = {".", ",", ";", ":", '"', "'", "(", ")", "[", "]", "{", "}", "|", "/", "\\", "`" }
for i = 1, #trailingKeys do
	keymap("n", "<leader>"..trailingKeys[i], "mzA"..trailingKeys[i].."<Esc>`z")
end
-- Remove last character from line
keymap("n", "X", 'mz$"_x`z')

-- Spelling (mnemonic: [z]pelling)
keymap("n", "zl", function() telescope.spell_suggest() end)
keymap("n", "gz", "]s") -- next misspelling
keymap("n", "gZ", "[s") -- prev misspelling
keymap("n", "za", "1z=") -- Autocorrect word under cursor (= select 1st suggestion)

-- [O]verride Operator (vim.subversive)
keymap("n", "ö", "<Plug>(SubversiveSubstitute)")
keymap("n", "öö", "<Plug>(SubversiveSubstituteLine)")
keymap("n", "Ö", "<Plug>(SubversiveSubstituteToEndOfLine)")

-- Duplicate Line / Selection (mnemonic: [r]eplicate)
keymap("n", "R", ':noautocmd normal!mz"zyy"zp`zj<CR>', {silent = true}) -- current line, ":noautocmd" to disable highlighted yank for this
keymap("v", "R", '"zy`]"zp', {silent = true}) -- selection (best used with Visual Line Mode)

-- Line & Character Movement (vim.move plugin)
g.move_map_keys = 0 -- disable default keymaps of vim.move
keymap("n", "<Down>", "<Plug>MoveLineDown")
keymap("n", "<Up>", "<Plug>MoveLineUp")
keymap("v", "<Down>", "<Plug>MoveBlockDown")
keymap("v", "<Up>", "<Plug>MoveBlockUp")

keymap("n", "<Right>", "<Plug>MoveCharRight")
keymap("n", "<Left>", "<Plug>MoveCharLeft")
keymap("v", "<Right>", "<Plug>MoveBlockRight")
keymap("v", "<Left>", "<Plug>MoveBlockLeft")

-- Merging / Splitting Lines
keymap({"n", "v"}, "M", "J") -- [M]erge line up
keymap({"n", "v"}, "gm", "ddpkJ") -- [m]erge line down
g.splitjoin_split_mapping = '' -- disable default mappings
g.splitjoin_join_mapping = ''
keymap("n", "<leader>m", ":SplitjoinJoin<CR>")
keymap("n", "<leader>s", ":SplitjoinSplit<CR>")

-- Undo
keymap({"n", "v"}, "U", "<C-r>") -- redo
keymap("n", "<C-u>", "U") -- undo line
keymap("n", "<leader>u", ":UndotreeToggle<CR>") -- undo tree

--------------------------------------------------------------------------------
-- INSERT MODE & COMMAND MODE
keymap("i", "<C-e>", '<Esc>A') -- EoL
keymap("i", "<C-k>", '<Esc>lDi') -- kill line
keymap("i", "<C-a>", '<Esc>I') -- BoL
keymap("c", "<C-a>", '<Home>')
keymap("c", "<C-e>", '<End>')
keymap("c", "<C-u>", '<C-e><C-u>') -- clear

-- quicker typing
keymap("i", "!!", ' {}<Left><CR><Esc>O') -- {} with proper linebreak

--------------------------------------------------------------------------------
-- VISUAL MODE
keymap("v", "p", 'P') -- do not override register when pasting
keymap("v", "P", 'p') -- override register when pasting

keymap("n", "V", "Vj") -- visual line mode starts with two lines selected
keymap("v", "V", "j") -- repeatedly pressing "V" selects more lines

keymap("v", "y", "ygv<Esc>") -- yanking in visual mode keeps position https://stackoverflow.com/a/3806683#comment10788861_3806683

--------------------------------------------------------------------------------
-- FILES AND WINDOWS

-- File switchers
keymap("n", "go", function() telescope.find_files() end) -- [o]pen file in parent-directory
keymap("n", "gO", function() telescope.find_files{cwd='%:p:h:h', prompt_prefix='🆙📂'} end) -- [o]pen file in grandparent-directory
keymap("n", "gr", function() telescope.oldfiles() end) -- [r]ecent files
keymap("n", "gb", function() telescope.buffers() end) -- open [b]uffer
keymap("n", "gf", function() telescope.live_grep() end) -- search in [f]iles

-- Buffers
keymap("", "<C-Tab>", "<C-^>") -- for footpedal
keymap("n", "gw", "<C-w><C-w>") -- switch to next split
keymap({"n", "v"}, "gt", ":nohl<CR><C-^>", {silent = true}) -- switch to alt-file (use vim's buffer model instead of tabs)

-- File Operations
keymap("n", "<C-p>", ':let @+ = expand("%:p")<CR>:echo "Copied:"expand("%:p")<CR>') -- copy path of current file
keymap("n", "<C-n>", ':let @+ = expand("%:t")<CR>:echo "Copied:"expand("%:t")<CR>') -- copy name of current file
keymap("n", "<C-r>", ':Rename ') -- rename of current file, requires eunuch.vim
keymap("n", "<C-d>", ':Duplicate <C-R>=expand("%:t")<CR>') -- duplicate current file
keymap("n", "<leader>X", ':Chmod +x<CR>') -- execution permission, requires eunuch.vim
keymap("n", "<leader><BS>", ":Remove<CR>:bd<CR>") -- undoable deletion of the file, requires eunuch.vim
keymap("v", "X", ":'<,'> w new.lua | normal gvd<CR>:buffer #<CR>:Rename ") -- refactor selection into new file

-- Option Toggling
keymap("n", "<leader>os", ":set spell!<CR>")
keymap("n", "<leader>or", ":set number! relativenumber!<CR>")
keymap("n", "<leader>ow", ":set wrap! relativenumber!<CR>")
