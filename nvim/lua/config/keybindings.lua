require("config.utils")
--------------------------------------------------------------------------------
-- META

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

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", function()
	local lastCommand = fn.getreg(":")
	fn.setreg("+", lastCommand)
	vim.notify("COPIED\n" .. lastCommand)
end, { desc = "Copy last command" })

-- run [l]ast command [a]gain
keymap("n", "<leader>la", "@:", { desc = "Run last command again" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({ "n", "x" }, "H", "0^") -- 0^ ensures fully scrolling to the left on long lines
keymap("o", "H", "^")

keymap({ "n", "x", "o" }, "L", "$")

keymap("n", "J", function() qol.overscroll("6j") end, { desc = "6j (with overscroll)" })
keymap("x", "J", "6j")
keymap("o", "J", "2j") -- dj = delete 2 lines, dJ = delete 3 lines

keymap({ "n", "x" }, "K", "6k")
keymap("o", "K", "2k")

-- add overscroll
keymap("n", "j", function() qol.overscroll("j") end, { desc = "j (with overscroll)" })
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
keymap("n", "^", function()
	normal("za")
	cmd.SatelliteRefresh() -- https://github.com/lewis6991/satellite.nvim/blob/main/doc/satellite.txt#L113
end, { desc = "toggle fold" })

-- [M]atchUp
g.matchup_text_obj_enabled = 0
g.matchup_matchparen_enabled = 1 -- highlight
keymap({ "n", "x", "o" }, "m", "<Plug>(matchup-%)", { desc = "matchup" })

-- Middle of the Line
keymap({ "n", "x" }, "gm", "gM", { desc = "goto middle of logical line" })

-- Hunks & changes
keymap("n", "gh", ":Gitsigns next_hunk<CR>", { desc = "goto next hunk" })
keymap("n", "gH", ":Gitsigns prev_hunk<CR>", { desc = "goto previous hunk" })
keymap("n", "gc", "g;", { desc = "goto next change" })
keymap("n", "gC", "g,", { desc = "goto previous change" })

-- Leap
keymap("n", "ö", "<Plug>(leap-forward-to)", { desc = "Leap forward" })
keymap("n", "Ö", "<Plug>(leap-backward-to)", { desc = "Leap backward" })

--------------------------------------------------------------------------------

-- CLIPBOARD
opt.clipboard = "unnamedplus"

-- don't pollute the register
keymap("n", "x", '"_x')
keymap("n", "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P", { desc = "paste without switcing register" })

-- yanking without moving the cursor
augroup("yankImprovements", {})
autocmd({ "CursorMoved", "VimEnter" }, {
	group = "yankImprovements",
	callback = function() g.cursorPreYank = getCursor(0) end,
})

-- - yanking without moving the cursor
-- - highlighted yank
-- - saves yanks in numbered register, so `"1p` pastes previous yanks.
autocmd("TextYankPost", {
	group = "yankImprovements",
	callback = function()
		vim.highlight.on_yank { timeout = 1500 } -- highlighted yank
		if vim.v.event.operator ~= "y" then return end
		setCursor(0, g.cursorPreYank) -- sticky yank
		-- fn.setpos(".", g.cursorPreYankPos)

		-- add yanks to numbered registers
		if vim.v.event.regname ~= "" then return end
		for i = 8, 1, -1 do
			local regcontent = fn.getreg(tostring(i))
			fn.setreg(tostring(i + 1), regcontent)
		end
		if g.lastYank then fn.setreg("1", g.lastYank) end
		g.lastYank = fn.getreg('"')
	end,
})

-- cycle through the last deletes/yanks
g.killringCount = 0
keymap("n", "P", function()
	cmd.undo()
	g.killringCount = g.killringCount + 1
	if g.killringCount > 9 then g.killringCount = 0 end
	normal('"' .. tostring(g.killringCount) .. "p")
end, { desc = "simply killring" })

keymap("n", "p", function()
	g.killringCount = 0
	normal("p")
end, { desc = "paste & reset killring" })

-- paste charwise reg as linewise & vice versa
keymap("n", "gp", function()
	local reg = "+"
	local isLinewise = fn.getregtype(reg) == "V"
	local targetRegType = isLinewise and "v" or "V"
	local regContent = fn.getreg(reg):gsub("\n$", "")
	fn.setreg(reg, regContent, targetRegType) ---@diagnostic disable-line: param-type-mismatch
	normal('"' .. reg .. "p") -- for whatever reason, `p` along does not work here
	if targetRegType == "V" then normal("==") end
end, { desc = "paste differently" })

--------------------------------------------------------------------------------

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

-- Append to / delete from EoL
local trailingKeys = { ".", ",", ";", ":", '"', "'" }
for _, v in pairs(trailingKeys) do
	keymap("n", "<leader>" .. v, "mzA" .. v .. "<Esc>`z", { desc = "append " .. v .. " to EoL" })
end
keymap("n", "X", "mz$x`z", { desc = "delete last character" })

-- Spelling (mnemonic: [z]pe[l]ling)
keymap("n", "zl", telescope.spell_suggest, { desc = "spellsuggest" })
keymap("n", "zg", "zg<CR>", { desc = "mark as correct spelling" }) -- needs extra enter due to `cmdheight=0`
keymap("n", "gz", "]s", { desc = "next misspelling" })
keymap("n", "za", "mz1z=`z", { desc = "autofix spelling" }) -- [a]utofix word under cursor

-- [S]ubstitute Operator (substitute.nvim)
keymap("n", "s", function() require("substitute").operator() end, { desc = "substitute operator" })
keymap("n", "ss", function()
	require("substitute").line()
	normal("==")
end, { desc = "substitute line" })
keymap("n", "S", function() require("substitute").eol() end, { desc = "substitute to end of line" })
keymap("n", "sx", function() require("substitute.exchange").operator() end, { desc = "exchange op" })
keymap("n", "sxx", function() require("substitute.exchange").line() end, { desc = "exchange line" })

-- ISwap
keymap("n", "<leader>e", cmd.ISwapWith, { desc = "exchange nodes" })

-- search & replace
keymap("n", "<leader>f", [[:%s/<C-r>=expand("<cword>")<CR>//g<Left><Left>]], { desc = "search & replace" })
keymap("x", "<leader>f", ":s///g<Left><Left><Left>", { desc = "search & replace" })
keymap({ "n", "x" }, "<leader>F", function() require("ssr").open() end, { desc = "struct. search & replace" })
keymap("n", "<leader>n", ":%normal ", { desc = ":normal" })
keymap("x", "<leader>n", ":normal ", { desc = ":normal" })
keymap("n", "<A-r>", "R", { desc = "replace mode" })

-- Duplicate Line / Selection (mnemonic: [r]eplicate)
keymap("n", "R", qol.duplicateLine, { desc = "duplicate line" })
keymap("x", "R", qol.duplicateSelection, { desc = "duplicate selection" })

-- Undo
keymap({ "n", "x" }, "U", "<C-r>", { desc = "redo" }) -- redo
keymap("n", "<C-u>", qol.undoDuration, { desc = "undo specific durations" })
-- stylua: ignore
keymap( "n", "<leader>u", function() require("telescope").extensions.undo.undo() end, { desc = "Telescope Undotree" })

-- Logging & Debugging
keymap({ "n", "x" }, "<leader>ll", qol.quicklog, { desc = "add log statement" })
keymap({ "n", "x" }, "<leader>lb", qol.beeplog, { desc = "add beep log" })
keymap({ "n", "x" }, "<leader>lt", qol.timelog, { desc = "log time" })
keymap({ "n", "x" }, "<leader>lr", qol.removelogs, { desc = "remove all log statements" })

-- Sort & highlight duplicate lines
-- stylua: ignore
keymap( { "n", "x" }, "<leader>S", [[:sort<CR>:g/^\(.*\)$\n\1$/<CR><CR>]], { desc = "sort & highlight duplicates" })

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
keymap("x", "|", "<Esc>`>a<CR><Esc>`<i<CR><Esc>", { desc = "split around selection" })

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

-- autopairs for command mode
keymap("c", "(", "()<Left>")
keymap("c", "[", "[]<Left>")
keymap("c", "{", "{}<Left>")
keymap("c", "'", "''<Left>")
keymap("c", '"', '""<Left>')

--------------------------------------------------------------------------------
-- VISUAL MODE
keymap("x", "V", "j") -- repeatedly pressing "V" selects more lines (indented for Visual Line Mode)
keymap("x", "v", "<C-v>") -- `vv` from normal mode = visual block mode

--------------------------------------------------------------------------------
-- WINDOWS & SPLITS
keymap("n", "<C-w>v", ":vsplit #<CR>", { desc = "vertical split (alt file)" }) -- open the alternate file in the split instead of the current file
keymap("n", "<C-w>h", ":split #<CR>", { desc = "horizontal split (alt file)" })
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
	keymap({ "n", "x", "i" }, "<D-w>", qol.betterClose, { desc = "close buffer/window/tab" })

	keymap({ "n", "x", "i" }, "<D-s>", cmd.write, { desc = "save" }) -- cmd+s, will be overridden on lsp attach
	keymap("n", "<D-a>", "ggVG", { desc = "select all" }) -- cmd+a
	keymap("i", "<D-a>", "<Esc>ggVG", { desc = "select all" })
	keymap("x", "<D-a>", "ggG", { desc = "select all" })
	keymap("x", "<D-c>", "y", { desc = "copy selection" }) -- cmd+c, habit sometimes

	keymap({ "n", "x" }, "<D-l>", function() -- show file in default GUI file explorer
		fn.system("open -R '" .. expand("%:p") .. "'")
	end, { desc = "open in file explorer" })

	keymap("n", "<D-0>", ":10messages<CR>", { desc = ":messages (last 10)" }) -- as cmd.function these wouldn't require confirmation
	keymap("n", "<D-9>", ":Notification<CR>", { desc = ":Notifications" })

	-- Multi-Cursor https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
	g.VM_maps = {
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

-- Color Picker
keymap("n", "#", ":CccPick<CR>")
keymap("n", "'", ":CccConvert<CR>") -- shift-# on German keyboard
keymap("i", "<C-#>", "<Plug>(ccc-insert)")

-- Neural
keymap("x", "ga", ":NeuralCode complete<CR>", { desc = "AI: Code Complete" })

-- ChatGPT
keymap("n", "ga", ":ChatGPT<CR>", { desc = "AI: ChatGPT Prompt" })

--------------------------------------------------------------------------------
-- BUFFERS
-- INFO: <BS> to cycle buffer has to be set in cybu config

keymap("n", "gb", telescope.buffers, { desc = "select an open buffer" })

keymap("n", "<CR>", function()
	if expand("#") == "" then
		local lastOldfile = vim.v.oldfiles[2]
		cmd.edit(lastOldfile)
	else
		cmd.nohlsearch()
		cmd.buffer("#")
	end
end, { desc = "switch to alt file" })
--------------------------------------------------------------------------------
-- FILES

-- File Switchers
keymap("n", "go", telescope.find_files, { desc = "Telescope: Files in cwd" })
keymap("n", "gO", telescope.git_files, { desc = "Telescope: Git Files" })
keymap("n", "gr", telescope.oldfiles, { desc = "Telescope: [R]ecent Files" })
keymap("n", "gF", telescope.live_grep, { desc = "Telescope: Search in cwd" })

-- File Operations
keymap("n", "<C-p>", function() require("genghis").copyFilepath() end, { desc = "copy filepath" })
keymap("n", "<C-n>", function() require("genghis").copyFilename() end, { desc = "copy filename" })
keymap("n", "<leader>x", function() require("genghis").chmodx() end, { desc = "chmod +x" })
keymap("n", "<C-r>", function() require("genghis").renameFile() end, { desc = "rename file" })
keymap("n", "<D-S-m>", function() require("genghis").moveAndRenameFile() end, { desc = "move-rename file" })
keymap("n", "<C-d>", function() require("genghis").duplicateFile() end, { desc = "duplicate file" })
keymap("n", "<D-BS>", function() require("genghis").trashFile() end, { desc = "move file to trash" })
keymap("n", "<D-n>", function() require("genghis").createNewFile() end, { desc = "create new file" })
-- stylua: ignore
keymap( "x", "X", function() require("genghis").moveSelectionToNewFile() end, { desc = "selection to new file" })

--------------------------------------------------------------------------------
-- GIT

-- Neo[G]it
keymap("n", "<leader>G", ":Neogit<CR>")

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
		cmd.execute([["normal! \<C-W>w"]]) -- go directly to file window
	end)
end)

-- Git-link
keymap({ "n", "x" }, "<C-g>", qol.gitLink, { desc = "git link" })

-- add-commit-pull-push
keymap("n", "<leader>g", qol.addCommitPush, { desc = "git add-commit-pull-push" })

--------------------------------------------------------------------------------

-- Option Toggling
keymap("n", "<leader>os", ":set spell!<CR>")
keymap("n", "<leader>or", ":set relativenumber!<CR>")
keymap("n", "<leader>on", ":set number!<CR>")
keymap("n", "<leader>ow", qol.toggleWrap, { desc = "toggle wrap" })
keymap("n", "<leader>od", function()
	g.diagnosticOn = g.diagnosticOn or true
	if g.diagnosticOn then
		vim.diagnostic.disable(0)
	else
		vim.diagnostic.enable(0)
	end
	g.diagnosticOn = not g.diagnosticOn
end, { desc = "toggle diagnostics" })

--------------------------------------------------------------------------------

-- TERMINAL AND CODI
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = "Esc" }) -- normal mode in Terminal window
keymap("n", "6", ":ToggleTerm size=8<CR>", { desc = "ToggleTerm" })
keymap("x", "6", ":ToggleTermSendVisualSelection size=8<CR>", { desc = "Selection to ToggleTerm" })

keymap("n", "5", function()
	cmd.CodiNew()
	cmd.file("Codi: " .. bo.filetype) -- HACK to set buffername, since Codi does not provide a filename for its buffer
end, { desc = ":CodiNew" })

--------------------------------------------------------------------------------

-- BUILD SYSTEM & QUICKFIX LIST
keymap("n", "gq", cmd.cnext, { desc = "next quickfix item" })
keymap("n", "gQ", function() cmd.Telescope("quickfix") end, { desc = "Telescope: quickfix list" })

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
		local result =
			fn.system([[osascript -l JavaScript "$HOME/.config/karabiner/build-karabiner-config.js"]])
		result = result:gsub("\n$", "")
		vim.notify(result)

	-- Typescript
	elseif ft == "typescript" then
		cmd.redir("@z")
		cmd.make() -- defined via makeprg
		local output = fn.getreg("z")
		local logLevel = output:find("error") and logError or logTrace
		vim.notify(output, logLevel)
		cmd.redir("END")

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

-- q / Esc to close special windows
local opts = { buffer = true, nowait = true, remap = true }
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
		"lazy",
		"notify",
		"AppleScriptRunOutput",
		"man",
	},
	callback = function()
		keymap("n", "<Esc>", cmd.close, opts)
		keymap("n", "q", cmd.close, opts)
	end,
})

-- HACK to remove the waiting time from the q, due to conflict with `qq`
-- for comments
autocmd("FileType", {
	group = "quickQuit",
	pattern = "TelescopePrompt",
	callback = function() keymap("n", "q", "<Esc>", opts) end,
})
autocmd("FileType", {
	group = "quickQuit",
	pattern = "ssr",
	callback = function() keymap("n", "q", "Q", opts) end,
})

--------------------------------------------------------------------------------
-- Remaps for the refactoring operations currently offered by the plugin

keymap("n", "zi", function () require('refactoring').refactor('Inline Variable') end, {desc = "Refactor: Inline Variable"})
keymap("x", "zv", function () require('refactoring').refactor('Extract Variable') end, {desc = "Refactor: Extract Variable"})
keymap("x", "zb", function () require('refactoring').refactor('Extract Block') end, {desc = "Refactor: Extract Block"})
keymap("x", "zf", function () require('refactoring').refactor('Extract Function') end, {desc = "Refactor: Extract Function"})

--------------------------------------------------------------------------------

local bar = "aaaaa"
local function foo()
	print(bar)
	print(bar .. "aa")
end

print("bar" .. "aa")
print("bar" .. "aa")
print("bar" .. "aa")
