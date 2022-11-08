require("utils")
local qol = require("quality-of-life")
--------------------------------------------------------------------------------
-- META
g.mapleader = ","

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", ':let @+=@:<CR>:echo "Copied:"@:<CR>')

-- run [l]ast command [a]gain
keymap("n", "<leader>la", ":<C-r>:<CR>")

-- search keymaps
keymap("n", "?", telescope.keymaps)

-- Theme Picker
keymap("n", "<leader>T", telescope.colorscheme)

-- Highlights
keymap("n", "<leader>G", telescope.highlights)

-- Update [P]lugins
keymap("n", "<leader>p", function()
	cmd [[nohl]]
	cmd [[update! ~/.config/nvim/lua/plugin-list.lua]]
	package.loaded["plugin-list"] = nil -- empty the cache for lua
	local packer = require("packer")
	packer.startup(require("plugin-list").PluginList)
	packer.sync()
	cmd [[MasonUpdateAll]]
end)
keymap("n", "<leader>P", ":PackerStatus<CR>")

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({"n", "x"}, "H", "0^") -- 0^ ensures fully scrolling to the left on long lines
keymap("o", "H", "^")
keymap({"n", "x", "o"}, "L", "$")
keymap({"x", "o"}, "J", "7j")
keymap({"n", "x", "o"}, "K", "7k")

keymap("n", "j", function() qol.overscroll("j") end, {silent = true})
keymap("n", "J", function() qol.overscroll("7j") end, {silent = true})
keymap({"n", "x"}, "G", "Gzz")

-- Sections
keymap("", "[", "{", {nowait = true}) -- slightly easier to press
keymap("", "]", "}", {nowait = true})

-- Jump History
keymap("n", "<C-h>", "<C-o>") -- Back
keymap("n", "<C-l>", "<C-i>") -- Forward

-- Hunks
keymap("n", "gh", ":Gitsigns next_hunk<CR>")
keymap("n", "gH", ":Gitsigns next_prev<CR>")

-- Hop
keymap("n", "ö", ":HopWordAC<CR>")
keymap("n", "Ö", ":HopWordBC<CR>")

-- Search
keymap({"n", "x", "o"}, "-", "/") -- German Keyboard consistent with US Keyboard layout
keymap("n", "/", "/\v") -- more PCRE-like regex patterns (:h magic)
keymap("n", "<Esc>", ":nohl<CR>:echo<CR>lh", {silent = true}) -- clear highlights & shortmessage, lh clears hover window
keymap({"n", "x", "o"}, "+", "*") -- no more modifier key on German Keyboard

-- URLs
keymap("n", "gü", "/http.*<CR>:nohl<CR>") -- goto next
keymap("n", "gÜ", "?http.*<CR>:nohl<CR>") -- goto prev

-- Marks
keymap("", "ä", "`") -- Goto Mark

--------------------------------------------------------------------------------

-- CLIPBOARD
keymap("n", "x", '"_x')
keymap("n", "c", '"_c')
keymap("n", "C", '"_C')
keymap("n", "P", '"0p') -- paste what was yanked, not what was deleted

--------------------------------------------------------------------------------

-- TEXT OBJECTS
keymap("n", "<Space>", '"_ciw') -- change word
keymap("n", "<C-A-Space>", '"_daw') -- wordaround, since <S-Space> not fully supported, requires karabiner remapping it
keymap("x", "<Space>", '"_c')

