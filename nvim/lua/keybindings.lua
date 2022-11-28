require("utils")
local packer = require("packer")
--------------------------------------------------------------------------------

-- META
g.mapleader = ","

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", qol.copyLastCommand)

-- run [l]ast command [a]gain
keymap("n", "<leader>la", qol.runLastCommandAgain)

-- [e]dit [l]ast command
keymap("n", "<leader>le", ":<Up>")

-- search keymaps
keymap("n", "?", telescope.keymaps)

-- Theme Picker
keymap("n", "<leader>T", telescope.colorscheme)

-- Highlights
keymap("n", "<leader>G", telescope.highlights)

-- Update [P]lugins
keymap("n", "<leader>p", function()
	cmd [[update!]]
	package.loaded["plugin-list"] = nil -- empty the cache for lua
	packer.startup(require("plugin-list").PluginList)
	packer.snapshot("packer-snapshot_" .. os.date("!%Y-%m-%d_%H-%M-%S"))
	packer.sync()
	cmd [[MasonUpdateAll]]
	-- remove oldest snapshot when more than 20
	local snapshotPath = fn.stdpath("config") .. "/packer-snapshots"
	os.execute([[cd ']] .. snapshotPath .. [[' ; ls -t | tail -n +20 | tr '\n' '\0' | xargs -0 rm]])
end)
keymap("n", "<leader>P", packer.status)

-- write all before quitting
keymap("n", "ZZ", ":wqall!<CR>")

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({"n", "x"}, "H", "0^") -- 0^ ensures fully scrolling to the left on long lines
keymap("o", "H", "^")
keymap({"n", "x", "o"}, "L", "$")
keymap({"x", "o"}, "J", "6j")
keymap({"n", "x", "o"}, "K", "6k")

keymap("n", "j", function() qol.overscroll("j") end, {silent = true})
keymap("n", "J", function() qol.overscroll("6j") end, {silent = true})
keymap({"n", "x"}, "G", "Gzz")

-- Sections
keymap("", "[", "{", {nowait = true}) -- slightly easier to press
keymap("", "]", "}", {nowait = true})

-- Jump History
keymap("n", "<C-h>", "<C-o>") -- Back
keymap("n", "<C-l>", "<C-i>") -- Forward

-- Search
keymap({"n", "x", "o"}, "-", "/") -- German Keyboard consistent with US Keyboard layout
keymap("n", "<Esc>", function() -- clear all
	require("notify").dismiss() -- notifications
	cmd [[nohl]] -- highlights
	cmd [[echo]] -- shortmessage
	cmd [[normal!lh]] -- lsp hover window
end, {silent = true})

keymap({"n", "x", "o"}, "+", "*") -- no more modifier key on German Keyboard
keymap({"n", "x", "o"}, "*", "#")

-- URLs
keymap("n", "gü", "/http.*<CR>:nohl<CR>") -- goto next
keymap("n", "gÜ", "?http.*<CR>:nohl<CR>") -- goto prev

-- MARKS
keymap("", "ä", "`M") -- Goto Mark M
keymap("", "Ä", "mM") -- Set Mark M


--------------------------------------------------------------------------------
-- NAVIGATION PLUGINS
-- vim.[m]atchup
keymap("", "m", "%", {remap = true}) -- remap to use matchup's % instead of builtin %
keymap({"o", "x"}, "im", "i%", {remap = true})
keymap({"o", "x"}, "am", "a%", {remap = true})

-- Leap
keymap("n", "ö", "<Plug>(leap-forward-to)")
keymap("n", "Ö", "<Plug>(leap-backward-to)")

-- Hunks
keymap("n", "gh", ":Gitsigns next_hunk<CR>")
keymap("n", "gH", ":Gitsigns prev_hunk<CR>")

--------------------------------------------------------------------------------

-- CLIPBOARD
keymap("n", "x", '"_x')
keymap("n", "c", '"_c')
keymap("n", "C", '"_C')
keymap("n", "gp", qol.pasteDifferently) -- paste charwise reg as linewise & vice versa

