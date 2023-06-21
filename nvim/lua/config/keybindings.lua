local autocmd = vim.api.nvim_create_autocmd
local bo = vim.bo
local cmd = vim.cmd
local expand = vim.fn.expand
local fn = vim.fn
local keymap = vim.keymap.set
local u = require("config.utils")

--------------------------------------------------------------------------------
-- META

-- search keymaps
keymap("n", "?", function() cmd.Telescope("keymaps") end, { desc = " Search Keymaps" })

-- Highlights
keymap("n", "<leader>H", function() cmd.Telescope("highlights") end, { desc = " Highlight Groups" })

-- [P]lugins
keymap("n", "<leader>pp", require("lazy").sync, { desc = " Lazy Update/Sync" })
keymap("n", "<leader>ph", require("lazy").home, { desc = " Lazy Overview" })
keymap("n", "<leader>pi", require("lazy").install, { desc = " Lazy Install" })

keymap("n", "<leader>pm", cmd.Mason, { desc = " Mason Overview" })
-- stylua: ignore
keymap("n", "<leader>pa", function() cmd.TSModuleInfo("highlight") end, { desc = " Treesitter Parser Overview" })
keymap("n", "<leader>pt", cmd.TSUpdate, { desc = " Treesitter Parser Update" })

-- Theme Picker
-- stylua: ignore
keymap("n", "<leader>pc", function() cmd.Telescope("colorscheme") end, { desc = "  Change Colorschemes" })

--------------------------------------------------------------------------------

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", function()
	local lastCommand = fn.getreg(":"):gsub("^I ", "")
	if #lastCommand == 0 then
		vim.notify("No last command available", u.warn)
		return
	end
	fn.setreg("+", lastCommand)
	vim.notify("COPIED\n" .. lastCommand)
end, { desc = "󰘳 Copy last command" })

-- [l]ast command [a]gain
-- as opposed to `@:`, this works across restarts of neovim
keymap("n", "<leader>la", ":<Up><CR>", { desc = "󰘳 Run last command again" })

-- search command history
-- stylua: ignore
keymap("n", "<leader>lh", function() cmd.Telescope("command_history") end, { desc = "󰘳  Command History" })

-- show current filetype & buftype
keymap("n", "<leader>lf", function()
	local icon = require("nvim-web-devicons").get_icon(vim.fn.bufname(), vim.bo.filetype)
	if not icon then
		icon = ""
	else
		icon = icon .. " "
	end
	local out = ("filetype: %s%s"):format(icon, bo.filetype)
	if bo.buftype ~= "" then out = out .. "\nbuftype: " .. bo.buftype end
	vim.notify(out, u.trace)
end, { desc = "󰽘 Inspect FileType & BufType" })

