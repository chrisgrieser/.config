require("config.utils")
--------------------------------------------------------------------------------
-- META

-- search keymaps
keymap("n", "?", telescope.keymaps, { desc = "Telescope: Keymaps" })

-- Theme Picker
keymap("n", "<leader>T", telescope.colorscheme, { desc = "Telescope: Colorschemes" })

-- Highlights
keymap("n", "<leader>H", telescope.highlights, { desc = "Telescope: Highlight Groups" })

-- Update [P]lugins
keymap("n", "<leader>p", require("lazy").sync, { desc = ":Lazy sync" })
keymap("n", "<leader>P", require("lazy").home, { desc = ":Lazy home" })
keymap("n", "<leader>M", cmd.Mason, { desc = ":Mason" })

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
keymap({ "o", "x" }, "H", "^")
keymap("n", "H", "0^") -- 0^ ensures fully scrolling to the left on long lines

keymap({ "n", "x", "o" }, "L", "$")

keymap("n", "J", function() qol.overscroll("6j") end, { desc = "6j (with overscroll)" })
keymap("x", "J", "6j")
keymap({ "n", "x" }, "K", "6k")

keymap("o", "J", "2j") -- dj = delete 2 lines, dJ = delete 3 lines
keymap("o", "K", "2k")

-- add overscroll
keymap("n", "j", function() qol.overscroll("j") end, { desc = "j (with overscroll)" })
keymap({ "n", "x" }, "G", "Gzz")