-- yanking without moving the cursor
-- visual https://stackoverflow.com/a/3806683#comment10788861_3806683
-- normal https://www.reddit.com/r/vim/comments/ekgy47/comment/fddnfl3/
keymap("x", "y", "ygv<Esc>")
augroup("yankKeepCursor", {})
autocmd({"CursorMoved", "VimEnter"}, {
	group = "yankKeepCursor",
	callback = function() g.cursorPreYankPos = fn.getpos(".") end,
})
autocmd("TextYankPost", {
	group = "yankKeepCursor",
	callback = function()
		if vim.v.event.operator == "y" then
			fn.setpos(".", g.cursorPreYankPos)
		end
	end
})

--------------------------------------------------------------------------------
-- TEXTOBJECTS

keymap("n", "C", '"_C')
keymap("n", "<Space>", '"_ciw') -- change word
keymap("n", "<C-M-Space>", '"_daw') -- wordaround, since <S-Space> not fully supported, requires karabiner remapping it
keymap("x", "<Space>", '"_c')

-- change sub-word
-- (i.e. a simpler version of vim-textobj-variable-segment, not supporting CamelCase)
keymap("n", "<leader><Space>", function()
	opt.iskeyword:remove {"_", "-"}
	cmd [[normal! "_diw]]
	cmd [[startinsert]] -- :Normal does not allow to end in insert mode
	opt.iskeyword:append {"_", "-"}
end)

-- special plugin text objects
keymap({"x", "o"}, "ih", ":Gitsigns select_hunk<CR>", {silent = true})
keymap({"x", "o"}, "ah", ":Gitsigns select_hunk<CR>", {silent = true})

-- map ai to aI in languages where aI is not used anyway
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
-- q -> comment
-- aa -> an argument

keymap({"o", "x"}, "iq", 'i"') -- double [q]uote
keymap({"o", "x"}, "aq", 'a"')
keymap({"o", "x"}, "iz", "i'") -- single quote (mnemonic: [z]itation)
keymap({"o", "x"}, "az", "a'")
keymap({"o", "x"}, "ir", "i]") -- [r]ectangular brackets
keymap({"o", "x"}, "ar", "a]")
keymap({"o", "x"}, "ic", "i}") -- [c]urly brackets
keymap({"o", "x"}, "ac", "a}")
keymap("o", "r", "}") -- [r]est of the paragraph
keymap("o", "R", "{")

--------------------------------------------------------------------------------

-- MACRO
-- one-off recording (+ q needs remapping due to being mapped to comments)
-- needs temporary remapping, since there is no "recording mode"
augroup("recording", {})
autocmd("RecordingLeave", {
	group = "recording",
	callback = function()
		keymap("n", "0", "qy") -- not saving in throwaway register z, so the respective keymaps can be used during a macro
		vim.notify(" Recorded\n " .. vim.v.event.regcontents)
	end
})
autocmd("RecordingEnter", {
	group = "recording",
	callback = function() keymap("n", "0", "q") end,
})
keymap("n", "9", "@y") -- quick replay (I don't use counts that high anyway)
keymap("n", "0", "qy") -- needs to be set initially
keymap("n", "c0", function() -- edit macro
	local macro = fn.getreg("y")
	vim.ui.input({prompt = "Edit Macro: ", default = macro}, function(editedMacro)
		if not (editedMacro) then return end -- cancellation
		fn.setreg("y", editedMacro)
		vim.notify(" Edited Macro\n " .. editedMacro)
	end)
end)

--------------------------------------------------------------------------------

-- Whitespace Control
keymap("n", "!", "a <Esc>h") -- insert space
keymap("n", "=", "mzO<Esc>`z") -- add blank above
keymap("n", "_", "mzo<Esc>`z") -- add blank below
keymap("n", "d<Space>", function() -- reduce multiple blank lines to exactly one
	if fn.getline(".") == "" then ---@diagnostic disable-line: param-type-mismatch
		cmd [[normal! "_dipO]]
	else
		vim.notify(" Line not empty.", logWarn) 
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

--------------------------------------------------------------------------------
-- EDITING

-- toggle word between Capital and lower case
keymap("n", "ü", "mzlblgueh~`z")

-- toggle case or switch direction of char (e.g. > to <)
keymap("n", "Ü", qol.reverse)

-- <leader>{char} → Append {char} to end of line
local trailingKeys = {".", ",", ";", ":", '"', "'", "(", ")", "[", "]", "{", "}", "|", "/", "\\", "`"}
for _, v in pairs(trailingKeys) do
	keymap("n", "<leader>" .. v, "mzA" .. v .. "<Esc>`z")
end
-- Remove last character from line, e.g., a trailing comma
keymap("n", "X", 'mz$"_x`z')

-- Spelling (mnemonic: [z]pe[l]ling)
keymap("n", "zl", telescope.spell_suggest)
keymap("n", "gl", "]s") -- next misspelling
keymap("n", "gL", "[s") -- prev misspelling
keymap("n", "zf", "mz1z=`z") -- auto[f]ix word under cursor (= select 1st suggestion)

-- [S]ubstitute Operator (substitute.nvim)
local substi = require("substitute")
local exchange = require("substitute.exchange")
substi.setup()
keymap("n", "s", substi.operator)
keymap("n", "ss", substi.line)
keymap("n", "S", substi.eol)
keymap("n", "sx", exchange.operator)
keymap("n", "sxx", exchange.line)
keymap("x", "X", exchange.visual)

-- search & replace
keymap("n", "<leader>f", [[:%s/<C-r>=expand("<cword>")<CR>//g<Left><Left>]])
keymap("x", "<leader>f", ":s///g<Left><Left>")
keymap({"n", "x"}, "<leader>F", function() require("ssr").open() end) -- wrapped in function for lazy-loading

-- Duplicate Line / Selection (mnemonic: [r]eplicate)
keymap("n", "R", qol.duplicateLine)
keymap("n", "<A-r>", function() qol.duplicateLine {increment = true} end)
keymap("x", "R", qol.duplicateSelection)

-- Undo
keymap({"n", "x"}, "U", "<C-r>") -- redo
keymap("n", "<C-u>", qol.undoDuration)
keymap("n", "<leader>u", ":UndotreeToggle<CR>") -- undo tree
keymap("i", "<C-g>u<Space>", "<Space>") -- extra undo point for every space

-- Logging & Debugging
keymap("n", "<leader>ll", qol.quicklog)
keymap("n", "<leader>lr", qol.removeLog)

-- Sort
keymap({"n", "x"}, "<leader>S", ":sort<CR>")

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
keymap({"n", "x"}, "gM", "gJ") -- [M]erge line up, don't add spaces
keymap({"n", "x"}, "gm", "ddpkJ") -- [m]erge line down
keymap("n", "|", "a<CR><Esc>k$") -- Split line at cursor
keymap("n", "<leader>s", ":TSJToggle<CR>")

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
keymap("x", "V", "j") -- repeatedly pressing "V" selects more lines (indented for Visual Line Mode)
keymap("x", "v", "<C-v>") -- `vv` from normal mode goes to visual block mode

--------------------------------------------------------------------------------
-- WINDOWS & SPLITS
keymap("", "<C-w>v", ":vsplit #<CR>") -- open the alternate file in the split instead of the current file
keymap("", "<C-w>h", ":split #<CR>")
keymap("", "<C-Right>", ":vertical resize +3<CR>") -- resizing on one key for sanity
keymap("", "<C-Left>", ":vertical resize -3<CR>")
keymap("", "<C-Down>", ":resize +3<CR>")
keymap("", "<C-Up>", ":resize -3<CR>")
keymap("n", "gw", "<C-w><C-w>") -- switch to next split

--------------------------------------------------------------------------------

-- BUFFERS
keymap("n", "<CR>", ":nohl<CR><C-^>", {silent = true}) -- switch to alt-file
keymap("n", "<BS>", "<Plug>(CybuNext)") -- cycle between buffers
keymap("n", "<S-BS>", "<Plug>(CybuPrev)")
keymap("n", "<Del>", function() -- <C-BS> = <Del> (via Karabiner)
	cmd [[bdelete]]
	vim.notify(" Buffer deleted. ")
end)
keymap("n", "gb", telescope.buffers) -- open [b]uffer

require("cybu").setup {
	display_time = 1500,
	position = {
		anchor = "bottomcenter",
		max_win_height = 12,
		vertical_offset = 2,
	},
	style = {
		border = borderStyle,
		padding = 2,
		path = "tail",
		hide_buffer_id = true,
		highlights = {
			current_buffer = "CursorLine",
			adjacent_buffers = "Normal",
		},
	},
	behavior = {
		mode = {
			default = {
				switch = "immediate",
				view = "paging",
			},
		},
	},
	exclude = specialFiletypes,
}

--------------------------------------------------------------------------------
-- FILES

-- File Switchers
keymap("n", "go", telescope.find_files) -- [o]pen file in parent-directory
keymap("n", "gO", telescope.git_files) -- [o]pen file in git directory
keymap("n", "gr", telescope.oldfiles) -- [r]ecent files
keymap("n", "gf", telescope.live_grep) -- search in [f]iles
keymap("n", "gR", telescope.resume) -- resume last search

-- File Operations (genghis-nvim)
local genghis = require("genghis")
keymap("", "<C-p>", genghis.copyFilepath)
keymap("", "<C-n>", genghis.copyFilename)
keymap("", "<leader>x", genghis.chmodx)
keymap("", "<C-r>", genghis.renameFile)
keymap("", "<C-d>", genghis.duplicateFile)
keymap("", "<D-BS>", genghis.trashFile)
keymap("", "<D-n>", genghis.createNewFile)
keymap("x", "X", genghis.moveSelectionToNewFile)

-- Diffview
keymap("n", "<C-g>", function()
	vim.ui.input({prompt = "Search File History (empty = full history):"}, function(query)
		if not (query) then return
		elseif query == "" then cmd("DiffviewFileHistory %")
		else cmd("DiffviewFileHistory % -G" .. query)
		end
	end)
end)

--------------------------------------------------------------------------------

-- Option Toggling
keymap("n", "<leader>os", ":set spell!<CR>")
keymap("n", "<leader>or", ":set relativenumber!<CR>")
keymap("n", "<leader>on", ":set number!<CR>")
keymap("n", "<leader>ow", ":set wrap!<CR>")

--------------------------------------------------------------------------------

-- TERMINAL MODE
keymap("n", "<leader>t", ":10split<CR>:terminal<CR>")
keymap("n", "<leader>g", [[:w<CR>:!acp ""<Left>]]) -- shell function, enabled via .zshenv

--------------------------------------------------------------------------------

-- BUILD SYSTEM
keymap("n", "<leader>r", function()
	cmd [[update!]]
	local filename = fn.expand("%:t")
	local parentFolder = fn.expand("%:p:h")

	if filename == "sketchybarrc" then
		fn.system("brew services restart sketchybar")

	elseif bo.filetype == "markdown" then
		local filepath = fn.expand("%:p")
		local pdfFilename = fn.expand("%:t:r") .. ".pdf"
		fn.system("pandoc '" .. filepath .. "' --output='" .. pdfFilename .. "' --pdf-engine=wkhtmltopdf")
		fn.system("open '" .. pdfFilename .. "'")

	elseif bo.filetype == "lua" then
		if parentFolder:find("nvim") then
			cmd [[write! | source %]]
			if filename:find("plugin%-list") then
				require("packer").compile()
				vim.notify(" 'plugins-list.lua' reloaded and re-compiled. ")
			else
				vim.notify(" " .. fn.expand("%") .. " reloaded. ")
			end
		elseif parentFolder:find("hammerspoon") then
			os.execute('open -g "hammerspoon://hs-reload"')
		end

	elseif bo.filetype == "yaml" and parentFolder:find(".config/karabiner") then
		os.execute [[osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"]]

	elseif filename:find("vale%.ini") then
		vim.notify(" Loading… ")
		fn.system [[cd "$HOME" && vale sync && open "$HOME/.config/vale/styles"]]

	elseif bo.filetype == "typescript" then
		cmd [[!npm run build]] -- not via fn.system to get the output in the cmdline

	elseif bo.filetype == "applescript" then
		cmd [[AppleScriptRun]]

	else
		vim.notify(" No build system set.", logWarn)

	end
end)

--------------------------------------------------------------------------------

-- q / Esc to close special windows
autocmd("FileType", {
	pattern = specialFiletypes,
	callback = function()
		local opts = {buffer = true, silent = true, nowait = true}
		-- these bindings do not work with Telescope
		if bo.filetype == "TelescopePrompt" then return end

		keymap("n", "<Esc>", ":close<CR>", opts)
		keymap("n", "q", ":close<CR>", opts)
	end
})
