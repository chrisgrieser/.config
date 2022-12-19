require("config/utils")
local packer = require("packer")
--------------------------------------------------------------------------------

-- META
g.mapleader = ","

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", function()
	local lastCommand = fn.getreg(":")
	fn.setreg("+", lastCommand)
	vim.notify("COPIED\n" .. lastCommand)
end, { desc = "Copy last command" })

-- run [l]ast command [a]gain
keymap("n", "<leader>la", "@:", { desc = "Run last command again" })

-- search keymaps
keymap("n", "?", telescope.keymaps, { desc = "Telescope: Keymaps" })

-- Theme Picker
keymap("n", "<leader>T", telescope.colorscheme, { desc = "Telescope: Colorschemes" })

-- Highlights
keymap("n", "<leader>H", telescope.highlights, { desc = "Telescope: Highlight Groups" })

-- Mason
keymap("n", "<leader>M", cmd.Mason, { desc = ":Mason" })

-- Update [P]lugins
keymap("n", "<leader>p", function()
	cmd.update { bang = true }
	packer.compile()
	if package.loaded["plugin-list"] then
		package.loaded["plugin-list"] = nil -- empty the cache for lua
		packer.startup(require("plugin-list").PluginList)
	end
	packer.snapshot("packer-snapshot_" .. os.date("!%Y-%m-%d_%H-%M-%S"))
	packer.sync()
	cmd.MasonUpdateAll()
	-- remove oldest snapshot when more than 20
	local snapshotPath = fn.stdpath("config") .. "/packer-snapshots"
	os.execute([[cd ']] .. snapshotPath .. [[' ; ls -t | tail -n +20 | tr '\n' '\0' | xargs -0 rm]])
end, { desc = ":PackerSnapshot & :PackerSync" })
keymap("n", "<leader>P", packer.status, { desc = ":PackerStatus" })

