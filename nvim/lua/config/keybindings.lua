local keymap = require("config.utils").uniqueKeymap

---META-------------------------------------------------------------------------
-- save before quitting (non-unique, since also set by Neovide)
keymap("n", "<D-q>", vim.cmd.wqall, { desc = " Save & quit", unique = false })

keymap(
	{ "n", "x", "i" },
	"<D-C-r>", -- `hyper` gets registered by Neovide as `cmd+ctrl` (`<D-C-`)
	function() require("personal-plugins.misc").restartNeovide() end,
	{ desc = " Save & restart" }
)

keymap(
	{ "n", "x", "i" },
	"<D-C-t>", -- `hyper` gets registered by Neovide as `cmd+ctrl` (`<D-C-`)
	function() require("personal-plugins.misc").openCwdInTerminal() end,
	{ desc = " Open cwd in Terminal" }
)

-- stylua: ignore
keymap("n", "<leader>pd", function() vim.ui.open(vim.fn.stdpath("data") --[[@as string]]) end, { desc = "󰝰 Local data dir" })

keymap("n", "<D-,>", function()
	local pathOfThisLuaFile = debug.getinfo(1, "S").source:gsub("^@", "")
	vim.cmd.edit(pathOfThisLuaFile)
end, { desc = "󰌌 Edit keybindings" })

---NAVIGATION-------------------------------------------------------------------
-- make mappings work on wrapped lines as well
keymap({ "n", "x" }, "j", "gj")
keymap({ "n", "x" }, "k", "gk")

-- make HJKL behave like hjkl but with bigger distance
keymap({ "n", "x" }, "J", "6gj")
keymap({ "n", "x" }, "K", "6gk")

-- Jump history
keymap("n", "<C-h>", "<C-o>", { desc = "󱋿 Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "󱋿 Jump forward", unique = false })

-- Search
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = " Search within selection" })

-- Diagnostics
keymap("n", "ge", "]d", { desc = "󰋽 Next diagnostic", remap = true })
keymap("n", "gE", "[d", { desc = "󰋽 Previous diagnostic", remap = true })

-- [g]oto [m]atching parenthesis (`remap` needed to use builtin `MatchIt` plugin)
keymap("n", "gm", "%", { desc = "󰅪 Goto match", remap = true })

-- Open URL in file
keymap("n", "<D-U>", function()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	for _, line in ipairs(lines) do
		local url = line:match("%l+://[^%s%)%]}\"'`>]+")
		if url then return vim.ui.open(url) end
	end
	vim.notify("No URL found in file.", vim.log.levels.WARN)
end, { desc = " Open URL in buffer" })

---MARKS------------------------------------------------------------------------
do
	local marks = require("personal-plugins.marks")

	marks.loadSigns()
	if vim.g.whichkeyAddSpec then vim.g.whichkeyAddSpec { "<leader>m", group = "󰃀 Marks" } end

	keymap("n", "<leader>mm", marks.cycleMarks, { desc = "󰃀 Cycle marks" })
	keymap("n", "<leader>ma", marks.setUnsetA, { desc = "󰃅 Set A" })
	keymap("n", "<leader>mb", marks.setUnsetB, { desc = "󰃅 Set B" })
end

---EDITING----------------------------------------------------------------------

-- Undo
keymap("n", "u", "<cmd>silent undo<CR>zv", { desc = "󰜊 Silent undo" })
keymap("n", "U", "<cmd>silent redo<CR>zv", { desc = "󰛒 Silent redo" })
keymap("n", "<leader>uu", ":earlier ", { desc = "󰜊 Undo to earlier" })
-- stylua: ignore
keymap("n", "<leader>ur", function() vim.cmd.later(vim.o.undolevels) end, { desc = "󰛒 Redo all" })

-- Duplicate
-- stylua: ignore
keymap("n", "ww", function() require("personal-plugins.misc").smartDuplicate() end, { desc = "󰲢 Duplicate line" })

-- stylua: ignore
keymap("n", "<", function() require("personal-plugins.misc").toggleTitleCase() end, { desc = "󰬴 Toggle lower/Title case" })
keymap("n", ">", "gUiw", { desc = "󰬴 Uppercase cword" })