-- change sub-word
-- (i.e. a simpler version of vim-textobj-variable-segment, not supporting CamelCase)
keymap("n", "<leader><Space>", function()
	opt.iskeyword = opt.iskeyword - {"_", "-"}
	cmd [[normal! "_diw]]
	cmd [[startinsert]] -- :Normal does not allow to end in insert mode
	opt.iskeyword = opt.iskeyword + {"_", "-"}
end)

keymap({"o", "x"}, "iq", 'i"') -- double [q]uote
keymap({"o", "x"}, "aq", 'a"')
keymap({"o", "x"}, "iz", "i'") -- single quote (mnemonic: [z]itation)
keymap({"o", "x"}, "az", "a'")
keymap({"o", "x"}, "ir", "i]") -- [r]ectangular brackets
keymap({"o", "x"}, "ar", "a]")
keymap({"o", "x"}, "ic", "i}") -- [c]urly brackets
keymap({"o", "x"}, "ac", "a}")
keymap({"o", "x"}, "in", "gn") -- [n]ext search hit
keymap({"o", "x"}, "an", "gn")
keymap({"o", "x"}, "r", "}") -- [r]est of the paragraph
keymap({"o", "x"}, "R", "{")

-- special plugin text objects
keymap({"x", "o"}, "ih", ":Gitsigns select_hunk<CR>", {silent = true})
keymap({"x", "o"}, "ah", ":Gitsigns select_hunk<CR>", {silent = true})

-- map ai to aI
-- except for yaml, python and md, where aI does not make sense
augroup("indentobject", {})
autocmd("BufEnter", {
	group = "indentobject",
	callback = function()
		local ft = bo.filetype
		if not (ft == "yaml" or ft == "python" or ft == "markdown") then
			keymap({"x", "o"}, "ai", "aI", {remap = true, buffer = true})
		end
	end
})

-- treesitter textobjects:
-- af -> a function
-- aC -> a condition
-- c -> comment
-- aa -> an argument

require("nvim-surround").setup {
	move_cursor = false,
	keymaps = {
		insert = "<C-g>s",
		visual = "s",
	},
	aliases = {-- aliases should match the bindings further above
		["b"] = ")",
		["c"] = "}",
		["r"] = "]",
		["q"] = '"',
		["z"] = "'",
	},
}

--------------------------------------------------------------------------------

-- COMMENTS (mnemonic: [q]uiet text)
require("Comment").setup {
	toggler = {
		line = "qq",
		block = "<Nop>",
	},
	opleader = {
		line = "q",
		block = "<Nop>",
	},
	extra = {
		above = "qO",
		below = "qo",
		eol = "Q",
	},
}

-- effectively creating "q" as comment textobj, can't map directly to q since
-- overlap in visual mode where q can be object and operator. However, this
-- method here also has the advantage of making it possible to preserve cursor
-- position.
keymap("n", "dq", "mzdCOM`z", {remap = true}) -- requires remap for treesitter and comments.nvim mappings
keymap("n", "yq", "mzyCOM`z", {remap = true})
keymap("n", "gUq", "mzgUCOM`z", {remap = true}) -- uppercase comment
keymap("n", "sq", "mzsCOM`z", {remap = true})
keymap("n", "cq", 'mz"_dCOMxQ', {remap = true}) -- delete & append comment to preserve commentstring

--------------------------------------------------------------------------------

-- MACRO & SUBSTITUTION
-- one-off recording (+ q needs remapping due to being mapped to comments)
-- needs temporary remapping, since there is no "recording mode"
augroup("recording", {})
autocmd({"RecordingLeave", "VimEnter"}, {
	group = "recording",
	callback = function() keymap("n", "0", "qy") end -- not saving in throwaway register z, so the respective keymaps can be used during a macro
})
autocmd("RecordingEnter", {
	group = "recording",
	callback = function() keymap("n", "0", "q") end
})
keymap("n", "9", "qy") -- quick replay (don't use counts that high anyway)

-- find & replace under cursor
keymap("n", "<leader>f", ':% s/<C-r>=expand("<cword>")<CR>//g<Left><Left>')

-- find & replace selection
keymap("v", "<leader>f", [[<Esc>:'<,'> s/\(.*\)/\1/<Left><Left><Left>]])

--------------------------------------------------------------------------------

-- Whitespace Control
keymap("n", "!", "a <Esc>h") -- insert space
keymap("n", "=", "mzO<Esc>`z") -- add blank above
keymap("n", "_", "mzo<Esc>`z") -- add blank below
keymap("n", "<BS>", function() -- reduce multiple blank lines to exactly one
	if fn.getline(".") == "" then ---@diagnostic disable-line: param-type-mismatch
		cmd [[normal! "_dipO]]
	else
		print("Line not empty.")
	end
end)

-- [H]ori[z]ontal Ruler
keymap("n", "zh", qol.hr)

-- Indention
keymap("n", "<Tab>", ">>")
keymap("n", "<S-Tab>", "<<")
keymap("x", "<Tab>", ">gv")
keymap("x", "<S-Tab>", "<gv")

keymap({"n", "x"}, "^", "=") -- auto-indent
keymap("n", "^^", "mz=ip`z") -- since indenting paragraph is far more common than indenting a line
keymap("n", "^A", "mzgg=G`z") -- entire file

--------------------------------------------------------------------------------

-- toggle word between Capital and lower case
keymap("n", "ü", "mzlblgueh~`z")

-- toggle case or switch direction of char (e.g. > to <)
keymap("n", "Ü", qol.reverse)

-- <leader>{char} → Append {char} to end of line
local trailingKeys = {".", ",", ";", ":", '"', "'", "(", ")", "[", "]", "{", "}", "|", "/", "\\", "`"}
for i = 1, #trailingKeys do
	keymap("n", "<leader>" .. trailingKeys[i], "mzA" .. trailingKeys[i] .. "<Esc>`z")
end
-- Remove last character from line
keymap("n", "X", 'mz$"_x`z')

-- Spelling (mnemonic: [z]pelling)
keymap("n", "zl", telescope.spell_suggest)
keymap("n", "gl", "]s") -- next misspelling
keymap("n", "gL", "[s") -- prev misspelling
keymap("n", "zf", "1z=") -- auto[f]ix word under cursor (= select 1st suggestion)

-- [S]ubstitute Operator (substitute.nvim)
local substi = require("substitute")
substi.setup()
keymap("n", "s", substi.operator)
keymap("n", "ss", substi.line)
keymap("n", "S", substi.eol)
keymap("x", "s", substi.visual)

-- Duplicate Line / Selection (mnemonic: [r]eplicate)
keymap("n", "R", qol.duplicateLine)
keymap("n", "<A-r>", function() qol.duplicateLine {increment = true} end)
keymap("n", "<A-r>", function() qol.duplicateLine {increment = true} end)
keymap("x", "R", qol.duplicateSelection)

-- Undo
keymap({"n", "x"}, "U", "<C-r>") -- redo
keymap("n", "<C-u>", "U") -- undo line, needs remapping since shadowed
keymap("n", "<leader>u", ":UndotreeToggle<CR>") -- undo tree

-- Logging
keymap("n", "<leader>ll", function() qol.quicklog(true) end)

--------------------------------------------------------------------------------

-- Line & Character Movement
keymap("n", "<Down>", qol.moveLineDown)
keymap("n", "<Up>", qol.moveLineUp)
keymap("x", "<Down>", qol.moveSelectionDown)
keymap("x", "<Up>", qol.moveSelectionUp)
keymap("n", "<Right>", qol.moveCharRight)
keymap("n", "<Left>", qol.moveCharLeft)
keymap("x", "<Right>", qol.moveSelectionRight)
keymap("x", "<Left>", qol.moveSelectionLeft)

-- Merging / Splitting Lines
keymap({"n", "x"}, "M", "J") -- [M]erge line up
keymap({"n", "x"}, "gm", "ddpkJ") -- [m]erge line down
g.splitjoin_split_mapping = "" -- disable default mappings
g.splitjoin_join_mapping = ""

keymap("n", "<leader>m", ":SplitjoinJoin<CR>")
keymap("n", "<leader>s", ":SplitjoinSplit<CR>")
keymap("n", "|", "a<CR><Esc>k$") -- Split line at cursor
keymap("n", "<leader>q", "gqq") -- needs remapping since shadowed

--------------------------------------------------------------------------------
-- INSERT MODE & COMMAND MODE
keymap("i", "<C-e>", "<Esc>A") -- EoL
keymap("i", "<C-k>", "<Esc>lDi") -- kill line
keymap("i", "<C-a>", "<Esc>I") -- BoL
keymap("c", "<C-a>", "<Home>")
keymap("c", "<C-e>", "<End>")
keymap("c", "<C-u>", "<C-e><C-u>") -- clear

--------------------------------------------------------------------------------
-- VISUAL MODE
keymap("x", "p", "P") -- do not override register when pasting
keymap("x", "P", "p") -- override register when pasting

keymap("n", "V", "Vj") -- visual line mode starts with two lines selected
keymap("x", "V", "j") -- repeatedly pressing "V" selects more lines (indented for Visual Line Mode)

keymap("x", "y", "ygv<Esc>") -- yanking in visual mode keeps position https://stackoverflow.com/a/3806683#comment10788861_3806683

--------------------------------------------------------------------------------
-- WINDOW AND BUFFERS
keymap("", "<C-w>v", ":vsplit #<CR>") -- open the alternate file in the split instead of the current file
keymap("", "<C-w>h", ":split #<CR>")
keymap("", "<C-Right>", ":vertical resize +3<CR>") -- resizing on one key for sanity
keymap("", "<C-Left>", ":vertical resize -3<CR>")
keymap("", "<C-Down>", ":resize +3<CR>")
keymap("", "<C-Up>", ":resize -3<CR>")
keymap("n", "gw", "<C-w><C-w>") -- switch to next split

-- Buffers
keymap("", "<C-Tab>", "<C-^>") -- for footpedal
keymap({"n", "x"}, "gt", ":nohl<CR><C-^>", {silent = true}) -- switch to alt-file (use vim's buffer model instead of tabs)

--------------------------------------------------------------------------------
-- FILES

-- File switchers
keymap("n", "go", telescope.find_files) -- [o]pen file in parent-directory
keymap("n", "gO", telescope.git_files) -- [o]pen file in git directory
keymap("n", "gr", telescope.oldfiles) -- [r]ecent files
keymap("n", "gb", telescope.buffers) -- open [b]uffer
keymap("n", "gf", telescope.live_grep) -- search in [f]iles
keymap("n", "gR", telescope.resume) -- search in [f]iles
keymap("n", "gF", "gf") -- needs remapping since shadowed

-- File Operations
keymap("", "<C-p>", ':let @+ = expand("%:p")<CR>:echo "Copied:"expand("%:p")<CR>') -- copy path of current file
keymap("", "<C-n>", ':let @+ = expand("%:t")<CR>:echo "Copied:"expand("%:t")<CR>') -- copy name of current file
keymap("n", "<leader>x", ':!chmod +x %:p<CR><CR>:echo "Execution permission granted."<CR>')
keymap("x", "X", ":write Untitled.lua | normal! gvd<CR>:buffer #<CR> ") -- refactor selection into new file
keymap("", "<C-r>", qol.renameFile)
keymap("", "<C-d>", qol.duplicateFile)

-- Option Toggling
keymap("n", "<leader>os", ":set spell!<CR>")
keymap("n", "<leader>or", ":set relativenumber!<CR>")
keymap("n", "<leader>on", ":set number!<CR>")
keymap("n", "<leader>ow", ":set wrap! <CR>")

--------------------------------------------------------------------------------

-- TERMINAL MODE
keymap("n", "<leader>t", ":10split<CR>:terminal<CR>")
keymap("n", "<leader>g", ":w<CR>:!acp ") -- shell function, enabled via .zshenv

--------------------------------------------------------------------------------

-- BUILD SYSTEM
keymap("n", "<leader>r", function()
	cmd [[update]]
	local filename = fn.expand("%:t")

	if filename == "sketchybarrc" then
		fn.system("brew services restart sketchybar")

	elseif bo.filetype == "markdown" then
		local filepath = fn.expand("%:p")
		local pdfFilename = fn.expand("%:t:r") .. ".pdf"
		fn.system("pandoc '" .. filepath .. "' --output='" .. pdfFilename .. "' --pdf-engine=wkhtmltopdf")
		fn.system("open '" .. pdfFilename .. "'")

	elseif bo.filetype == "lua" then
		local parentFolder = fn.expand("%:p:h")
		if not (parentFolder) then return end
		if parentFolder:find("nvim") then
			cmd [[write! | source % | echo "Neovim config reloaded."]]
		elseif parentFolder:find("hammerspoon") then
			os.execute('open -g "hammerspoon://hs-reload"')
		end

	elseif bo.filetype == "yaml" and fn.getcwd():find(".config/karabiner") then
		os.execute [[osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"]]

	elseif bo.filetype == "typescript" then
		cmd [[!npm run build]] -- not via fn.system to get the output in the cmdline

	elseif bo.filetype == "applescript" then
		cmd [[AppleScriptRun]]

	else
		print("No build system set.")

	end
end)

--------------------------------------------------------------------------------

-- q / Esc to close special windows
autocmd("FileType", {
	pattern = specialFiletypes,
	callback = function()
		local opts = {buffer = true, silent = true, nowait = true}
		keymap("n", "<Esc>", ":close<CR>", opts)
		keymap("n", "q", ":close<CR>", opts)
	end
})
