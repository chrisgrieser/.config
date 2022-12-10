require("utils")
local packer = require("packer")
--------------------------------------------------------------------------------

-- META
g.mapleader = ","

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", qol.copyLastCommand)

-- run [l]ast command [a]gain
keymap("n", "<leader>la", "@:")

-- search keymaps
keymap("n", "?", telescope.keymaps)

-- Theme Picker
keymap("n", "<leader>T", telescope.colorscheme)

-- Highlights
keymap("n", "<leader>H", telescope.highlights)

-- Mason
keymap("n", "<leader>M", ":Mason<CR>")

-- Update [P]lugins
keymap("n", "<leader>p", function()
	cmd [[update!]]
	packer.compile()
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
keymap("n", "ZZ", ":wall! | qa!<CR>")

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({"n", "x"}, "H", "0^") -- 0^ ensures fully scrolling to the left on long lines
keymap("o", "H", "^")
keymap({"n", "x", "o"}, "L", "$")
keymap({"x", "o"}, "J", "6j")
keymap({"n", "x", "o"}, "K", "6k")

keymap("n", "j", function() qol.overscroll("j") end)
keymap("n", "J", function() qol.overscroll("6j") end)
keymap({"n", "x"}, "G", "Gzz")

-- Jump History
keymap("n", "<C-h>", "<C-o>") -- Back
keymap("n", "<C-l>", "<C-i>") -- Forward

-- Search
keymap({"n", "x", "o"}, "-", [[/\v]]) -- German Keyboard, \v for very-magic search
keymap("n", "<Esc>", function()
	local clearPending = require("notify").pending() > 10 and true or false
	require("notify").dismiss {pending = clearPending}
	cmd [[nohl]] -- clear highlights
	cmd [[echo]] -- clear shortmessage
	cmd [[normal!lh]] -- clear lsp hover window
	require("lualine").refresh()
end)

keymap({"n", "x", "o"}, "+", "*") -- no more modifier key (German Layout)
keymap({"n", "x", "o"}, "*", "#") -- backwards on the same key (German Layout)

-- MARKS
keymap("", "ä", "`M") -- Goto Mark M
keymap("", "Ä", function() -- Set Mark M
	cmd [[normal!mM]]
	vim.notify(" Mark M set. ")
end)

-- FOLDING
keymap("n", "^", "za") -- quicker toggling of folds

-- [M]atch
keymap({"n", "x", "o"}, "m", "%")

-- Middle of the Line
keymap({"n", "x"}, "gm", "gM")

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

-- LIST
-- af -> a [f]unction
-- ao -> a c[o]ndition
-- q -> comment (mnemonic: [q]uiet text)
-- Q -> consecutive (big) comment
-- aa -> an [a]rgument
-- ah -> a [h]unk
-- ai -> a [i]ndentation
-- ad -> a [d]iagnostic
-- ae -> almost to the [e]nding of line

keymap({"o", "x"}, "iq", 'i"') -- [q]uote
keymap({"o", "x"}, "aq", 'a"')
keymap({"o", "x"}, "iz", "i'") -- [z]ingle quote
keymap({"o", "x"}, "az", "a'")
keymap({"o", "x"}, "at", "a`") -- [t]emplate-string
keymap({"o", "x"}, "it", "i`")
keymap({"o", "x"}, "ir", "i]") -- [r]ectangular brackets
keymap({"o", "x"}, "ar", "a]")
keymap({"o", "x"}, "ic", "i}") -- [c]urly brackets
keymap({"o", "x"}, "ac", "a}")
keymap({"o", "x"}, "am", "aW") -- [m]assive word
keymap({"o", "x"}, "im", "iW")
keymap("o", "an", "gn") -- [n]ext search result
keymap("o", "in", "gn")
keymap("o", "r", "}") -- [r]est of the paragraph

-- BUILT-IN ONES KEPT
-- ab: bracket
-- as: sentence
-- ap: paragraph
-- aw: word

-- FILE-TYPE-SPECIFIC TEXT OBJECTS
-- al: a [l]ink (markdown)
-- c: class
-- v: value

--------------------------------------------------------------------------------
-- Text Object definitions

keymap("n", "C", '"_C')
keymap("n", "<Space>", '"_ciw') -- change word
keymap("n", "<C-M-Space>", '"_daw') -- wordaround, since <S-Space> not fully supported, requires karabiner remapping it
keymap("x", "<Space>", '"_c')

-- change-subword ( = word excluding _ and - as word-parts)
keymap("n", "<leader><Space>", function()
	opt.iskeyword:remove {"_", "-"}
	cmd [[normal! "_diw]]
	cmd [[startinsert]] -- :normal does not allow to end in insert mode
	opt.iskeyword:append {"_", "-"}
end)

-- special plugin text objects
keymap({"x", "o"}, "ih", ":Gitsigns select_hunk<CR>")
keymap({"x", "o"}, "ah", ":Gitsigns select_hunk<CR>")

-- map ai to aI in languages where aI is not used anyway
augroup("indentobject", {})
autocmd("FileType", {
	group = "indentobject",
	callback = function()
		local ft = bo.filetype
		if not (ft == "yaml" or ft == "python" or ft == "markdown") then
			keymap({"x", "o"}, "ai", "aI", {remap = true, buffer = true})
		end
	end
})

-- textobj-[d]iagnostic
keymap({"x", "o"}, "id", function() require("textobj-diagnostic").nearest_diag() end)
keymap({"x", "o"}, "ad", function() require("textobj-diagnostic").nearest_diag() end)

-- disable text-objects from mini.ai in favor of my own
local miniaiConfig = {
	custom_textobjects = {
		b = false,
		q = false,
		t = false,
		f = false,
		a = false,
	},
	mappings = {
		around_next = "",
		inside_next = "",
		around_last = "",
		inside_last = "",
		goto_left = "",
		goto_right = "",
	},
}

-- custom text object "e": from cursor to [e]end of line minus 1 char
miniaiConfig.custom_textobjects.e = function()
	local row = fn.line(".")
	local col = fn.col(".")
	local eol = fn.col("$") - 1
	local from = {line = row, col = col}
	local to = {line = row, col = eol - 1}
	return {from = from, to = to}
end
require("mini.ai").setup(miniaiConfig)


--------------------------------------------------------------------------------

-- MACRO
-- one-off recording (+ q needs remapping due to being mapped to comments)
-- needs temporary remapping, since there is no "recording mode"
augroup("recording", {})
autocmd("RecordingLeave", {
	group = "recording",
	callback = function()
		keymap("n", "0", "qy") -- not saving in throwaway register z, so the respective keymaps can be used during a macro
		local sequence = vim.v.event.regcontents
		if sequence ~= "" then
			vim.notify(" Recorded\n " .. sequence, logTrace)
		else
			vim.notify(" Recording cancelled. ", logTrace)
		end
	end
})
autocmd("RecordingEnter", {
	group = "recording",
	callback = function()
		keymap("n", "0", "q")
		vim.notify(" Recording…", logTrace)
	end,
})
keymap("n", "9", "@y") -- quick replay (yes, I don't use counts that high)
keymap("n", "0", "qy") -- needs to be set initially
keymap("n", "c0", function() -- edit macro
	local macro = fn.getreg("y")
	vim.ui.input({prompt = "Edit Macro: ", default = macro}, function(editedMacro)
		if not (editedMacro) then return end -- cancellation
		fn.setreg("y", editedMacro)
		vim.notify(" Edited Macro\n " .. editedMacro, logTrace)
	end)
end)

--------------------------------------------------------------------------------

-- Whitespace Control
keymap("n", "!", "a <Esc>h") -- insert space
keymap("n", "=", "mzO<Esc>`z") -- add blank above
keymap("n", "_", "mzo<Esc>`z") -- add blank below
keymap("n", "d<Space>", function() -- delete blank lines except one
	if fn.getline(".") == "" then ---@diagnostic disable-line: param-type-mismatch
		cmd [[normal! "_dipO]]
	else
		vim.notify(" Line not empty.", logWarn)
	end
end)

-- Indentation
keymap("n", "<Tab>", ">>")
keymap("n", "<S-Tab>", "<<")
keymap("x", "<Tab>", ">gv")
keymap("x", "<S-Tab>", "<gv")

--------------------------------------------------------------------------------
-- EDITING

-- toggle word between Capital and lower case
keymap("n", "ü", "mzlblgueh~`z")
keymap("n", "Ü", "gUiw")

-- <leader>{char} → Append {char} to end of line
local trailingKeys = {".", ",", ";", ":", '"', "'"}
for _, v in pairs(trailingKeys) do
	keymap("n", "<leader>" .. v, "mzA" .. v .. "<Esc>`z")
end

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

-- search & replace
keymap("n", "<leader>f", [[:%sm/<C-r>=expand("<cword>")<CR>//g<Left><Left>]])
keymap("x", "<leader>f", ":sm///g<Left><Left><Left>")
keymap({"n", "x"}, "<leader>F", function() require("ssr").open() end) -- wrapped in function for lazy-loading

-- Duplicate Line / Selection (mnemonic: [r]eplicate)
keymap("n", "R", qol.duplicateLine)
keymap("n", "<A-r>", function() qol.duplicateLine {increment = true} end)
keymap("x", "R", qol.duplicateSelection)

-- Undo
keymap({"n", "x"}, "U", "<C-r>") -- redo
keymap("n", "<C-u>", qol.undoDuration)
keymap("n", "<leader>u", ":MundoToggle<CR>") -- undo tree
keymap("i", "<C-g>u<Space>", "<Space>") -- extra undo point for every space

-- Logging & Debugging
keymap("n", "<leader>ll", qol.quicklog)
keymap("n", "<leader>lr", qol.removeLog)

-- Sort & highlight duplicate lines
keymap({"n", "x"}, "<leader>S", [[:sort<CR>:g/^\(.*\)$\n\1$/<CR><CR>]]) -- second <CR> due to cmdheight=0

-- sane-gx
keymap("n", "gx", qol.bettergx)

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
keymap({"n", "x"}, "<leader>m", "ddpkJ") -- [m]erge line down
keymap("n", "|", "a<CR><Esc>k$") -- Split line at cursor

-- TreeSJ plugin + Splitjoin-Fallback
keymap("n", "<leader>s", function()
	cmd [[TSJToggle]]
	if bo.filetype == "lua" then
		cmd.mkview() -- HACK to not mess up lua folds
		vim.lsp.buf.format {async = false} -- not async to avoid race condition
		cmd [[noautocmd write! | edit %]] -- reload, no autocmd to not trigger rememberFolds augroup, with mkview (of the now non-existing folds) on bufleave
		cmd.loadview()
	else
		vim.lsp.buf.format {async = true} -- HACK: run formatter as workaround for https://github.com/Wansmer/treesj/issues/25
	end
end)

require("treesj").setup {use_default_keymaps = false}
augroup("splitjoinFallback", {}) -- HACK: https://github.com/Wansmer/treesj/discussions/19
autocmd("FileType", {
	pattern = "*",
	group = "splitjoinFallback",
	callback = function()
		local langs = require("treesj.langs")["presets"]
		if not (langs[bo.filetype]) then
			keymap("n", "<leader>s", ":SplitjoinSplit<CR>", {buffer = true})
		end
	end
})

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
keymap("x", "V", "j") -- repeatedly pressing "V" selects more lines (indented for Visual Line Mode)
keymap("x", "v", "<C-v>") -- `vv` from normal mode = visual block mode

--------------------------------------------------------------------------------
-- WINDOWS & SPLITS
keymap("", "<C-w>v", ":vsplit #<CR>") -- open the alternate file in the split instead of the current file
keymap("", "<C-w>h", ":split #<CR>")
keymap("", "<C-Right>", ":vertical resize +3<CR>") -- resizing on one key for sanity
keymap("", "<C-Left>", ":vertical resize -3<CR>")
keymap("", "<C-Down>", ":resize +3<CR>")
keymap("", "<C-Up>", ":resize -3<CR>")
keymap("n", "ö", "<C-w><C-w>") -- switch to next split

--------------------------------------------------------------------------------
-- CMD-Keybindings
if isGui() then

	keymap({"n", "x", "i"}, "<D-w>", qol.betterClose) -- cmd+w

	keymap({"n", "x", "i"}, "<D-z>", cmd.undo) -- cmd+z
	keymap({"n", "x", "i"}, "<D-S-z>", cmd.redo) -- cmd+shift+z
	keymap({"n", "x", "i"}, "<D-s>", cmd.write) -- cmd+s
	keymap("n", "<D-a>", "ggVG") -- cmd+a
	keymap("i", "<D-a>", "<Esc>ggVG")
	keymap("x", "<D-a>", "ggG")

	keymap({"n", "x"}, "<D-l>", function() -- show file in default GUI file explorer
		fn.system("open -R '" .. fn.expand("%:p") .. "'")
	end)
	keymap({"n", "x"}, "<D-1>", cmd.Lex) -- file tree (netrw)
	keymap({"n", "x"}, "<D-0>", ":messages<CR>") -- as cmd.function these wouldn't require confirmation
	keymap({"n", "x"}, "<D-9>", ":Notification<CR>")

	-- Multi-Cursor https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
	g.VM_maps = {-- cmd+j
		["Find Under"] = "<D-j>",
		["Visual Add"] = "<D-j>",
	}

	-- cut, copy & paste
	keymap("n", "<D-c>", "yy") -- no selection = line
	keymap("x", "<D-c>", "y")
	keymap("n", "<D-x>", "dd") -- no selection = line
	keymap("x", "<D-x>", "d")
	keymap({"n", "x"}, "<D-v>", "p")
	keymap("c", "<D-v>", "<C-r>+")
	keymap("i", "<D-v>", "<C-r><C-o>+")

	-- cmd+e: inline code
	keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>") -- no selection = word under cursor
	keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>")
	keymap("i", "<D-e>", "``<Left>")

	-- cmd+t: Template ${string}
	keymap("n", "<D-t>", "bi${<Esc>ea}<Esc>b") -- no selection = word under cursor
	keymap("x", "<D-t>", "<Esc>${<i}<Esc>${>la}<Esc>b")
	keymap("i", "<D-t>", "${}<Left>")
end

--------------------------------------------------------------------------------

-- BUFFERS
local function betterAltBuf() -- switch to alternate-file
	local noAltFile = fn.expand("#") == ""
	if noAltFile then
		vim.notify(" No alternate file. ", logWarn)
	else
		cmd.nohlsearch()
		cmd.buffer("#")
	end
end

-- HACK: fix for https://github.com/cshuaimin/ssr.nvim/issues/11
augroup("ssr-fix", {})
autocmd("BufReadPost", {
	group = "ssr-fix",
	callback = function()
		if bo.filetype == "ssr" then return end
		keymap("n", "<CR>", betterAltBuf)
	end
})

-- INFO: nohl added here, since it does not work with autocmds
keymap("n", "<BS>", ":nohl<CR><Plug>(CybuNext)") -- cycle between buffers
keymap("n", "<S-BS>", ":nohl<CR><Plug>(CybuPrev)")
keymap("n", "gb", telescope.buffers) -- open Buffer

require("cybu").setup {
	display_time = 1000,
	position = {
		anchor = "bottomcenter",
		max_win_height = 12,
		vertical_offset = 3,
	},
	style = {
		border = borderStyle,
		padding = 7,
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
-- FILES & GIT

-- File Switchers
keymap("n", "go", telescope.find_files) -- [o]pen file in parent-directory
keymap("n", "gO", telescope.git_files) -- [o]pen file in git directory
keymap("n", "gr", telescope.oldfiles) -- [r]ecent files
keymap("n", "gf", telescope.live_grep) -- search in [f]iles
keymap("n", "gR", telescope.resume) -- resume last search

-- File Operations (no shorthand for lazy-loading)
keymap("", "<C-p>", function() require("genghis").copyFilepath() end)
keymap("", "<C-n>", function() require("genghis").copyFilename() end)
keymap("", "<leader>x", function() require("genghis").chmodx() end)
keymap("", "<C-r>", function() require("genghis").renameFile() end)
keymap("", "<C-d>", function() require("genghis").duplicateFile() end)
keymap("", "<D-BS>", function() require("genghis").trashFile() end)
keymap("", "<D-n>", function() require("genghis").createNewFile() end)
keymap("x", "X", function() require("genghis").moveSelectionToNewFile() end)

-- Diffview
keymap("n", "<D-g>", function()
	vim.ui.input({prompt = "Search File History (empty = full history):"}, function(query)
		if not (query) then return
		elseif query == "" then cmd("DiffviewFileHistory %")
		else cmd("DiffviewFileHistory % -G" .. query)
		end
	end)
end)

-- GitLinker
keymap("n", "<leader>G", function()
	require("gitlinker").get_buf_range_url("n", {action_callback = require("gitlinker.actions").copy_to_clipboard})
	require("gitlinker").get_buf_range_url("n", {action_callback = require("gitlinker.actions").open_in_browser})
end)

keymap("x", "<leader>G", function()
	require("gitlinker").get_buf_range_url("v", {action_callback = require("gitlinker.actions").copy_to_clipboard})
	require("gitlinker").get_buf_range_url("v", {action_callback = require("gitlinker.actions").open_in_browser})
end)

--------------------------------------------------------------------------------

-- Option Toggling
keymap("n", "<leader>os", ":set spell!<CR>")
keymap("n", "<leader>or", ":set relativenumber!<CR>")
keymap("n", "<leader>on", ":set number!<CR>")
keymap("n", "<leader>ow", ":set wrap!<CR>")

--------------------------------------------------------------------------------

-- TERMINAL MODE
keymap("t", "<Esc>", [[<C-\><C-n>]]) -- normal mode in Terminal window
keymap("t", "ö", [[<C-\><C-n><C-w><C-w>]]) -- switch windows directyl from Terminal window
keymap("n", "<leader>g", [[:w<CR>:!acp ""<Left>]]) -- shell function `acp`, enabled via .zshenv
keymap("n", "6", ":ToggleTerm size=8<CR>")
keymap("x", "6", ":ToggleTermSendVisualSelection size=8<CR>")

--------------------------------------------------------------------------------

-- BUILD SYSTEM
keymap("n", "<leader>r", function()
	cmd.update()
	local filename = fn.expand("%:t")
	local parentFolder = fn.expand("%:p:h")
	local ft = bo.filetype

	if filename == "sketchybarrc" then
		fn.system("brew services restart sketchybar")

	elseif ft == "markdown" then
		local filepath = fn.expand("%:p")
		local pdfFilename = fn.expand("%:t:r") .. ".pdf"
		fn.system("pandoc '" .. filepath .. "' --output='" .. pdfFilename .. "' --pdf-engine=wkhtmltopdf")
		fn.system("open '" .. pdfFilename .. "'")

	elseif ft == "lua" then
		if parentFolder:find("nvim") then
			cmd.write()
			cmd.mkview() -- HACK: mkview and loadview needed to not loose folding when sourcing
			cmd.source("%")
			cmd.loadview()
			if filename:find("plugin%-list") then
				packer.compile()
				vim.notify(" Packer recompiled and " .. fn.expand("%") .. " reloaded. ")
			else
				vim.notify(" " .. fn.expand("%") .. " reloaded. ")
			end
		elseif parentFolder:find("hammerspoon") then
			os.execute('open -g "hammerspoon://hs-reload"')
		end

	elseif ft == "yaml" and parentFolder:find("/karabiner") then
		local result = fn.system [[osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"]]
		vim.notify(" " .. trim(result) .. " ")
		if filename == "finder-vim.yaml" then
			local curFile = fn.expand("%:p")
			cmd.saveas {os.getenv("HOME") .. "/Library/Mobile Documents/com~apple~CloudDocs/Repos/finder-vim-mode/finder-vim.yaml",
				bang = true}
			cmd.bwipeout()
			cmd.edit(curFile)
			vim.notify(" " .. filename .. " also duplicated. ")
		end

	elseif ft == "typescript" then
		cmd [[!npm run build]] -- not via fn.system to get the output in the cmdline

	elseif ft == "applescript" then
		cmd.AppleScriptRun()

	else
		vim.notify(" No build system set. ", logWarn)

	end
end)

--------------------------------------------------------------------------------

-- q / Esc to close special windows
augroup("quickQuit", {})
autocmd("FileType", {
	group = "quickQuit",
	pattern = specialFiletypes,
	callback = function()
		local opts = {buffer = true, silent = true, nowait = true}
		if bo.filetype == "TelescopePrompt" or bo.filetype == "ssr" then return end
		keymap("n", "<Esc>", cmd.close, opts)
		keymap("n", "q", cmd.close, opts)
	end
})