-- Toggles
-- stylua: ignore
keymap("n", "+", function() require("personal-plugins.misc").toggleOrIncrement() end, { desc = "󰐖 Increment/toggle" })
keymap("n", "ü", "<C-x>", { desc = "󰍵 Decrement" })
keymap("n", "~", "v~", { desc = "󰬴 Toggle char case (w/o moving)" })

keymap("n", "X", function()
	local updatedLine = vim.api.nvim_get_current_line():sub(1, -2)
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = "󱎘 Delete char at EoL" })

-- Append to EoL: `<leader>` + `char`
local trailChars = { ",", ")", ";", ".", '"', "'", " \\", " {", "?" }
for _, chars in pairs(trailChars) do
	keymap("n", "<leader>" .. vim.trim(chars), function()
		local updatedLine = vim.api.nvim_get_current_line() .. chars
		vim.api.nvim_set_current_line(updatedLine)
	end)
end

-- Spelling
keymap("n", "z.", "1z=", { desc = "󰓆 Fix spelling" }) -- works even with `spell=false`
keymap("n", "zl", function()
	local suggestions = vim.fn.spellsuggest(vim.fn.expand("<cword>"))
	suggestions = vim.list_slice(suggestions, 1, 9)
	vim.ui.select(suggestions, { prompt = "󰓆 Spelling suggestions" }, function(selection)
		if not selection then return end
		vim.cmd.normal { '"_ciw' .. selection, bang = true }
	end)
end, { desc = "󰓆 Spell suggestions" })

-- Template strings
-- stylua: ignore
keymap("i", "<D-t>", function() require("personal-plugins.auto-template-str").insertTemplateStr() end, { desc = "󰅳 Insert template string" })

-- Edits repeatable via `.`
keymap("n", "<D-j>", '*N"_cgn', { desc = "󰆿 Repeatable edit (cword)" })
keymap("x", "<D-j>", function()
	assert(vim.fn.mode() == "v", "Only visual (character) mode.")
	local selection = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
	vim.fn.setreg("/", "\\V" .. vim.fn.escape(selection, [[/\]]))
	return '<Esc>"_cgn'
end, { desc = "󰆿 Repeatable edit (selection)", expr = true })

-- Merge lines
keymap("n", "m", "J", { desc = "󰽜 Merge line up" })
keymap("n", "M", "<cmd>. move +1<CR>kJ", { desc = "󰽜 Merge line down" }) -- `:move` preserves marks

-- Markdown inline comments (useful to have in all filetypes for comments)
-- stylua: ignore start
keymap({ "n", "x", "i" }, "<D-e>", function() require("personal-plugins.md-qol").wrap("`") end, { desc = " Inline code" })

-- Simple surrounds
-- keymap("n", '"', function() require("personal-plugins.md-qol").wrap('"') end, { desc = " Surround" })
keymap("n", "'", function() require("personal-plugins.md-qol").wrap("'") end, { desc = " Surround" })
keymap("n", "(", function() require("personal-plugins.md-qol").wrap("(", ")") end, { desc = "󰅲 Surround" })
keymap("n", "[", function() require("personal-plugins.md-qol").wrap("[", "]") end, { nowait = true, desc = "󰅪 Surround" })
keymap("n", "{", function() require("personal-plugins.md-qol").wrap("{", "}") end, { desc = " Surround" })
-- stylua: ignore end

---AI REWRITE-------------------------------------------------------------------
do
	if vim.g.whichkeyAddSpec then vim.g.whichkeyAddSpec { "<leader>a", group = "󰚩 AI" } end
	-- stylua: ignore start
	keymap({ "n", "x" }, "<leader>aa", function() require("personal-plugins.ai-rewrite").task() end, { desc = "󰘎 Prompt" })
	keymap({ "n", "x" }, "<leader>as", function() require("personal-plugins.ai-rewrite").task("simplify") end, { desc = "󰚩 Simplify" })
	keymap({ "n", "x" }, "<leader>af", function() require("personal-plugins.ai-rewrite").task("fix") end, { desc = "󰚩 Fix" })
	keymap({ "n", "x" }, "<leader>ac", function() require("personal-plugins.ai-rewrite").task("complete") end, { desc = "󰚩 Complete" })
	-- stylua: ignore end
