require("config/utils")
--------------------------------------------------------------------------------
-- META

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
	require("lazy").sync()
	cmd.MasonUpdateAll()
end, { desc = ":Lazy sync & :MasonUpdateAll" })
keymap("n", "<leader>P", require("lazy").install, { desc = ":Lazy install" })

-- write all before quitting
keymap("n", "ZZ", ":wall! | qa!<CR>", { desc = ":wall & :quitall" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({ "n", "x" }, "H", "0^") -- 0^ ensures fully scrolling to the left on long lines
keymap("o", "H", "^")
keymap({ "n", "x", "o" }, "L", "$")
keymap({ "x", "o" }, "J", "6j")
keymap({ "n", "x", "o" }, "K", "6k")

keymap("n", "j", function() qol.overscroll("j") end, { desc = "j (with overscroll)" })
keymap("n", "J", function() qol.overscroll("6j") end, { desc = "6j (with overscroll)" })
keymap({ "n", "x" }, "G", "Gzz")

-- Jump History
keymap("n", "<C-h>", "<C-o>", { desc = "Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "Jump forward" })

-- Search
keymap({ "n", "x", "o" }, "-", "/", { desc = "Search (German Keyboard)" })
keymap("n", "<Esc>", function()
	cmd.nohlsearch()
	cmd.echo() -- clear shortmessage
	require("lualine").refresh() -- so the highlight count disappears quicker
	if isGui() then 
		local clearPending = require("notify").pending() > 10
		require("notify").dismiss { pending = clearPending }
	end
end, { desc = "clear highlights and notifications" })

keymap("n", "+", "*", { desc = "search word under cursor (German keyboard)" })
keymap("x", "+", [["zy/\V<C-R>=getreg("@z")<CR><CR>]], { desc = "visual star (I use `+` though)" })

-- FOLDING
keymap("n", "^", "za", { desc = "toggle fold" }) -- quicker toggling of folds

-- [M]atch
keymap({ "n", "x", "o" }, "m", "%", { desc = "match parenthesis" })

-- Middle of the Line
keymap({ "n", "x" }, "gm", "gM", { desc = "goto middle of logical line" })

-- Hunks
keymap("n", "gh", ":Gitsigns next_hunk<CR>", { desc = "goto next hunk" })
keymap("n", "gH", ":Gitsigns prev_hunk<CR>", { desc = "goto previous hunk" })

-- Leap & Flit
keymap("n", "ö", "<Plug>(leap-forward-to)", { desc = "Leap forward" })
keymap("n", "Ö", "<Plug>(leap-backward-to)", { desc = "Leap backward" })
require("flit").setup { multiline = false }

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

keymap("n", "p", "<Plug>(YankyPutAfter)")
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
keymap("n", "zg", "zg<CR>") -- needs extra enter due to `cmdheight=0`
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
keymap("n", "<leader>f", [[:%s/<C-r>=expand("<cword>")<CR>//g<Left><Left>]], { desc = "search & replace" })
keymap("x", "<leader>f", ":s///g<Left><Left><Left>", { desc = "search & replace" })
keymap({ "n", "x" }, "<leader>F", function() require("ssr").open() end, { desc = "structural search & replace" }) -- wrapped in function for lazy-loading
keymap("n", "<leader>n", ":%normal ", { desc = ":normal" })
keymap("x", "<leader>n", ":normal ", { desc = ":normal" })

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
keymap("n", "<leader>u", function() require("telescope").extensions.undo.undo() end, { desc = "Telescope Undotree" })

-- Logging & Debugging
keymap({ "n", "x" }, "<leader>ll", qol.quicklog, { desc = "add log statement" })
keymap({ "n", "x" }, "<leader>lb", qol.beeplog, { desc = "add beep log" })
keymap("n", "<leader>lr", qol.removeLog, { desc = "remove all log statements" })

-- Sort & highlight duplicate lines
keymap({ "n", "x" }, "<leader>S", [[:sort<CR>:g/^\(.*\)$\n\1$/<CR><CR>]], { desc = "sort & highlight duplicates" }) -- second <CR> due to cmdheight=0

-- URL Opening
keymap("n", "gx", qol.bettergx, { desc = "open next URL" })
keymap("n", "gX", function() cmd.UrlView("buffer") end, { desc = "select URL to open" })

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

-- TreeSJ plugin
keymap("n", "<leader>s", cmd.TSJToggle, { desc = "split/join" })

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
keymap("x", "p", "P", {desc = "paste without switcing register"})

--------------------------------------------------------------------------------
-- WINDOWS & SPLITS
keymap("", "<C-w>v", ":vsplit #<CR>", { desc = "vertical split (alt file)" }) -- open the alternate file in the split instead of the current file
keymap("", "<C-w>h", ":split #<CR>", { desc = "horizontal split (alt file)" })
keymap("", "<C-Right>", ":vertical resize +3<CR>", { desc = "vertical resize" }) -- resizing on one key for sanity
keymap("", "<C-Left>", ":vertical resize -3<CR>", { desc = "vertical resize" })
keymap("", "<C-Down>", ":resize +3<CR>", { desc = "horizontal resize" })
keymap("", "<C-Up>", ":resize -3<CR>", { desc = "horizontal resize" })

keymap("n", "ä", "<C-w>w", { desc = "switch to next window" })
keymap("n", "Ä", "<C-w>p", { desc = "switch to previous window" })
keymap("t", "ä", [[<C-\><C-n><C-w>p]], { desc = "switch to previous window" })

--------------------------------------------------------------------------------

-- CMD-Keybindings
if isGui() then
	keymap({ "n", "x", "i" }, "<D-w>", qol.betterClose, { desc = "close buffer/window/tab" }) -- cmd+w

	keymap({ "n", "x", "i" }, "<D-s>", cmd.write, { desc = "save" }) -- cmd+s, will be overridden on lsp attach
	keymap("n", "<D-a>", "ggVG", { desc = "select all" }) -- cmd+a
	keymap("i", "<D-a>", "<Esc>ggVG", { desc = "select all" })
	keymap("x", "<D-a>", "ggG", { desc = "select all" })
	keymap("x", "<D-c>", "y", { desc = "copy selection" }) -- cmd+c, habit sometimes

	keymap({ "n", "x" }, "<D-l>", function() -- show file in default GUI file explorer
		fn.system("open -R '" .. expand("%:p") .. "'")
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
	keymap({ "n", "x" }, "<D-v>", "p", { desc = "paste" }) -- needed for pasting from Alfred clipboard history
	keymap("c", "<D-v>", "<C-r>+", { desc = "paste" })
	keymap("i", "<D-v>", "<C-r><C-o>+", { desc = "paste" })

	-- cmd+e: inline code
	keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = "Inline Code Markup" }) -- no selection = word under cursor
	keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = "Inline Code Markup" })
	keymap("i", "<D-e>", "``<Left>", { desc = "Inline Code Markup" })

	-- cmd+t: template string
	keymap("n", "<D-t>", "bi${<Esc>ea}<Esc>b", { desc = "Template String Markup" }) -- no selection = word under cursor
	keymap("x", "<D-t>", "<Esc>${<i}<Esc>${>la}<Esc>b", { desc = "Template String Markup" })
	keymap("i", "<D-t>", "${}<Left>", { desc = "Template String Markup" })
end

--------------------------------------------------------------------------------
-- BUFFERS
-- INFO: <BS> cycle between buffers (cybu) has to be defined in plugin-list for
-- lazy loading
keymap("n", "<BS>", ":nohl<CR><Plug>(CybuNext)", { desc = "cycle buffers" })

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
			if expand("#") == "" then
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
keymap("n", "go", telescope.find_files, { desc = "Telescope: Files in cwd" })
keymap("n", "gO", telescope.git_files, { desc = "Telescope: Git Files" })
keymap("n", "gr", telescope.oldfiles, { desc = "Telescope: Recent Files" })
keymap("n", "gF", telescope.live_grep, { desc = "Telescope: Search in cwd" })
keymap("n", "gc", telescope.resume, { desc = "Telescope: Resume" })

-- File Operations (no shorthand for lazy-loading)
keymap("n", "<C-p>", function() require("genghis").copyFilepath() end, { desc = "copy filepath" })
keymap("n", "<C-n>", function() require("genghis").copyFilename() end, { desc = "copy filename" })
keymap("n", "<leader>x", function() require("genghis").chmodx() end, { desc = "chmod +x" })
keymap("n", "<C-r>", function() require("genghis").renameFile() end, { desc = "rename file" })
keymap("n", "<C-m>", function() require("genghis").moveAndRenameFile() end, { desc = "move & rename file" })
keymap("n", "<C-d>", function() require("genghis").duplicateFile() end, { desc = "duplicate file" })
keymap("", "<D-BS>", function() require("genghis").trashFile() end, { desc = "move file to trash" })
keymap("", "<D-n>", function() require("genghis").createNewFile() end, { desc = "create new file" })
keymap("x", "X", function() require("genghis").moveSelectionToNewFile() end, { desc = "move selection to new file" })

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

-- TERMINAL AND CODI
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = "Esc" }) -- normal mode in Terminal window
keymap("n", "6", ":ToggleTerm size=8<CR>", { desc = "ToggleTerm" })
keymap("x", "6", ":ToggleTermSendVisualSelection size=8<CR>", { desc = "Send Selection to ToggleTerm" })

keymap("n", "5", function()
	local ft = bo.filetype
	cmd.CodiNew()
	cmd.file("Codi: " .. ft) -- workaround, since Codi does not provide a filename for its buffer
end, { desc = ":CodiNew" })

--------------------------------------------------------------------------------

-- BUILD SYSTEM
keymap("n", "<leader>r", function()
	cmd.update()
	local filename = expand("%:t")
	local parentFolder = expand("%:p:h")
	local ft = bo.filetype

	if filename == "sketchybarrc" then
		fn.system("brew services restart sketchybar")
	elseif ft == "markdown" then
		local filepath = expand("%:p")
		local pdfFilename = expand("%:t:r") .. ".pdf"
		fn.system("pandoc '" .. filepath .. "' --output='" .. pdfFilename .. "' --pdf-engine=wkhtmltopdf")
		fn.system("open '" .. pdfFilename .. "'")

	-- nvim config
	elseif ft == "lua" and parentFolder:find("nvim") then
		cmd.source()
		vim.notify(expand("%:r") .. " re-sourced")

	-- Hammerspoon
	elseif ft == "lua" and parentFolder:find("hammerspoon") then
		os.execute([[open -g "hammerspoon://hs-reload"]])

	-- Karabiner
	elseif ft == "yaml" and parentFolder:find("/karabiner") then
		local result = fn.system([[osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"]])
		result = result:gsub("\n$", "")
		vim.notify(result)

	-- Typescript
	elseif ft == "typescript" then
		cmd([[!npm run build]]) -- not via fn.system to get the output in the cmdline

	-- AppleScript
	elseif ft == "applescript" then
		cmd.AppleScriptRun()
		normal("<C-w><C-p>") -- switch to previous window

	-- None
	else
		vim.notify("No build system set.", logWarn)
	end
end)

--------------------------------------------------------------------------------
-- BUG as long as an lsp is attached to a buffer (null-ls or regular), `gq`
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
		"lspinfo",
		"tsplayground",
		"qf",
		"notify",
		"AppleScriptRunOutput",
		"man",
	},
	callback = function()
		local opts = { buffer = true, nowait = true }
		keymap("n", "<Esc>", cmd.close, opts)
		keymap("n", "q", cmd.close, opts)
	end,
})

-- HACK to remove the waiting time from the q, due to conflict with `qq`
-- for comments
autocmd("FileType", {
	group = "quickQuit",
	pattern = "TelescopePrompt",
	callback = function() keymap("n", "q", "<Esc>", { buffer = true, nowait = true, remap = true }) end,
})
autocmd("FileType", {
	group = "quickQuit",
	pattern = "ssr",
	callback = function() keymap("n", "q", "Q", { buffer = true, nowait = true, remap = true }) end,
})

--------------------------------------------------------------------------------