-- Jump History
keymap("n", "<C-h>", "<C-o>", { desc = "Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "Jump forward" })

-- Search
keymap("n", "-", "/", { desc = "Search" })
keymap("x", "-", "<Esc>/\\%V", { desc = "Search within selection" })

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
keymap("n", "^", "za", { desc = "toggle fold" })

-- [M]atchUp
keymap({ "n", "x", "o" }, "m", "<Plug>(matchup-%)", { desc = "matchup" })

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

g.killringCount = 0
g.cursorPreYank = getCursor(0)
g.lastYank = nil

-- don't pollute the register
keymap("n", "x", '"_x')
keymap("n", "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P", { desc = "paste without switcing register" })

-- yanking without moving the cursor
augroup("yankImprovements", {})
autocmd("CursorMoved", {
	group = "yankImprovements",
	callback = function() g.cursorPreYank = getCursor(0) end,
})

-- - yanking without moving the cursor
-- - highlighted yank
-- - saves yanks in numbered register, so `"1p` pastes previous yanks.
autocmd("TextYankPost", {
	group = "yankImprovements",
	callback = function()
		-- highlighted yank
		vim.highlight.on_yank { timeout = 1500 }

		if vim.v.event.operator == "y" then -- deletion does not need stickiness and also already shifts registers
			-- sticky yank
			setCursor(0, g.cursorPreYank)

			-- add yanks and deletes to numbered registers
			if vim.v.event.regname ~= "" then return end
			for i = 8, 2, -1 do
				local regcontent = fn.getreg(tostring(i))
				fn.setreg(tostring(i + 1), regcontent)
			end
			fn.setreg("1", fn.getreg("0")) -- so both y and d copy to "1
			if g.lastYank then fn.setreg("2", g.lastYank) end
		end
		g.lastYank = fn.getreg('"') -- so deletes get stored here
	end,
})

-- cycle through the last deletes/yanks ("2 till "9)
keymap("n", "P", function()
	cmd.undo()
	normal('"' .. tostring(g.killringCount) .. "p")
	g.killringCount = g.killringCount + 1
	if g.killringCount > 9 then g.killringCount = 2 end
end, { desc = "simply killring" })

keymap("n", "p", function()
	g.killringCount = 2
	normal("p")
end, { desc = "paste & reset killring" })

-- paste charwise reg as linewise & vice versa
keymap("n", "gp", function()
	local reg = "+"
	local regContent = fn.getreg(reg)
	local isLinewise = fn.getregtype(reg) == "V"

	local targetRegType
	if isLinewise then
		targetRegType = "v"
		regContent = regContent:gsub("^%s*", ""):gsub("%s*$", "")
	else
		targetRegType = "V"
	end

	fn.setreg(reg, regContent, targetRegType) ---@diagnostic disable-line: param-type-mismatch
	normal('"' .. reg .. "p") -- for whatever reason, not naming a register does not work here
	if targetRegType == "V" then normal("==") end
end, { desc = "paste differently" })

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
keymap("n", "ss", function() require("substitute").line() end, { desc = "substitute line" })
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

-- Replace Mode
keymap("n", "gR", "R", { desc = "replace mode" })

-- Duplicate Line / Selection (mnemonic: [r]eplicate)
keymap("n", "R", qol.duplicateLine, { desc = "duplicate line" })
keymap("x", "R", qol.duplicateSelection, { desc = "duplicate selection" })

-- Undo
keymap({ "n", "x" }, "U", "<C-r>", { desc = "redo" }) -- redo
keymap("n", "<C-u>", qol.undoDuration, { desc = "undo specific durations" })
keymap(
	"n",
	"<leader>u",
	function() require("telescope").extensions.undo.undo() end,
	{ desc = "Telescope Undotree" }
)

-- Refactor
keymap(
	"n",
	"<leader>i",
	function() require("refactoring").refactor("Inline Variable") end,
	{ desc = "Refactor: Inline Variable" }
)
keymap(
	"n",
	"<leader>e",
	function() require("refactoring").refactor("Extract Variable") end,
	{ desc = "Refactor: Extract Variable" }
)

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

--------------------------------------------------------------------------------
-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated V selects more lines" })
keymap("x", "v", "<C-v>", { desc = "vv from Normal Mode goes to Visual Block Mode" })

--------------------------------------------------------------------------------
-- SPLITS
keymap("n", "<C-w>v", ":vsplit #<CR>", { desc = "vertical split (alt file)" }) -- open the alternate file in the split instead of the current file
keymap("n", "<C-w>h", ":split #<CR>", { desc = "horizontal split (alt file)" })
keymap("", "<C-Right>", ":vertical resize +3<CR>", { desc = "vertical resize" }) -- resizing on one key for sanity
keymap("", "<C-Left>", ":vertical resize -3<CR>", { desc = "vertical resize" })
keymap("", "<C-Down>", ":resize +3<CR>", { desc = "horizontal resize" })
keymap("", "<C-Up>", ":resize -3<CR>", { desc = "horizontal resize" })

--------------------------------------------------------------------------------
-- BUFFERS & WINDOWS

keymap("n", "gb", telescope.buffers, { desc = "Telescope: open buffers" })
-- INFO: <BS> to cycle buffer has to be set in cybu config

keymap("t", "ä", [[<C-\><C-n><C-w>p]], { desc = "switch to previous window" })

keymap("n", "<CR>", qol.altBufferWindow, { desc = "switch to alt buffer/window" })

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
keymap("n", "<leader>gs", ":Neogit<CR>")
keymap("n", "<leader>gc", ":Neogit commit<CR>")

-- Git-link
keymap({ "n", "x" }, "<leader>gl", qol.gitLink, { desc = "git link" })

-- add-commit-pull-push
keymap("n", "<leader>gg", qol.addCommitPush, { desc = "git add-commit-pull-push" })

-- Diffview
g.diffviewOpen = false
keymap("n", "<leader>gd", function()
	if g.diffviewOpen then
		cmd.DiffviewClose()
		g.diffviewOpen = false
		return
	end
	vim.ui.input({ prompt = "Git Pickaxe (empty = full history)" }, function(query)
		if not query then
			return
		elseif query == "" then
			cmd("DiffviewFileHistory %")
		else
			cmd("DiffviewFileHistory % -G" .. query)
		end
		cmd.wincmd("w") -- go directly to file window
		g.diffviewOpen = true
	end)
end)

--------------------------------------------------------------------------------

-- Option Toggling
keymap("n", "<leader>os", ":set spell!<CR>")
keymap("n", "<leader>or", ":set relativenumber!<CR>")
keymap("n", "<leader>on", ":set number!<CR>")
keymap("n", "<leader>ol", cmd.LspRestart, {desc = "LSP Restart"})
keymap("n", "<leader>ow", qol.toggleWrap, { desc = "toggle wrap" })

keymap("n", "<leader>od", function()
	if g.diagnosticOn == nil then g.diagnosticOn = true end
	if g.diagnosticOn then
		vim.diagnostic.disable(0)
	else
		vim.diagnostic.enable(0)
	end
	g.diagnosticOn = not g.diagnosticOn
end, { desc = "toggle diagnostics" })

--------------------------------------------------------------------------------

-- TERMINAL AND CODI
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = "Esc (Normal Mode in Terminal)" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = "Paste in Terminal Mode" })
augroup("terminal", {})
autocmd("FileType", {
	group = "terminal",
	pattern = "toggleterm",
	callback = function() keymap("n", "<CR>", "i<CR>", { desc = "Accept Terminal Input", buffer = true }) end,
})

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
		local karabinerBuildScp = vim.env.DOTFILE_FOLDER .. "/karabiner/build-karabiner-config.js"
		local result = fn.system('osascript -l JavaScript "' .. karabinerBuildScp .. '"')
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
local opts = { buffer = true, nowait = true }
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
opts = { buffer = true, nowait = true, remap = true }
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