end

---WHITESPACE & INDENTATION-----------------------------------------------------
keymap("n", "=", "[<Space>", { desc = " Blank above", remap = true }) -- remap, since nvim default
keymap("n", "_", "]<Space>", { desc = " Blank below", remap = true })

keymap("n", "<Tab>", ">>", { desc = "󰉶 indent" })
keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent" })
keymap("i", "<Tab>", "<C-t>", { desc = "󰉶 indent", unique = false })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent" })
keymap("i", "<S-Tab>", "<C-d>", { desc = "󰉵 outdent", unique = false })

---QUICKFIX---------------------------------------------------------------------
keymap("n", "gq", "<cmd>silent cnext<CR>zv", { desc = "󰴩 Next quickfix" })
keymap("n", "gQ", "<cmd>silent cprev<CR>zv", { desc = "󰴩 Prev quickfix" })
keymap("n", "<leader>qr", function() vim.cmd.cexpr("[]") end, { desc = "󰚃 Remove qf items" })
keymap("n", "<leader>q1", "<cmd>silent cfirst<CR>zv", { desc = "󰴩 Goto 1st quickfix" })
keymap("n", "<leader>qq", function()
	local quickfixWinOpen = vim.fn.getqflist({ winid = true }).winid ~= 0
	vim.cmd(quickfixWinOpen and "cclose" or "copen")
end, { desc = " Toggle quickfix window" })

---FOLDING----------------------------------------------------------------------
keymap("n", "zz", "<cmd>%foldclose<CR>", { desc = " Close toplevel folds" })
keymap("n", "zm", "zM", { desc = " Close all folds" })
keymap("n", "zv", "zv", { desc = "󰘖 Open until cursor visible" }) -- just for which-key
keymap("n", "zr", "zR", { desc = "󰘖 Open all folds" })
-- stylua: ignore
keymap("n", "zf", function() vim.opt.foldlevel = vim.v.count1 end, { desc = " Set fold level to {count}" })

---YANKING----------------------------------------------------------------------

do -- STICKY YANK
	keymap({ "n", "x" }, "y", function()
		vim.b.preYankCursor = vim.api.nvim_win_get_cursor(0)
		return "y"
	end, { expr = true })
	keymap("n", "Y", function()
		vim.b.preYankCursor = vim.api.nvim_win_get_cursor(0)
		return "y$"
	end, { expr = true, unique = false }) -- non-unique, since nvim default

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "User: Sticky yank",
		callback = function()
			if vim.v.event.operator == "y" and vim.b.preYankCursor then
				vim.api.nvim_win_set_cursor(0, vim.b.preYankCursor)
				vim.b.preYankCursor = nil
			end
		end,
	})
end

do -- YANKRING
	-- When undoing the paste and then using `.`, will paste `"2p`, so `<D-p>...`
	-- pastes all recent things and `<D-p>u.u.u.u.`, cycles through them
	keymap("n", "<D-p>", '"1p', { desc = " Paste from yankring" })

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "User: Yankring",
		callback = function()
			if vim.v.event.operator ~= "y" then return end
			for i = 9, 1, -1 do -- shift all numbered registers
				vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
			end
		end,
	})
end

-- keep the register clean
keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P")
keymap("n", "dd", function() -- `dd` should not put empty lines into the register
	local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
	return (lineEmpty and '"_dd' or "dd")
end, { expr = true })

---PASTING----------------------------------------------------------------------
keymap("n", "P", function()
	local reg = "+"
	require("personal-plugins.md-qol").addTitleToUrlIfMarkdown(reg)
	local curLine = vim.api.nvim_get_current_line():gsub("%s*$", "")
	local clipb = vim.trim(vim.fn.getreg(reg))
	vim.api.nvim_set_current_line(curLine .. " " .. clipb)
end, { desc = " Paste at EoL" })

-- insert mode paste
-- 1. trim if register
-- 2. add undopoint before the paste
-- 3. skip auto-indent
keymap("i", "<D-v>", function()
	local reg = "+"
	vim.fn.setreg(reg, vim.trim(vim.fn.getreg(reg))) -- trim
	if vim.fn.mode() == "R" then return "<C-r>" .. reg end
	require("personal-plugins.md-qol").addTitleToUrlIfMarkdown(reg)
	return "<C-g>u<C-r><C-o>" .. reg -- `<C-g>u` adds undopoint before, `<C-r><C-o>` skips auto-indent
end, { desc = " Paste", expr = true })