-- write all before quitting
keymap("n", "ZZ", ":wall! | qa!<CR>", { desc = "writeall, quitall" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({ "n", "x" }, "H", "0^") -- 0^ ensures fully scrolling to the left on long lines
keymap("o", "H", "^")
keymap({ "n", "x", "o" }, "L", "$")
keymap({ "x", "o" }, "J", "6j")
keymap({ "n", "x", "o" }, "K", "6k")

keymap("n", "k", function()
	cmd.normal { "k", bang = true }
	cmd.nohlsearch()
end, { desc = "k also triggers :nohl" })

keymap("n", "j", function()
	qol.overscroll("j")
	cmd.nohlsearch()
end, { desc = "j (with overscroll) and :nohl" })
keymap("n", "J", function() qol.overscroll("6j") end, { desc = "6j (with overscroll)" })
keymap({ "n", "x" }, "G", "Gzz")

-- Jump History
keymap("n", "<C-h>", "<C-o>", { desc = "Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "Jump forward" })

-- Search
keymap({ "n", "x", "o" }, "-", [[/\v]]) -- German Keyboard, \v for very-magic search
keymap("n", "<Esc>", function()
	local clearPending = require("notify").pending() > 10 and true or false
	require("notify").dismiss { pending = clearPending }
	cmd.nohlsearch() -- clear highlights
	cmd.echo() -- clear shortmessage
end, { desc = "clear highlights and notifications" })

keymap({ "n", "x", "o" }, "+", "*") -- no more modifier key (German Layout)
keymap({ "n", "x", "o" }, "*", "#") -- backwards on the same key (German Layout)

-- MARKS
keymap("", "ä", "`M", { desc = "goto mark M" }) -- Goto Mark M
keymap("", "Ä", function() -- Set Mark M
	cmd.normal { "mM", bang = true }
	vim.notify("Mark M set")
end, { desc = "set mark M" })

-- FOLDING
keymap("n", "^", "za", { desc = "toggle fold" }) -- quicker toggling of folds

-- [M]atch
keymap({ "n", "x", "o" }, "m", "%", { desc = "match parenthesis" })

-- Middle of the Line
keymap({ "n", "x" }, "gm", "gM", { desc = "goto middle of logical line" })

-- Hunks
keymap("n", "gh", ":Gitsigns next_hunk<CR>", { desc = "goto next hunk" })
keymap("n", "gH", ":Gitsigns prev_hunk<CR>", { desc = "goto previous hunk" })

-- quickscope: only highlight when key is pressed
g.qs_highlight_on_keys = { "f", "F", "t", "T" }
g.qs_filetype_blacklist = {}

--------------------------------------------------------------------------------

-- CLIPBOARD
opt.clipboard = "unnamedplus"
keymap("n", "x", '"_x')
keymap("n", "c", '"_c')
keymap("n", "C", '"_C')

require("yanky").setup {
	ring = { history_length = 25 },
	highlight = { timer = 1500 },
}

keymap({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
keymap("n", "P", "<Plug>(YankyCycleForward)")
keymap("n", "gp", qol.pasteDifferently, { desc = "paste differently" }) -- paste charwise reg as linewise & vice versa
keymap("n", "gP", "<Plug>(YankyCycleBackward)")

-- yanking without moving the cursor
-- visual https://stackoverflow.com/a/3806683#comment10788861_3806683
-- normal https://www.reddit.com/r/vim/comments/ekgy47/comment/fddnfl3/
keymap("x", "y", "ygv<Esc>", { desc = "sticky yank" })
augroup("yankKeepCursor", {})
autocmd({ "CursorMoved", "VimEnter" }, {
	group = "yankKeepCursor",
	callback = function() g.cursorPreYankPos = fn.getpos(".") end,
})
autocmd("TextYankPost", {
	group = "yankKeepCursor",
	callback = function()
		if vim.v.event.operator == "y" then fn.setpos(".", g.cursorPreYankPos) end
	end,
})

--------------------------------------------------------------------------------

-- MACROS
local recorder = require("recorder")
recorder.setup {
	slots = { "a", "b" },
	clear = true,
	logLevel = logTrace,
	mapping = {
		startStopRecording = "0",
		playMacro = "9",
		editMacro = "c0",
		switchSlot = "<C-0>",
	},
}

--------------------------------------------------------------------------------

-- Whitespace Control
keymap("n", "!", "a <Esc>h", { desc = "insert space" })
keymap("n", "=", "mzO<Esc>`z", { desc = "add blank above" })
keymap("n", "_", "mzo<Esc>`z", { desc = "add blank below" })

-- Indentation
keymap("n", "<Tab>", ">>", { desc = "indent" })
keymap("n", "<S-Tab>", "<<", { desc = "outdent" })
keymap("x", "<Tab>", ">gv", { desc = "indent" })
keymap("x", "<S-Tab>", "<gv", { desc = "outdent" })

--------------------------------------------------------------------------------
-- EDITING

-- Casing
keymap("n", "ü", "mzlblgueh~`z", { desc = "toggle capital/lowercase of word" })
keymap("n", "Ü", "gUiw", { desc = "uppercase word" })
keymap("n", "~", "~h", { desc = "switch char case w/o moving" })

-- <leader>{char} → Append {char} to end of line
local trailingKeys = { ".", ",", ";", ":", '"', "'" }
for _, v in pairs(trailingKeys) do
	keymap("n", "<leader>" .. v, "mzA" .. v .. "<Esc>`z", { desc = "append " .. v .. " to EoL" })
end

-- Spelling (mnemonic: [z]pe[l]ling)
keymap("n", "zl", telescope.spell_suggest, { desc = "spellsuggest" })
keymap("n", "gl", "]s") -- next misspelling
keymap("n", "gL", "[s") -- prev misspelling
keymap("n", "zf", "mz1z=`z") -- auto[f]ix word under cursor (= select 1st suggestion)

-- [S]ubstitute Operator (substitute.nvim)
local substi = require("substitute")
local exchange = require("substitute.exchange")
substi.setup()
keymap("n", "s", substi.operator, { desc = "substitute operator" })
keymap("n", "ss", substi.line, { desc = "substitute line" })
keymap("n", "S", substi.eol, { desc = "substitute to end of line" })
keymap("n", "sx", exchange.operator, { desc = "exchange operator" })
keymap("n", "sxx", exchange.line, { desc = "exchange line" })

-- ISwap
keymap("n", "X", cmd.ISwapWith, { desc = "swap nodes" })

-- search & replace
keymap("n", "<leader>f", [[:%sm/<C-r>=expand("<cword>")<CR>//g<Left><Left>]], { desc = "search & replace" })
keymap("x", "<leader>f", ":sm///g<Left><Left><Left>", { desc = "search & replace" })
keymap({ "n", "x" }, "<leader>F", function() require("ssr").open() end, { desc = "structural search & replace" }) -- wrapped in function for lazy-loading
keymap({"n", "x"}, "<leader>n", ":normal ", {desc = ":normal"})


-- Duplicate Line / Selection (mnemonic: [r]eplicate)
keymap("n", "R", qol.duplicateLine, { desc = "duplicate line" })
keymap(
	"n",
	"<A-r>",
	function() qol.duplicateLine { increment = true } end,
	{ desc = "duplicate line, incrementing numbers" }
)
keymap("x", "R", qol.duplicateSelection, { desc = "duplicate selection" })

-- Undo
keymap({ "n", "x" }, "U", "<C-r>", { desc = "redo" }) -- redo
keymap("n", "<C-u>", qol.undoDuration, { desc = "undo specific durations" })
keymap("n", "<leader>u", function() require("telescope-undo")() end, { desc = "Telescope Undotree" })
keymap("i", "<Space>", "<Space><C-g>u", { desc = "add blank below" })

-- Logging & Debugging
keymap({ "n", "x" }, "<leader>ll", qol.quicklog, { desc = "add log statement" })
keymap("n", "<leader>lr", qol.removeLog, { desc = "remove all log statements" })

-- Sort & highlight duplicate lines
keymap({ "n", "x" }, "<leader>S", [[:sort<CR>:g/^\(.*\)$\n\1$/<CR><CR>]], { desc = "sort & highlight duplicates" }) -- second <CR> due to cmdheight=0

-- sane-gx
keymap("n", "gx", qol.bettergx, { desc = "open next URL" })

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
keymap({ "n", "x" }, "M", "J", { desc = "merge line up" })
keymap({ "n", "x" }, "<leader>m", "ddpkJ", { desc = "merge line down" })
keymap("n", "|", "a<CR><Esc>k$", { desc = "split line at cursor" })

-- TreeSJ plugin + Splitjoin-Fallback
keymap("n", "<leader>s", cmd.TSJToggle, { desc = "split/join" })

require("treesj").setup { use_default_keymaps = false }
augroup("splitjoinFallback", {}) -- HACK: https://github.com/Wansmer/treesj/discussions/19
autocmd("FileType", {
	pattern = "*",
	group = "splitjoinFallback",
	callback = function()
		local langs = require("treesj.langs")["presets"]
		if not langs[bo.filetype] then
			keymap("n", "<leader>s", ":SplitjoinSplit<CR>", { buffer = true, desc = "split/join" })
		end
	end,
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
keymap("n", "ö", "<C-w>w", { desc = "switch to next window" })
keymap("n", "Ö", "<C-w>o", { desc = "close other windows" })

--------------------------------------------------------------------------------

-- CMD-Keybindings
if isGui() then
	keymap({ "n", "x", "i" }, "<D-w>", qol.betterClose, { desc = "close buffer/window/tab" }) -- cmd+w

	keymap({ "n", "x", "i" }, "<D-s>", cmd.write, { desc = "save" }) -- cmd+s, will be overridden on lsp attach
	keymap("n", "<D-a>", "ggVG", { desc = "select all" }) -- cmd+a
	keymap("i", "<D-a>", "<Esc>ggVG", { desc = "select all" })
	keymap("x", "<D-a>", "ggG", { desc = "select all" })

	keymap({ "n", "x" }, "<D-l>", function() -- show file in default GUI file explorer
		fn.system("open -R '" .. fn.expand("%:p") .. "'")
	end, { desc = "open in file explorer" })
	keymap({ "n", "x", "i" }, "<D-1>", cmd.Lex) -- file tree (netrw)
	keymap("n", "<D-0>", ":messages<CR>", { desc = ":messages" }) -- as cmd.function these wouldn't require confirmation
	keymap("n", "<D-9>", ":Notification<CR>", { desc = ":Notifications" })

	-- Multi-Cursor https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
	g.VM_maps = { -- cmd+j
		["Find Under"] = "<D-j>",
		["Visual Add"] = "<D-j>",
	}

	-- cut, copy & paste
	keymap({ "n", "x" }, "<D-v>", "<Esc>p", { desc = "paste" }) -- needed for pasting from Alfred clipboard history
	keymap("c", "<D-v>", "<C-r>+", { desc = "paste" })
	keymap("i", "<D-v>", "<C-r><C-o>+", { desc = "paste" })

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
-- cycle between buffers
keymap("n", "<BS>", [[:nohl<CR><Plug>(CybuNext)]], { desc = "cycle buffers" })

-- Buffer selector
keymap("n", "gb", function()
	local moreThanOneBuf = #(fn.getbufinfo { buflisted = 1 }) > 1
	if moreThanOneBuf then
		cmd.nohlsearch()
		telescope.buffers()
	else
		vim.notify("Only one buffer open.")
	end
end, { desc = "select an open buffer" })

-- HACK: fix for https://github.com/cshuaimin/ssr.nvim/issues/11
augroup("ssr-fix", {})
autocmd("BufReadPost", {
	group = "ssr-fix",
	callback = function()
		if bo.filetype == "ssr" then return end
		keymap("n", "<CR>", function()
			if fn.expand("#") == "" then
				vim.notify("No alternate file.", logWarn)
			else
				cmd.nohlsearch()
				cmd.buffer("#")
			end
		end, { desc = "switch to alt file" })
	end,
})

--------------------------------------------------------------------------------
-- FILES

-- File Switchers
keymap("n", "go", telescope.find_files) -- [o]pen file in parent-directory
keymap("n", "gO", telescope.git_files) -- [o]pen file in git directory
keymap("n", "gr", telescope.oldfiles) -- [r]ecent files
keymap("n", "gF", telescope.live_grep) -- search in [f]iles
keymap("n", "gR", telescope.resume) -- [R]esume last search

-- File Operations (no shorthand for lazy-loading)
keymap("n", "<C-p>", function() require("genghis").copyFilepath() end, {desc = "copy filepath"})
keymap("n", "<C-n>", function() require("genghis").copyFilename() end, {desc = "copy filename"})
keymap("n", "<leader>x", function() require("genghis").chmodx() end, {desc = "chmod +x"})
keymap("n", "<C-r>", function() require("genghis").renameFile() end, {desc = "rename file"})
keymap("n", "<C-m>", function() require("genghis").moveAndRenameFile() end, {desc = "move & rename file"})
keymap("n", "<C-d>", function() require("genghis").duplicateFile() end, {desc = "duplicate file"})
keymap("", "<D-BS>", function() require("genghis").trashFile() end, {desc = "move file to trash"})
keymap("", "<D-n>", function() require("genghis").createNewFile() end, {desc = "create new file"})
keymap("x", "X", function() require("genghis").moveSelectionToNewFile() end, {desc = "move selection to new file"})

--------------------------------------------------------------------------------
-- GIT

-- Diffview
keymap("n", "<D-g>", function()
	vim.ui.input({ prompt = "Git Pickaxe (empty = full history)" }, function(query)
		if not query then
			return
		elseif query == "" then
			cmd("DiffviewFileHistory %")
		else
			cmd("DiffviewFileHistory % -G" .. query)
		end
	end)
end)

-- GitLinker: Copy & Open in Browser
keymap("n", "<leader>G", function()
	require("gitlinker").get_buf_range_url("n", { action_callback = require("gitlinker.actions").copy_to_clipboard })
	require("gitlinker").get_buf_range_url("n", { action_callback = require("gitlinker.actions").open_in_browser })
end)

keymap("v", "<leader>G", function() -- this seems to not work with xmap, requires vmap
	require("gitlinker").get_buf_range_url("v", { action_callback = require("gitlinker.actions").copy_to_clipboard })
	require("gitlinker").get_buf_range_url("v", { action_callback = require("gitlinker.actions").open_in_browser })
end)

-- add-commit-pull-push
keymap("n", "<leader>g", function()
	local prefill = b.prevCommitMsg or ""

	-- uses dressing + cmp + omnifunc for autocompletion of filenames
	vim.ui.input({ prompt = "Commit Message", default = prefill, completion = "file" }, function(commitMsg)
		if not commitMsg then
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
		if parentFolder:find("nvim/lua") then
			cmd.write()
			cmd.source("%")
			if filename:find("plugin%-list") then
				packer.compile()
				vim.notify("Packer recompiled and " .. fn.expand("%") .. " reloaded.")
			else
				vim.notify(fn.expand("%") .. " reloaded.")
			end
		elseif parentFolder:find("hammerspoon") then
			os.execute([[open -g "hammerspoon://hs-reload"]])
		end
	elseif ft == "yaml" and parentFolder:find("/karabiner") then
		local result = fn.system([[osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"]])
		result = result:gsub("\n$", "")
		vim.notify(result)
	elseif ft == "typescript" then
		cmd([[!npm run build]]) -- not via fn.system to get the output in the cmdline
	elseif ft == "applescript" then
		cmd.AppleScriptRun()
		cmd.normal { "<C-w><C-p>", bang = true } -- switch to previous window
	else
		vim.notify("No build system set.", "warn")
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
		local opts = { buffer = true, silent = true, nowait = true }
		keymap("n", "<Esc>", cmd.close, opts)
		keymap("n", "q", cmd.close, opts)
	end,
})

--------------------------------------------------------------------------------