-- copy [l]ast [n] notification
keymap("n", "<leader>ln", function()
	local history = require("notify").history {}
	local lastNotify = history[#history]
	if not lastNotify then
		vim.notify("No Notification in this session.", u.warn)
		return
	end
	local msg = ""
	for _, line in pairs(lastNotify.message) do
		msg = msg .. line .. "\n"
	end
	fn.setreg("+", msg)
	vim.notify("Last Notification copied.\n" .. msg, u.trace)
end, { desc = "󰘳 Copy Last Notification" })

-- copy [l]ast [m]essage
keymap("n", "<leader>lm", function()
	vim.cmd.redir("@+")
	vim.cmd("silent! 1messages")
	vim.cmd.redir("END")
	vim.notify("Last Message copied.\n" .. fn.getreg("+"), u.trace)
end, { desc = "󰘳 Copy Last Message" })

-- Dismiss notifications & re-enable fold after search
keymap("n", "<Esc>", function()
	local clearPending = require("notify").pending() > 10
	require("notify").dismiss { pending = clearPending }
end, { desc = "Clear Notifications" })

--------------------------------------------------------------------------------

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({ "o", "x" }, "H", "^")
keymap("n", "H", "0^") -- 0^ ensures fully scrolling to the left on long indented lines
keymap({ "n", "x" }, "L", "$") -- not using "o", since used for link textobj
keymap({ "n", "x" }, "J", "6j")
keymap({ "n", "x" }, "K", "6k")

-- dj = delete 2 lines, dJ = delete 3 lines
keymap("o", "J", "2j")
keymap("o", "K", "2k")

-- Jump history
keymap("n", "<C-h>", "<C-o>", { desc = "Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "Jump forward" })

--------------------------------------------------------------------------------

-- Marks

-- stylua: ignore start
keymap("n", "Ä", function() require("bookmarks").bookmark_toggle() end, { desc = "󰃀 Toggle Bookmark" })
keymap("n", "ä", function() require("bookmarks").bookmark_next() end, { desc = "󰃀 Next Bookmark" })
keymap("n", "dä", function() require("bookmarks").bookmark_clean() end, { desc = "󰃀 Clear All Bookmark" })
keymap("n", "gä", function() require("bookmarks").bookmark_list() end, { desc = "󰃀  Bookmarks to Quickfix" })
-- stylua: ignore end

-- Hunks and Changes
keymap("n", "gh", ":Gitsigns next_hunk<CR>zv", { desc = "goto next hunk" })
keymap("n", "gH", ":Gitsigns prev_hunk<CR>zv", { desc = "goto previous hunk" })

-- [M]atching Bracket
-- remap needed, if using the builtin matchit plugin / vim-matchup
keymap("n", "m", "%", { remap = true, desc = "Goto Matching Bracket" })

--------------------------------------------------------------------------------

-- SEARCH
keymap("x", "-", "zn<Esc>/\\%V", { desc = "Search within selection" })
keymap("n", "+", "*", { desc = "Search word under cursor" })
keymap("x", "+", [["zy/\V<C-R>=getreg("@z")<CR><CR>]], { desc = "Visual star" })

-- auto-nohl -> https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?context=3
vim.on_key(function(char)
	if vim.g.scrollview_refreshing then return end -- FIX: https://github.com/dstein64/nvim-scrollview/issues/88#issuecomment-1570400161
	local searchKeys = { "n", "N", "*", "#" }
	local searchConfirmed = (fn.keytrans(char) == "<CR>" and fn.getcmdtype():find("[/?]") ~= nil)
	if not (searchConfirmed or fn.mode() == "n") then return end
	local searchKeyUsed = searchConfirmed or (vim.tbl_contains(searchKeys, fn.keytrans(char)))
	if vim.opt.hlsearch:get() ~= searchKeyUsed then vim.opt.hlsearch = searchKeyUsed end
end, vim.api.nvim_create_namespace("auto_nohl"))

autocmd("CmdlineEnter", {
	callback = function()
		if fn.getcmdtype():find("[/?]") then vim.opt.hlsearch = true end
	end,
})

--------------------------------------------------------------------------------
-- EDITING

-- QUICKFIX
keymap("n", "gq", require("funcs.quickfix").next, { desc = " Next Quickfix" })
keymap("n", "gQ", require("funcs.quickfix").previous, { desc = " Previous Quickfix" })
keymap("n", "dQ", require("funcs.quickfix").deleteList, { desc = " Empty Quickfix List" })

-- COMMENTS & ANNOTATIONS
keymap("n", "qw", require("funcs.comment-divider").commentHr, { desc = " Horizontal Divider" })
keymap("n", "wq", "yypkqqj", { desc = " Duplicate Line as Comment", remap = true })

-- WHITESPACE CONTROL
keymap("n", "=", "mzO<Esc>`z", { desc = "  blank above" })
keymap("n", "_", "mzo<Esc>`z", { desc = "  blank below" })
keymap("n", "<Tab>", ">>", { desc = "󰉶 indent" })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent" })
keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent" })

-- delete surrounding indentation
keymap("n", "dsi", function()
	-- select inner indentation
	require("various-textobjs").indentation(true, true)
	-- when textobj is found, will switch to visual line mode
	local notOnIndentedLine = vim.fn.mode():find("V") == nil
	if notOnIndentedLine then return end

	-- dedent indentation
	u.normal("<")

	-- delete start- and end-border
	local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1] + 1
	local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1] - 1

	-- don't delete endborder when language does not have them
	if not (bo.filetype == "python" or bo.filetype == "yaml" or bo.filetype == "markdown") then
		-- delete end first so line index is not shifted
		vim.cmd(tostring(endBorderLn) .. " delete")
	end
	vim.cmd(tostring(startBorderLn) .. " delete")
end, { desc = "Delete surrounding indentation" })

-- Append to / delete from EoL
local trailingKeys = { ",", ";", '"', "'", ")", "}", "]", "\\" }
for _, key in pairs(trailingKeys) do
	keymap("n", "<leader>" .. key, "mzA" .. key .. "<Esc>`z", { desc = "which_key_ignore" })
end
keymap("n", "X", "mz$x`z", { desc = "Delete last character" })

-- Case Conversion
local casings = {
	{ char = "u", arg = "upper", desc = "UPPER CASE" },
	{ char = "l", arg = "lower", desc = "lower case" },
	{ char = "t", arg = "title", desc = "Title case" },
	{ char = "c", arg = "camel", desc = "camelCase" },
	{ char = "p", arg = "pascal", desc = "PascalCase" },
	{ char = "s", arg = "snake", desc = "snake_case" },
	{ char = "k", arg = "dash", desc = "kebab-case" },
	{ char = "/", arg = "path", desc = "path/case" },
	{ char = ".", arg = "dot", desc = "dot.case" },
	{ char = "_", arg = "constant", desc = "SCREAMING_SNAKE_CASE" },
}

for _, case in pairs(casings) do
	keymap(
		"n",
		"cr" .. case.char,
		("<cmd>lua require('textcase').current_word('to_%s_case')<CR>"):format(case.arg),
		{ desc = case.desc }
	)
	keymap(
		"n",
		"cR" .. case.char,
		("<cmd>lua require('textcase').lsp_rename('to_%s_case')<CR>"):format(case.arg),
		{ desc = "󰒕 " .. case.desc }
	)
end

-- Word Switcher (fallback: switch casing)
-- stylua: ignore
keymap( "n", "ö", function() require("funcs.flipper").flipWord() end, { desc = "switch common words" })

-- open new brace
keymap({ "n", "i" }, "<D-o>", function()
	local line = vim.api.nvim_get_current_line()
	line = line:gsub(" $", "") .. " {" -- only appends space if there is none already
	vim.api.nvim_set_current_line(line)
	local ln = u.getCursor(0)[1]
	local indent = line:match("^%s*")
	vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. "\t", indent .. "}" })
	u.setCursor(0, { ln + 1, 1 }) -- go line down
	cmd.startinsert { bang = true }
end, { desc = " Open new brace" })

--------------------------------------------------------------------------------

-- SPELLING

-- [z]pelling [l]ist
keymap("n", "zl", function() cmd.Telescope("spell_suggest") end, { desc = "󰓆 Spell Suggest" })
keymap("n", "z.", "1z=", { desc = "󰓆 Correct" })

---add word under cursor to vale/languagetool dictionary
keymap({ "n", "x" }, "zg", function()
	local word
	if fn.mode() == "n" then
		local iskeywBefore = vim.opt_local.iskeyword:get() -- remove word-delimiters for <cword>
		vim.opt_local.iskeyword:remove { "_", "-", "." }
		word = expand("<cword>")
		vim.opt_local.iskeyword = iskeywBefore
	else
		u.normal('"zy')
		word = fn.getreg("z")
	end
	local filepath = u.linterConfigFolder .. "/dictionary-for-vale-and-languagetool.txt"
	local success = u.appendToFile(filepath, word)
	if not success then return end -- error message already by AppendToFile
	vim.notify(string.format('󰓆 Now accepting:\n"%s"', word))
end, { desc = "󰓆 Accept Word" })

--------------------------------------------------------------------------------

-- [S]ubstitute Operator (substitute.nvim)
keymap("n", "s", function() require("substitute").operator() end, { desc = "substitute operator" })
keymap("n", "ss", function() require("substitute").line() end, { desc = "substitute line" })
keymap("n", "S", function() require("substitute").eol() end, { desc = "substitute to end of line" })
-- stylua: ignore
keymap("n", "sx", function() require("substitute.exchange").operator() end, { desc = "exchange operator" })
keymap("n", "sX", "sx$", { remap = true, desc = "exchange to EoL" })
keymap("n", "sxx", function() require("substitute.exchange").line() end, { desc = "exchange line" })

--------------------------------------------------------------------------------
-- REFACTORING

vim.keymap.set(
	{ "n", "x" },
	"<leader>ff",
	function() return ":S /" .. vim.fn.expand("<cword>") .. "//g<Left><Left>" end,
	{ desc = "󱗘 :AltSubstitute (word under cursor)", expr = true }
)

keymap("x", "<leader>fo", ":sort<CR>", { desc = "󱗘 :sort selection" })
keymap("n", "<leader>fo", "vip:sort<CR>", { desc = "󱗘 :sort paragraph" })
keymap("n", "<leader>fd", ":g//d<Left><Left>", { desc = "󱗘 :delete matching lines" })
keymap("n", "<leader>fy", ":g//y<Left><Left>", { desc = "󱗘 :yank matching lines" })

-- stylua: ignore
keymap("n", "<leader>fq", function() require("replacer").run { rename_files = true } end, { desc = "󱗘  replacer.nvim" })
-- stylua: ignore
keymap({ "n", "x" }, "<leader>fs", function() require("ssr").open() end, { desc = "󱗘 Structural S&R" })

-- Refactoring.nvim
-- stylua: ignore start
keymap({ "n", "x" }, "<leader>fi", function() require("refactoring").refactor("Inline Variable") end, { desc = "󱗘 Inline Var" })
keymap({ "n", "x" }, "<leader>fe", function() require("refactoring").refactor("Extract Variable") end, { desc = "󱗘 Extract Var" })
keymap({ "n", "x" }, "<leader>fu", function() require("refactoring").refactor("Extract Function") end, { desc = "󱗘 Extract Func" })
-- stylua: ignore end

keymap("n", "<leader>f<Tab>", function()
	bo.expandtab = false
	cmd.retab { bang = true }
	bo.tabstop = vim.opt_global.tabstop:get()
	vim.notify("Now using: Tabs ↹ ")
end, { desc = "↹ Use Tabs" })

keymap("n", "<leader>f<Space>", function()
	bo.expandtab = true
	cmd.retab { bang = true }
	vim.notify("Now using: Spaces 󱁐")
end, { desc = "󱁐 Use Spaces" })

--------------------------------------------------------------------------------

-- Undo
keymap({ "n", "x" }, "U", "<C-r>", { desc = "󰑎 Redo" }) -- remap for highlight-undo.nvim
keymap({ "n", "x" }, "<leader>ul", "U", { desc = "󰕌 Undo Line" })
keymap("n", "<leader>ut", ":UndotreeToggle<CR>", { desc = "󰕌  Undotree" })
-- stylua: ignore
keymap("n", "<leader>ur", function() cmd.later(tostring(vim.opt.undolevels:get())) end, { desc = "󰛒 Redo All" })
keymap("n", "<leader>uh", ":Gitsigns reset_hunk<CR>", { desc = "󰕌 󰊢 Undo (Reset) Hunk" })

-- save open time for each buffer
autocmd("BufReadPost", {
	callback = function() vim.b.timeOpened = os.time() end,
})

keymap("n", "<leader>uo", function()
	local now = os.time() -- saved in epoch secs
	local secsPassed = now - vim.b.timeOpened
	cmd.earlier(tostring(secsPassed) .. "s")
end, { desc = "󰜊 Undo since last open" })

--------------------------------------------------------------------------------

-- LOGGING & DEBUGGING
-- stylua: ignore start
keymap({ "n", "x" }, "<leader>ll", function() require("funcs.quick-log").log() end, { desc = " log variable" })
keymap({ "n", "x" }, "<leader>lo", function() require("funcs.quick-log").objectlog() end, { desc = " object log variable" })
keymap("n", "<leader>lb", function() require("funcs.quick-log").beeplog() end, { desc = " beep log" })
keymap("n", "<leader>l1", function() require("funcs.quick-log").timelog() end, { desc = " time log" })
keymap("n", "<leader>lr", function() require("funcs.quick-log").removelogs() end, { desc = "  remove log" })
keymap("n", "<leader>ld", function() require("funcs.quick-log").debuglog() end, { desc = " debugger" })
keymap("n", "<leader>lt", cmd.Inspect, { desc = " Treesitter Inspect" })
-- stylua: ignore end

keymap("n", "<leader>bu", function() require("dapui").toggle() end, { desc = " Toggle DAP-UI" })
keymap("n", "<leader>bv", function() require("dap").step_over() end, { desc = " Step Over" })
keymap("n", "<leader>bo", function() require("dap").step_out() end, { desc = " Step Out" })
keymap("n", "<leader>bi", function() require("dap").step_into() end, { desc = " Step Into" })
-- INFO toggling breakpoints done via nvim-recorder
-- stylua: ignore start
keymap("n", "<leader>bc", function() require("dap").run_to_cursor() end, { desc = " Run to Cursor" })
keymap("n", "<leader>br", function() require("dap").clear_breakpoints() end, { desc = "  Remove Breakpoints" })
keymap("n", "<leader>bq", function() require("dap").list_breakpoints() end, { desc = "  Breakpoints to QuickFix" })
-- stylua: ignore end

keymap("n", "<leader>bt", function()
	vim.opt_local.number = false
	require("dapui").close()
	require("dap").terminate()
end, { desc = "  Terminate" })
keymap("n", "<leader>bn", function()
	vim.opt_local.number = true
	-- INFO is the only one that needs manual starting, other debuggers
	-- start with `continue` by themselves
	if require("dap").status() ~= "" then
		vim.notify("Debugger already running.", u.warn)
		return
	end
	if not bo.filetype == "lua" then
		vim.notify("Not a lua file.", u.warn)
		return
	end
	require("osv").run_this()
end, { desc = "  Start nvim-lua debugger" })

--------------------------------------------------------------------------------
-- LINE & CHARACTER MOVEMENT

-- Node Swapping
-- stylua: ignore start
keymap("n", "ü", function () require("sibling-swap").swap_with_right() end, { desc = "󰑃 Move Node Right" })
keymap("n", "Ü", function () require("sibling-swap").swap_with_left() end, { desc = "󰑁 Move Node Left" })
-- stylua: ignore end
autocmd("FileType", {
	pattern = { "markdown", "text", "gitcommit" },
	callback = function()
		keymap("n", "ü", '"zdawel"zph', { desc = "➡️ Move Word Right", buffer = true })
		keymap("n", "Ü", '"zdawbh"zph', { desc = "⬅️ Move Word Left", buffer = true })
	end,
})

keymap("n", "<Down>", [[:. move +1<CR>==]], { desc = "󰜮 Move Line Down" })
keymap("n", "<Up>", [[:. move -2<CR>==]], { desc = "󰜷 Move Line Up" })
keymap("n", "<Right>", function()
	if vim.fn.col(".") >= vim.fn.col("$") - 1 then return end
	return [["zx"zp]]
end, { desc = "Move Char Right", expr = true })
keymap("n", "<Left>", function()
	if vim.fn.col(".") == 1 then return end
	return [["zdh"zph]]
end, { desc = "Move Char Left", expr = true })

-- stylua: ignore start
keymap("x", "<Down>", [[:move '>+1<CR>:normal! gv=gv<CR>]], { desc = "󰜮 Move selection down" })
keymap("x", "<Up>", [[:move '<-2<CR>:normal! gv=gv<CR>]], { desc = "󰜷 Move selection up" })
-- stylua: ignore end
keymap("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move selection right" })
keymap("x", "<Left>", [["zdh"zPgvhoho]], { desc = "➡️ Move selection left" })

-- Merging / Splitting Lines
keymap("n", "<leader>s", cmd.TSJToggle, { desc = "󰗈 split/join lines" })
keymap("x", "<leader>s", [[<Esc>`>a<CR><Esc>`<i<CR><Esc>]], { desc = "󰗈 split around selection" })
keymap({ "n", "x" }, "M", "J", { desc = "󰗈 merge line up" })
keymap({ "n", "x" }, "<leader>m", "ddpkJ", { desc = "󰗈 merge line down" })

-- URL Opening (forward-seeking `gx`)
keymap("n", "gx", function()
	require("various-textobjs").url()
	local foundURL = fn.mode():find("v") -- will only switch to visual mode if URL found
	if foundURL then
		u.normal('"zy')
		local url = fn.getreg("z")
		os.execute("open '" .. url .. "'")
	end
end, { desc = "󰌹 Smart URL Opener" })

--------------------------------------------------------------------------------
-- INSERT MODE & COMMAND MODE
keymap("i", "<C-e>", "<Esc>A") -- EoL
keymap("i", "<C-k>", "<Esc>lDi") -- kill line
keymap("i", "<C-a>", "<Esc>I") -- BoL
keymap("c", "<C-a>", "<Home>")
keymap("c", "<C-e>", "<End>")
keymap("c", "<C-u>", "<C-e><C-u>") -- clear

-- indent properly when entering insert mode on empty lines
keymap("n", "i", function()
	if #vim.fn.getline(".") == 0 then return [["_cc]] end
	return "i"
end, { expr = true, desc = "better i" })

--------------------------------------------------------------------------------
-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated V selects more lines" })
keymap("x", "v", "<C-v>", { desc = "vv from Normal Mode starts Visual Block Mode" })

--------------------------------------------------------------------------------
-- BUFFERS & WINDOWS & SPLITS

-- stylua: ignore start
keymap("n", "<CR>", function() require("funcs.alt-alt").altBufferWindow() end, { desc = "󰽙 Alt Buffer" })
keymap("n", "<BS>", "<Plug>(CybuNext)", { desc = "󰽙 Next Buffer" })
keymap("n", "<C-CR>", "<C-w>w", { desc = " Next Window" })

keymap({ "n", "x", "i" }, "<D-w>", function() require("funcs.alt-alt").betterClose() end, { desc = "󰽙 close buffer/window" })
keymap({ "n", "x", "i" }, "<D-S-t>", function() require("funcs.alt-alt").reopenBuffer() end, { desc = "󰽙 reopen last buffer" })

keymap("n", "gb", function() cmd.Telescope("buffers") end, { desc = " 󰽙 Buffers" })

-- stylua: ignore end
keymap("", "<C-w>h", ":split<CR>", { desc = " horizontal split" })
keymap("", "<C-Right>", ":vertical resize +3<CR>", { desc = " vertical resize (+)" })
keymap("", "<C-Left>", ":vertical resize -3<CR>", { desc = " vertical resize (-)" })
keymap("", "<C-Down>", ":resize +3<CR>", { desc = " horizontal resize (+)" })
keymap("", "<C-Up>", ":resize -3<CR>", { desc = " horizontal resize (-)" })

-- HARPOON

---of all the marked files, gets the next one in order of last change time
---(ctime), similar to the grapling hook plugin for Obsidian
---this is essentially an alternative to `require("harpoon.ui").nav_next()`,
---only that the order of cycling is not determined by the list, but by the
---mtime order
local function harpoonNextCtimeFile()
	-- get project
	local pwd = vim.loop.cwd() or ""
	local jsonPath = fn.stdpath("data") .. "/harpoon.json"
	local json = u.readFile(jsonPath)
	if not json then return end
	local data = vim.json.decode(json)
	if not data then return end
	local project = data.projects[pwd]
	if not project or #project.mark.marks == 0 then return end

	-- sort by atime
	local marksCtime = {}
	for _, file in pairs(project.mark.marks) do
		local absPath = pwd .. "/" .. file.filename
		local atime = vim.loop.fs_stat(absPath).atime.sec
		table.insert(marksCtime, { atime = atime, path = absPath })
	end
	table.sort(marksCtime, function(a, b) return a.atime > b.atime end)

	-- return next file
	local currentFile = expand("%:p")
	local fileFound = false
	for _, file in pairs(marksCtime) do
		if fileFound then return file.path end
		fileFound = currentFile == file.path
	end
	-- if at last marked file or if current file is not marked in harpoon, return
	-- the last accessed file instead
	return marksCtime[1].path
end

-- keymap("n", "<D-CR>", function() require("harpoon.ui").nav_next() end, { desc = "󰛢 Next" })
keymap("n", "<D-CR>", function() vim.cmd.edit(harpoonNextCtimeFile()) end, { desc = "󰛢 Next" })

-- stylua: ignore start
-- consistent with adding/removing bookmarks in the Browser/Obsidian
keymap("n", "<D-d>", function()
	require("harpoon.mark").add_file()
	vim.b.harpoonMark = "󰛢"
end, { desc = "󰛢 Add" })
keymap("n", "<D-S-d>", function() require("harpoon.ui").toggle_quick_menu() end, { desc = "󰛢 Menu" })
-- stylua: ignore end

------------------------------------------------------------------------------

-- CMD-KEYBINDINGS
keymap({ "n", "x", "i" }, "<D-s>", cmd.update, { desc = " Save & " })

-- stylua: ignore
keymap("", "<D-l>", function() fn.system("open -R '" .. expand("%:p") .. "'") end, { desc = "󰀶 Reveal in Finder" })
keymap("", "<D-S-l>", function()
	local parentFolder = expand("%:p:h")
	if not parentFolder:find("Alfred%.alfredpreferences") then
		vim.notify("Not in an Alfred directory.", u.warn)
		return
	end
	local workflowId = parentFolder:match("Alfred%.alfredpreferences/workflows/([^/]+)")
	-- stylua: ignore
	local command = ([[osascript -l JavaScript -e 'Application("com.runningwithcrayons.Alfred").revealWorkflow("%s")']]):format(workflowId)
	fn.system("open -a 'Alfred Preferences' && " .. command)
end, { desc = "󰮤 Reveal Workflow in Alfred" })
keymap("n", "<D-0>", ":10messages<CR>", { desc = ":messages (last 10)" }) -- as cmd.function these wouldn't require confirmation
keymap("n", "<D-9>", ":Notifications<CR>", { desc = ":Notifications" })

-- Multi-Cursor https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
-- are overridden inside snippet for snippetjumping
vim.g.VM_maps = {
	["Find Under"] = "<D-j>", -- select word under cursor & enter visual-multi (normal) / add next occurrence (visual-multi)
	["Visual Add"] = "<D-j>", -- enter visual-multi (visual)
	["Skip Region"] = "<D-S-j>", -- skip current selection (visual-multi)
}

--- copy & paste
keymap({ "n", "x" }, "<D-v>", "p", { desc = "paste" }) -- needed for pasting from Alfred clipboard history
keymap("c", "<D-v>", "<C-r>+", { desc = "paste" })
keymap("i", "<D-v>", "<C-g>u<C-r><C-o>+", { desc = "paste" }) -- "<C-g>u" adds undopoint before the paste
keymap("x", "<D-c>", "y", { desc = "copy" }) -- needed for compatibility with automation apps

-- cmd+e: inline code
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = "  Inline Code" }) -- no selection = word under cursor
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = "  Inline Code" })
keymap("i", "<D-e>", "``<Left>", { desc = "  Inline Code" })

-- cmd+t: template string
keymap("n", "<D-t>", "bi${<Esc>ea}<Esc>b", { desc = "Template String" }) -- no selection = word under cursor
keymap("x", "<D-t>", "<Esc>${<i}<Esc>${>la}<Esc>b", { desc = "Template String" })
keymap("i", "<D-t>", "${}<Left>", { desc = "Template String" })

--------------------------------------------------------------------------------

-- COLOR PICKER
keymap("n", "#", ":CccPick<CR>", { desc = " Color Picker" })
keymap("n", "'", ":CccConvert<CR>", { desc = " Convert Color" }) -- shift-# on German keyboard

-- AI
keymap("n", "<leader>a", cmd.NeoAI, { desc = "󰚩 NeoAI" })
keymap("x", "<leader>a", cmd.NeoAIContext, { desc = "󰚩 NeoAI Context" })

--------------------------------------------------------------------------------
-- FILES

-- P[a]th gf needs remapping, since `gf` is used for LSP references
keymap("n", "ga", "gf", { desc = "Goto Path" })

-- number of harpoon files in the current project
---@nodiscard
---@return number|nil
local function harpoonFileNumber()
	local pwd = vim.loop.cwd() or ""
	local jsonPath = fn.stdpath("data") .. "/harpoon.json"
	local json = u.readFile(jsonPath)
	if not json then return end
	local data = vim.json.decode(json)
	if not data then return end
	local project = data.projects[pwd]
	if not project then return end
	return #project.mark.marks
end

---@nodiscard
---@return string name of the current project
local function projectName()
	local pwd = vim.loop.cwd() or ""
	local name = pwd:gsub(".*/", "")
	return name
end

-- find files
-- add project name + number of harpoon files to prompt title
keymap("n", "go", function()
	local harpoonNumber = harpoonFileNumber() or 0
	local title = tostring(harpoonNumber) .. "󰛢 " .. projectName()
	require("telescope").extensions.file_browser.file_browser { prompt_title = title }
end, { desc = " Browse in Project" })

-- stylua: ignore
keymap( "n", "gO", function()
	require("telescope").extensions.file_browser.file_browser {
		path = expand("%:p:h"),
		prompt_title = "󰝰 " .. expand("%:p:h:t"),
	}
end, { desc = " Browse in Current Folder" })

-- stylua: ignore
-- goto projects
keymap("n", "gp", function() require("telescope").extensions.projects.projects { } end, { desc = " Projects" })

-- stylua: ignore
keymap("n", "gl", function() require("telescope.builtin").live_grep {
	prompt_title = "Live Grep: " .. projectName() }
end, { desc = " Live Grep in Project" })
-- stylua: ignore
keymap({ "n", "x" }, "gL", function() cmd.Telescope("grep_string") end, { desc = " Grep cword in Project" })
keymap("n", "gr", function() cmd.Telescope("oldfiles") end, { desc = " Recent Files" })
keymap("n", "gc", function() cmd.Telescope("resume") end, { desc = "  Continue" })

-- File Operations
-- stylua: ignore start
keymap("n", "<C-p>", function() require("genghis").copyFilepath() end, { desc = " Copy filepath" })
keymap("n", "<C-n>", function() require("genghis").copyFilename() end, { desc = " Copy filename" })
keymap("n", "<leader>x", function() require("genghis").chmodx() end, { desc = " chmod +x" })
keymap("n", "<C-r>", function() require("genghis").renameFile() end, { desc = " Rename file" })
keymap("n", "<D-S-m>", function() require("genghis").moveAndRenameFile() end, { desc = " Move-rename file" })
keymap("n", "<C-d>", function() require("genghis").duplicateFile() end, { desc = " Duplicate file" })
keymap("n", "<D-BS>", function() require("genghis").trashFile() end, { desc = " Move file to trash" })
keymap("n", "<D-n>", function() require("genghis").createNewFile() end, { desc = " Create new file" })
keymap("x", "X", function() require("genghis").moveSelectionToNewFile() end, { desc = " Selection to new file" })
-- stylua: ignore end

------------------------------------------------------------------------------
-- LSP KEYBINDINGS

-- INFO some LSP bindings done globally, so they can be used by null-ls as well
keymap("n", "ge", vim.diagnostic.goto_next, { desc = "󰒕 Next Diagnostic" })
keymap("n", "gE", vim.diagnostic.goto_prev, { desc = "󰒕 Previous Diagnostic" })

keymap("n", "<leader>d", function()
	require("lsp_lines").toggle()
	local nextState = vim.g.prevVirtText or false
	vim.g.prevVirtText = vim.diagnostic.config().virtual_text
	vim.diagnostic.config { virtual_text = nextState }
end, { desc = "󰒕 Toggle LSP Lines" })
keymap("n", "gs", function() cmd.Telescope("treesitter") end, { desc = " Document Symbols" })

keymap({ "n", "x" }, "<leader>c", vim.lsp.buf.code_action, { desc = "󰒕 Code Action" })

-- copy breadcrumbs (nvim navic)
keymap("n", "<D-b>", function()
	local rawdata = require("nvim-navic").get_data()
	if not rawdata then
		vim.notify("No Breadcrumbs available", u.warn)
		return
	end
	local breadcrumbs = ""
	for _, v in pairs(rawdata) do
		breadcrumbs = breadcrumbs .. v.name .. "."
	end
	breadcrumbs = breadcrumbs:sub(1, -2)
	fn.setreg("+", breadcrumbs)
	vim.notify("COPIED\n" .. breadcrumbs)
end, { desc = "󰒕 Copy Breadcrumbs" })

-- Save & Format
keymap({ "n", "i", "x" }, "<D-s>", function()
	cmd.update()
	vim.lsp.buf.format()
end, { desc = "󰒕  Save & Format" })

keymap("n", "<leader>h", vim.lsp.buf.hover, { desc = "󰒕 Hover" })

-- uses "v" instead of "x", so signature can be shown during snippet completion
keymap({ "n", "i", "v" }, "<C-s>", vim.lsp.buf.signature_help, { desc = "󰒕 Signature" })

keymap("n", "gd", function() cmd.Glance("definitions") end, { desc = "󰒕 Definitions" })
keymap("n", "gf", function() cmd.Glance("references") end, { desc = "󰒕 References" })
keymap("n", "gD", function() cmd.Glance("type_definitions") end, { desc = "󰒕 Type Definition" })

autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local capabilities = client.server_capabilities

		-- overrides treesitter-refactor's rename
		if capabilities.renameProvider then
			-- cannot run `cmd.IncRename` since the plugin *has* to use the
			-- command line; needs defer to not be overwritten by treesitter-
			-- refactor's smart-rename
			-- stylua: ignore
			vim.defer_fn( function() keymap("n", "<leader>v", ":IncRename ", { desc = "󰒕 IncRename", buffer = true }) end, 1)
			-- stylua: ignore
			keymap("n", "<leader>V", function() return ":IncRename " .. expand("<cword>") end, { desc = "󰒕 IncRename cword", buffer = true, expr = true })
		end
		if capabilities.documentSymbolProvider then
			-- overwrites treesitter goto-symbol
			-- stylua: ignore start
			keymap("n", "gs", function() cmd.Telescope("lsp_document_symbols") end, { desc = "󰒕 Symbols", buffer = true })
			keymap("n", "gS", function() cmd.Telescope("lsp_workspace_symbols") end, { desc = "󰒕 Workspace Symbols", buffer = true })
			-- stylua: ignore end
		end
	end,
})

--------------------------------------------------------------------------------
-- GIT

-- Neogit
keymap("n", "<leader>gn", cmd.Neogit, { desc = "󰊢 Neogit Menu" })
keymap("n", "<leader>gc", ":Neogit commit<CR>", { desc = "󰊢 Commit (Neogit)" })

-- Gitsigns
keymap("n", "<leader>ga", ":Gitsigns stage_hunk<CR>", { desc = "󰊢 Add Hunk" })
keymap("n", "<leader>gA", ":Gitsigns stage_buffer<CR>", { desc = "󰊢 Add Buffer" })
keymap("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = "󰊢 Reset Hunk" })
keymap("n", "<leader>g?", ":Gitsigns blame_line<CR>", { desc = "󰊢 Blame Line" })

-- Telescope
-- stylua: ignore start
keymap("n", "<leader>gs", function() cmd.Telescope("git_status") end, { desc = "󰊢  Status" })
keymap("n", "<leader>gl", function() cmd.Telescope("git_commits") end, { desc = "󰊢  Log / Commits" })
keymap("n", "<leader>gL", function() cmd.Telescope("git_bcommits") end, { desc = "󰊢  Buffer Commits" })
keymap("n", "<leader>gb", function() cmd.Telescope("git_branches") end, { desc = "󰊢  Branches Commits" })

-- My utils
keymap({ "n", "x" }, "<leader>gu", function () require("funcs.git-utils").githubUrl() end, { desc = "󰊢 GitHub Link" })
keymap("n", "<leader>gg", function() require("funcs.git-utils").addCommitPush() end, { desc = "󰊢 Add-Commit-Push" })
keymap("n", "<leader>gi", function() require("funcs.git-utils").issueSearch("open") end, { desc = "󰊢 Open Issues" })
keymap("n", "<leader>gI", function() require("funcs.git-utils").issueSearch("closed") end, { desc = "󰊢 Closed Issues" })
keymap("n", "<leader>gm", function() require("funcs.git-utils").amendNoEditPushForce() end, { desc = "󰊢 Amend-No-Edit & Force Push" })
keymap("n", "<leader>gM", function() require("funcs.git-utils").amendAndPushForce() end, { desc = "󰊢 Amend & Force Push" })
-- stylua: ignore end

-- Diffview
keymap("n", "<leader>gd", function()
	vim.ui.input({ prompt = "󰢷 Git Pickaxe (empty = full history)" }, function(query)
		if not query then return end
		if query ~= "" then query = (" -G'%s'"):format(query) end
		cmd("DiffviewFileHistory %" .. query)
		cmd.wincmd("w") -- go directly to file window
		cmd.wincmd("|") -- maximize it
	end)
end, { desc = "󰊢 File History (Diffview)" })
keymap(
	"x",
	"<leader>gd",
	":DiffviewFileHistory<CR><C-w>w<C-w>|",
	{ desc = "󰊢 Line History (Diffview)" }
)

--------------------------------------------------------------------------------
-- OPTION TOGGLING

keymap(
	"n",
	"<leader>or",
	"<cmd>set relativenumber!<CR>",
	{ desc = "  Toggle Relative Line Numbers" }
)
keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Toggle Line Numbers" })
keymap("n", "<leader>ol", cmd.LspRestart, { desc = " 󰒕 LSP Restart" })

keymap("n", "<leader>od", function()
	if vim.diagnostic.is_disabled(0) then
		vim.diagnostic.enable(0)
	else
		vim.diagnostic.disable(0)
	end
end, { desc = "  Toggle Diagnostics" })

keymap("n", "<leader>ow", function()
	local wrapOn = vim.opt_local.wrap:get()
	if wrapOn then
		vim.opt_local.wrap = false
		vim.opt_local.colorcolumn = vim.opt.colorcolumn:get()
		vim.keymap.del({ "n", "x" }, "H", { buffer = true })
		vim.keymap.del({ "n", "x" }, "L", { buffer = true })
		vim.keymap.del({ "n", "x" }, "J", { buffer = true })
		vim.keymap.del({ "n", "x" }, "K", { buffer = true })
		vim.keymap.del({ "n", "x" }, "k", { buffer = true })
		vim.keymap.del({ "n", "x" }, "j", { buffer = true })
		vim.keymap.del({ "n", "x" }, "A", { buffer = true })
		vim.keymap.del({ "n", "x" }, "I", { buffer = true })
	else
		vim.opt_local.wrap = true
		vim.opt_local.colorcolumn = ""
		keymap({ "n", "x" }, "H", "g^", { buffer = true })
		keymap({ "n", "x" }, "L", "g$", { buffer = true })
		keymap({ "n", "x" }, "J", "6gj", { buffer = true })
		keymap({ "n", "x" }, "K", "6gk", { buffer = true })
		keymap({ "n", "x" }, "j", "gj", { buffer = true })
		keymap({ "n", "x" }, "k", "gk", { buffer = true })
		keymap({ "n", "x" }, "A", "g$a", { buffer = true })
		keymap({ "n", "x" }, "I", "g^i", { buffer = true })
	end
end, { desc = " 󰖶 Toggle Wrap" })

--------------------------------------------------------------------------------

-- TERMINAL & CODE RUNNER
keymap("t", "<S-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste in Terminal Mode" })

keymap("n", "<leader>tf", "<Plug>PlenaryTestFile", { desc = " Test File" })
keymap("n", "<leader>td", "<cmd>PlenaryBustedDirectory .<CR>", { desc = " Tests in Directory" })

keymap("n", "<leader>th", function()
	cmd.edit("request.http")
	fn.system("open https://github.com/rest-nvim/rest.nvim/tree/main/tests")
end, { desc = "󰴚 Test HTTP request" })

keymap("n", "<leader>tt", cmd.ToggleTerm, { desc = " ToggleTerm" })
-- stylua: ignore
keymap("x", "<leader>tt", cmd.ToggleTermSendVisualSelection, { desc = "  Run Selection in ToggleTerm" })

keymap("n", "<leader>tc", function()
	local isCodiBuffer = bo.buftype == "nofile"
	if isCodiBuffer then
		cmd.CodiExpand() -- multiline output for the current line
	else
		cmd.CodiNew()
		vim.api.nvim_buf_set_name(0, "Codi: " .. bo.filetype)
	end
end, { desc = " Codi" })

-- edit embedded filetype
keymap("n", "<leader>te", function()
	if bo.filetype ~= "markdown" then
		vim.notify("Only markdown codeblocks can be edited without a selection.")
		return
	end
	cmd.EditCodeBlock()
end, { desc = " Edit Embedded Code (Code Block)" })

keymap("x", "<leader>te", function()
	local fts = { "bash", "applescript", "vim" }
	vim.ui.select(fts, { prompt = "Filetype:", kind = "simple" }, function(ft)
		if not ft then return end
		u.leaveVisualMode()
		cmd("'<,'>EditCodeBlockSelection " .. ft)
	end)
end, { desc = " Edit Embedded Code (Selection)" })

--------------------------------------------------------------------------------

-- q / Esc to close special windows
autocmd("FileType", {
	pattern = {
		"help",
		"lspinfo",
		"tsplayground",
		"PlenaryTestPopup",
		"qf", -- quickfix
		"lazy",
		"httpResult", -- rest.nvim
		"AppleScriptRunOutput",
		"DressingSelect", -- done here and not as dressing keybinding to be able to set `nowait`
		"DressingInput",
		"man",
		"neoai-input",
		"neoai-output",
	},
	callback = function()
		local opts = { buffer = true, nowait = true, desc = "close" }
		keymap("n", "<Esc>", cmd.close, opts)
		keymap("n", "q", cmd.close, opts)
	end,
})

-- just "q" to close special window
-- remove the waiting time from the q, due to conflict with `qq` for comments
autocmd("FileType", {
	pattern = { "ssr", "TelescopePrompt", "harpoon" },
	callback = function()
		local opts = { buffer = true, nowait = true, remap = true, desc = "close" }
		if bo.filetype == "ssr" then
			keymap("n", "q", "Q", opts)
		else
			-- HACK 1ms delay ensures it comes later in the autocmd stack and takes effect
			vim.defer_fn(function() keymap("n", "q", "<Esc>", opts) end, 1)
		end
	end,
})

--------------------------------------------------------------------------------