-- compatibility w/ macOS clipboard managers; remap to inherit changes to `p`
keymap("n", "<D-v>", "p", { desc = " Paste", remap = true })

---TEXTOBJECTS------------------------------------------------------------------
local textobjRemaps = {
	{ "c", "}", "", "curly" }, -------- [c]urly brace
	{ "r", "]", "󰅪", "rectangular" }, -- [r]ectangular bracket
	{ "m", "W", "󰬞", "WORD" }, --------- [m]assive word
	{ "q", '"', "", "double" }, ------- [q]uote
	{ "z", "'", "", "single" }, ------- [z]ingle quote
	{ "e", "`", "", "backtick" }, ----- t[e]mplate string / inline cod[e]
}
for _, value in pairs(textobjRemaps) do
	local remap, original, icon, label = unpack(value)
	keymap({ "o", "x" }, "i" .. remap, "i" .. original, { desc = icon .. " inner " .. label })
	keymap({ "o", "x" }, "a" .. remap, "a" .. original, { desc = icon .. " outer " .. label })
end

keymap("o", "J", "2j") -- `dd` = 1 line, `dj` = 2 lines, `dJ` = 3 lines
keymap("n", "<Space>", '"_ciw', { desc = "󰬞 Change word" })
keymap("x", "<Space>", '"_c', { desc = "󰒅 Change selection" })
keymap("n", "<S-Space>", '"_daw', { desc = "󰬞 Delete word" })

---COMMENTS---------------------------------------------------------------------
-- requires `remap` or method from: https://www.reddit.com/r/neovim/comments/1ctc1zd/comment/l4c29rx/
keymap({ "n", "x" }, "q", "gc", { desc = "󰆈 Comment operator", remap = true })
keymap("n", "qq", "gcc", { desc = "󰆈 Comment line", remap = true })
do
	keymap("o", "u", "gc", { desc = "󰆈 Multiline comment", remap = true })
	keymap("n", "guu", "guu") -- prevent previous keymap from overwriting `guu` (lowercase line)
end

do
	local com = require("personal-plugins.comment")
	keymap("n", "qw", com.commentHr, { desc = "󰆈 Divider" })
	keymap("n", "qr", function() com.commentHr("replaceMode") end, { desc = "󰆈 Divider + label" })
	keymap("n", "wq", com.duplicateLineAsComment, { desc = "󰆈 Duplicate line as comment" })
	keymap("n", "Q", function() com.addComment("eol") end, { desc = "󰆈 Add comment at EoL" })
	keymap("n", "qO", function() com.addComment("above") end, { desc = "󰆈 Add comment above" })
	keymap("n", "qo", function() com.addComment("below") end, { desc = "󰆈 Add comment below" })
	com.setupReplaceModeHelpersForComments()
end

