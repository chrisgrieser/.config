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
	vim.notify("Mark M set.")
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
opt.clipboard = "unnamedplus"
keymap("n", "x", '"_x')
keymap("n", "c", '"_c')
keymap("n", "C", '"_C')

require("yanky").setup {
	ring = {history_length = 25},
	highlight = {timer = 1500},
}

keymap({"n", "x"}, "p", "<Plug>(YankyPutAfter)")
keymap("n", "P", "<Plug>(YankyCycleForward)")
keymap("n", "gp", qol.pasteDifferently) -- paste charwise reg as linewise & vice versa
keymap("n", "gP", "<Plug>(YankyCycleBackward)")

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

-- MACROS
local recorder = require("recorder")
recorder.setup {
	slots = {"a", "b"},
	clear = true,
	mapping = {
		startStopRecording = "0",
		playMacro = "9",
		editMacro = "c0",
		switchSlot = "<C-0>",
	}
}

--------------------------------------------------------------------------------

-- Whitespace Control
keymap("n", "!", "a <Esc>h") -- insert space
keymap("n", "=", "mzO<Esc>`z") -- add blank above
keymap("n", "_", "mzo<Esc>`z") -- add blank below
keymap("n", "d<Space>", function() -- delete blank lines except one
	if fn.getline(".") == "" then ---@diagnostic disable-line: param-type-mismatch
		cmd [[normal! "_dipO]]
	else
		vim.notify("Line not empty.", logWarn)
	end
end)

-- Indentation
keymap("n", "<Tab>", ">>")
keymap("n", "<S-Tab>", "<<")
keymap("x", "<Tab>", ">gv")
keymap("x", "<S-Tab>", "<gv")

--------------------------------------------------------------------------------
-- EDITING

-- Casing
keymap("n", "ü", "mzlblgueh~`z", {desc = "toggle capital/lowercase of word"})
keymap("n", "Ü", "gUiw", {desc = "uppercase word"})
keymap("n", "~", "~h", {desc = "switch char case (w/o) moving"})

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

-- ISwap
keymap("n", "X", cmd.ISwapWith, {desc = "swap nodes"})

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
keymap("x", "V", "j") -- repeatedly pressing "V" selects more lines (indented for Visual Line Mode)
keymap("x", "v", "<C-v>") -- `vv` from normal mode = visual block mode
keymap("x", "u", "<Esc>u") -- actually undo/redo in visual mode
keymap("x", "U", "<Esc><C-r>")

--------------------------------------------------------------------------------
-- WINDOWS & SPLITS
keymap("", "<C-w>v", ":vsplit #<CR>") -- open the alternate file in the split instead of the current file
keymap("", "<C-w>h", ":split #<CR>")
keymap("", "<C-Right>", ":vertical resize +3<CR>") -- resizing on one key for sanity
keymap("", "<C-Left>", ":vertical resize -3<CR>")
keymap("", "<C-Down>", ":resize +3<CR>")
keymap("", "<C-Up>", ":resize -3<CR>")
keymap("n", "ö", "<C-w>w") -- switch to next split
keymap("n", "Ö", "<C-w>o") -- close other window(s)

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
	if fn.expand("#") == "" then
		vim.notify("No alternate file.", logWarn)
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

-- cycle between buffers
keymap("n", "<BS>", [[:nohl<CR><Plug>(CybuNext)]])

-- Buffer selector
keymap("n", "gb", function()
	local moreThanOneBuf = #(fn.getbufinfo {buflisted = 1}) > 1
	if moreThanOneBuf then
		cmd.nohlsearch()
		telescope.buffers()
	else
		vim.notify("Only one buffer open.")
	end
end)

--------------------------------------------------------------------------------
-- FILES

-- File Switchers
keymap("n", "go", telescope.find_files) -- [o]pen file in parent-directory
keymap("n", "gO", telescope.git_files) -- [o]pen file in git directory
keymap("n", "gr", telescope.oldfiles) -- [r]ecent files
keymap("n", "gF", telescope.live_grep) -- search in [f]iles
keymap("n", "gR", telescope.resume) -- resume last search

-- File Operations (no shorthand for lazy-loading)
keymap("n", "<C-p>", function() require("genghis").copyFilepath() end)
keymap("n", "<C-n>", function() require("genghis").copyFilename() end)
keymap("n", "<leader>x", function() require("genghis").chmodx() end)
keymap("n", "<C-r>", function() require("genghis").renameFile() end)
keymap("n", "<C-d>", function() require("genghis").duplicateFile() end)
keymap("", "<D-BS>", function() require("genghis").trashFile() end)
keymap("", "<D-n>", function() require("genghis").createNewFile() end)
keymap("x", "X", function() require("genghis").moveSelectionToNewFile() end)

--------------------------------------------------------------------------------
-- GIT

-- Diffview
keymap("n", "<D-g>", function()
	vim.ui.input({prompt = "Git Pickaxe (empty = full history):"}, function(query)
		if not (query) then return
		elseif query == "" then cmd("DiffviewFileHistory %")
		else cmd("DiffviewFileHistory % -G" .. query)
		end
	end)
end)

-- GitLinker: Copy & Open in Browser
keymap("n", "<leader>G", function()
	require("gitlinker").get_buf_range_url("n", {action_callback = require("gitlinker.actions").copy_to_clipboard})
	require("gitlinker").get_buf_range_url("n", {action_callback = require("gitlinker.actions").open_in_browser})
end)

keymap("v", "<leader>G", function() -- this seems to not work with xmap, requires vmap
	require("gitlinker").get_buf_range_url("v", {action_callback = require("gitlinker.actions").copy_to_clipboard})
	require("gitlinker").get_buf_range_url("v", {action_callback = require("gitlinker.actions").open_in_browser})
end)

-- add-commit-pull-push
keymap("n", "<leader>g", function()
	local prefill = b.prevCommitMsg or ""

	-- uses dressing + cmp + omnifunc for autocompletion of filenames
	vim.ui.input({prompt = "Commit Message:", default = prefill, completion = "file"}, function(commitMsg)
		if not (commitMsg) then
			return
		elseif #commitMsg > 50 then
			vim.notify("Commit Message too long.\n(Run again for shortened message.)", logWarn)
			b.prevCommitMsg = commitMsg:sub(1, 50)
			return
		elseif commitMsg == "" then
			commitMsg = "patch"
		end

		vim.notify("ﴻ add-commit-push…")
		fn.jobstart("git add -A && git commit -m '" .. commitMsg .. "' ; git pull ; git push", shellOpts)
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
keymap("t", "<Esc>", [[<C-\><C-n>]]) -- normal mode in Terminal window
keymap("t", "ö", [[<C-\><C-n><C-w><C-w>]]) -- switch windows directly from Terminal window
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
				vim.notify("Packer recompiled and " .. fn.expand("%") .. " reloaded.")
			else
				vim.notify(fn.expand("%") .. " reloaded.")
			end
		elseif parentFolder:find("hammerspoon") then
			os.execute [[open -g "hammerspoon://hs-reload"]]
		end

	elseif ft == "yaml" and parentFolder:find("/karabiner") then
		local result = fn.system [[osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"]]
		result = result:gsub("\n$", "")
		vim.notify(result)

	elseif ft == "typescript" then
		cmd [[!npm run build]] -- not via fn.system to get the output in the cmdline

	elseif ft == "applescript" then
		cmd.AppleScriptRun()
		cmd.normal {"<C-w><C-p>", bang = true} -- switch to previous window

	else
		vim.notify("No build system set.", logWarn)

	end
end)

--------------------------------------------------------------------------------
-- INFO as long as an lsp is attached to a buffer (null-ls or regular), `gq`
-- apparently stops working.

--------------------------------------------------------------------------------

-- q / Esc to close special windows
augroup("quickQuit", {})
autocmd("FileType", {
	group = "quickQuit",
	pattern = {
		"help",
		"startuptime",
		"netrw",
		"AppleScriptRunOutput",
		"man",
	},
	callback = function()
		local opts = {buffer = true, silent = true, nowait = true}
		keymap("n", "<Esc>", cmd.close, opts)
		keymap("n", "q", cmd.close, opts)
	end
})