---LINE & CHARACTER MOVEMENT----------------------------------------------------
keymap("n", "<Down>", "<cmd>. move +1<CR>==", { desc = "󰜮 Move line down" })
keymap("n", "<Up>", "<cmd>. move -2<CR>==", { desc = "󰜷 Move line up" })
keymap("n", "<Right>", [["zx"zp]], { desc = "➡️ Move char right" })
keymap("n", "<Left>", [["zdh"zph]], { desc = "⬅ Move char left" })
keymap("x", "<Down>", [[:move '>+1<CR>gv=gv]], { desc = "󰜮 Move selection down", silent = true })
keymap("x", "<Up>", [[:move '<-2<CR>gv=gv]], { desc = "󰜷 Move selection up", silent = true })
keymap("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move selection right" })
keymap("x", "<left>", [["zxhh"zpgvhoho]], { desc = "⬅ Move selection left" })

---LSP--------------------------------------------------------------------------
keymap({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "󱐋 Code action" })

-- stylua: ignore start
keymap({ "n", "x" }, "<leader>h", function() vim.lsp.buf.hover { max_width = 80 } end, { desc = "󰋽 LSP hover" })

keymap("n", "<PageDown>", function() require("personal-plugins.misc").scrollLspOrOtherWin(5) end, { desc = "↓ Scroll other win" })
keymap("n", "<PageUp>", function() require("personal-plugins.misc").scrollLspOrOtherWin(-5) end, { desc = "↑ Scroll other win" })
-- stylua: ignore end

---VARIOUS MODES----------------------------------------------------------------

-- insert mode
keymap("n", "i", function()
	local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
	return lineEmpty and '"_cc' or "i"
end, { expr = true, desc = "indented i on empty line" })

-- visual mode
keymap("x", "V", "j", { desc = "repeated `V` selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` starts visual block" })

-- terminal mode
keymap("t", "<C-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = " Esc" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste" })

-- cmdline mode
keymap("c", "<D-v>", function()
	vim.fn.setreg("+", vim.trim(vim.fn.getreg("+")))
	return "<C-r>+"
end, { expr = true, desc = " Paste" })

keymap("c", "<D-c>", function()
	local cmdline = vim.fn.getcmdline()
	if cmdline == "" then return vim.notify("Nothing to copy.", vim.log.levels.WARN) end
	vim.fn.setreg("+", cmdline)
	vim.notify(cmdline, nil, { title = "Copied", icon = "󰅍" })
end, { desc = "󰅍 Yank cmdline" })

keymap("c", "<BS>", function()
	if vim.fn.getcmdline() ~= "" then return "<BS>" end
end, { expr = true, desc = "<BS> does not leave cmdline" })

keymap("c", "<C-a>", "<C-b>", { desc = "Goto start of cmdline" })
keymap("c", "<D-Left>", "<C-b>", { desc = "Goto start of cmdline" })
keymap("c", "<D-Right>", "<C-e>", { desc = "Goto end of cmdline" })

---INSPECT & EVAL---------------------------------------------------------------
keymap("n", "<leader>ii", vim.cmd.Inspect, { desc = "󱈄 Inspect at cursor" })
keymap("n", "<leader>it", vim.cmd.InspectTree, { desc = " TS syntax tree" })
keymap("n", "<leader>iT", "<cmd>checkhealth nvim-treesitter<CR>", { desc = " TS Parsers" })

-- stylua: ignore start
keymap("n", "<leader>ia", function() require("personal-plugins.misc").inspectNodeAncestors() end, { desc = " Node ancestors" })
keymap("n", "<leader>iL", function() vim.cmd.edit(vim.lsp.log.get_filename()) end, { desc = "󱂅 LSP log" })
keymap("n", "<leader>ib", function() require("personal-plugins.misc").inspectBuffer() end, { desc = "󰽙 Buffer info" })
keymap({"n", "x"}, "<leader>i+", function() require("personal-plugins.misc").sumOfAllNumbersInBuf() end, { desc = "∑ Sum of numbers in buffer" })
-- stylua: ignore end

keymap("n", "<leader>id", function()
	local diag = vim.diagnostic.get_next()
	vim.notify(vim.inspect(diag), nil, { ft = "lua" })
end, { desc = "󰋽 Next diagnostic" })

keymap({ "n", "x" }, "<leader>ee", function()
	local selection = vim.fn.mode() == "n" and ""
		or vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
	return ":lua = " .. selection
end, { expr = true, desc = "󰢱 Eval lua expr" })

keymap("n", "<leader>ey", function()
	local cmd = vim.trim(vim.fn.getreg(":"))
	local lastExcmd = cmd:gsub("^lua ", ""):gsub("^= ?", "")
	if lastExcmd == "" then return vim.notify("Nothing to copy", vim.log.levels.TRACE) end
	local syntax = vim.startswith(cmd, "lua") and "lua" or "vim"
	vim.notify(lastExcmd, nil, { title = "Copied", icon = "󰅍", ft = syntax })
	vim.fn.setreg("+", lastExcmd)
end, { desc = " Yank last ex-cmd" })

---WINDOWS & SPLITS-------------------------------------------------------------
keymap({ "n", "v", "i" }, "<C-CR>", "<C-w>w", { desc = " Cycle windows" })
keymap({ "n", "x", "i" }, "<C-v>", "<cmd>vertical split #<CR>", { desc = " Split altfile" })
keymap({ "n", "x", "i" }, "<D-W>", vim.cmd.only, { desc = " Close other windows" })

keymap({ "n", "v", "i" }, "<C-Up>", "<C-w>3-")
keymap({ "n", "v", "i" }, "<C-Down>", "<C-w>3+")
keymap({ "n", "v", "i" }, "<C-Left>", "<C-w>5<")
keymap({ "n", "v", "i" }, "<C-Right>", "<C-w>5>")

---BUFFERS & FILES--------------------------------------------------------------

-- stylua: ignore start
keymap({ "n", "x" }, "<CR>", function() require("personal-plugins.magnet").gotoAltFile() end, { desc = "󰬈 Goto alt-file" })
keymap({ "n", "x" }, "<D-CR>", function() require("personal-plugins.magnet").gotoMostChangedFile() end, { desc = "󰊢 Goto most changed file" })
-- stylua: ignore end

keymap({ "n", "x", "i" }, "<D-w>", function()
	vim.cmd("silent! update")
	local winClosed = pcall(vim.cmd.close) -- fails on last window
	if winClosed then return end
	local bufCount = #vim.fn.getbufinfo { buflisted = 1 }
	if bufCount == 1 then return vim.notify("Only one buffer open.", vim.log.levels.TRACE) end
	vim.cmd.bdelete()
end, { desc = "󰽙 Close window/buffer" })

keymap("n", "<BS>", function()
	if vim.bo.buftype ~= "" then return end -- prevent accidental triggering in special buffers
	vim.cmd.bprevious()
end, { desc = "󰽙 Prev buffer" })
keymap("n", "<S-BS>", vim.cmd.bnext, { desc = "󰽙 Next buffer" })

-- stylua: ignore
keymap({ "n", "x", "i" }, "<D-L>", function() require("personal-plugins.misc").openWorkflowInAlfredPrefs() end, { desc = "󰮤 Reveal in Alfred" })

---MACROS-----------------------------------------------------------------------
do
	local reg = "r"
	local toggleKey = "0"

	vim.fn.setreg(reg, "") -- clear on startup to avoid accidents
	-- stylua: ignore
	keymap("n", toggleKey, function() require("personal-plugins.misc").startOrStopRecording(toggleKey, reg) end, { desc = "󰃽 Start/stop recording" })
	-- stylua: ignore
	keymap("n", "9", function() require("personal-plugins.misc").playRecording(reg) end, { desc = "󰃽 Play recording" })
end

---REFACTORING------------------------------------------------------------------
keymap("n", "<leader>rr", vim.lsp.buf.rename, { desc = "󰑕 LSP rename" })
keymap("n", "<leader>rq", function()
	local updatedLine = vim.api.nvim_get_current_line():gsub("[\"']", { ['"'] = "'", ["'"] = '"' })
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = " Switch quotes in line" })
-- stylua: ignore
keymap("n", "<leader>rc", function() require("personal-plugins.misc").camelSnakeLspRename() end, { desc = "󰑕 LSP rename: camel/snake" })

---OPTION TOGGLING--------------------------------------------------------------
keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Line numbers" })
keymap("n", "<leader>ow", "<cmd>set wrap!<CR>", { desc = "󰖶 Wrap" })
keymap("n", "<leader>od", function()
	local isEnabled = vim.diagnostic.is_enabled { bufnr = 0 }
	vim.diagnostic.enable(not isEnabled, { bufnr = 0 })
end, { desc = "󰋽 Diagnostics" })
-- stylua: ignore
keymap("n", "<leader>oc", function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0 end, { desc = "󰈉 Conceal" })

keymap("n", "<leader>ol", function()
	local clients = vim.lsp.get_clients { bufnr = 0 }
	local names = vim.tbl_map(function(client) return client.name end, clients)
	local list = "- " .. table.concat(names, "\n- ")
	vim.notify(list, nil, { title = "Restarting LSPs", icon = "󰑓" })
	vim.lsp.enable(names, false)
	vim.lsp.enable(names, true)
end, { desc = "󰑓 LSP Restart" })

--------------------------------------------------------------------------------
