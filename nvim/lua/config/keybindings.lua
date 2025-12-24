local keymap = require("config.utils").uniqueKeymap

---META-------------------------------------------------------------------------
-- save before quitting (non-unique, since also set by Neovide)
keymap("n", "<D-q>", vim.cmd.wqall, { desc = " Save & quit", unique = false })

keymap(
	{ "n", "x", "i" },
	"<D-C-r>", -- `hyper` gets registered by neovide as `cmd+ctrl` (`<D-C-`)
	function() require("personal-plugins.misc").restartNeovide() end,
	{ desc = " Save & restart" }
)

keymap(
	{ "n", "x", "i" },
	"<D-C-t>", -- `hyper` gets registered by neovide as `cmd+ctrl` (`<D-C-`)
	function() require("personal-plugins.misc").openCwdInTerminal() end,
	{ desc = " Open cwd in Terminal" }
)

-- stylua: ignore
keymap("n", "<leader>pd", function() vim.ui.open(vim.fn.stdpath("data") --[[@as string]]) end, { desc = "󰝰 Local data dir" })

keymap("n", "<D-,>", function()
	local pathOfThisFile = debug.getinfo(1, "S").source:gsub("^@", "")
	vim.cmd.edit(pathOfThisFile)
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
keymap("n", "ge", "]d", { desc = "󰋼 Next diagnostic", remap = true })
keymap("n", "gE", "[d", { desc = "󰋼 Previous diagnostic", remap = true })

-- Open URL in file
-- stylua: ignore
keymap("n", "<D-U>", function() require("personal-plugins.misc").openFirstUrlInBuffer() end, { desc = " Open URL in buffer" })

---MARKS------------------------------------------------------------------------
do
	local marks = require("personal-plugins.marks")
	marks.loadSigns()

	keymap("n", "gm", marks.cycleMarks, { desc = "󰃀 Cycle marks" })
	keymap("n", "<leader>m", marks.setUnsetMark, { desc = "󰃅 Set/unset marks" })
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
	local updatedLine = vim.api.nvim_get_current_line():gsub(".$", "")
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
keymap("n", "<D-j>", '*N"_cgn', { desc = "󰆿 Repeatable edit cword" })
keymap("x", "<D-j>", function()
	local selection = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
	vim.fn.setreg("/", "\\V" .. vim.fn.escape(selection, [[/\]]))
	return '<Esc>"_cgn'
end, { desc = "󰆿 Repeatable edit selection", expr = true })

-- Merge lines
keymap("n", "m", "J", { desc = "󰽜 Merge line up" })
keymap("n", "M", "<cmd>. move +1<CR>kJ", { desc = "󰽜 Merge line down" }) -- `:move` preserves marks

-- Markdown syntax (useful to have in all filetypes for comments)
-- stylua: ignore start
keymap({ "n", "x", "i" }, "<D-e>", function() require("personal-plugins.markdown-qol").wrap("`") end, { desc = " Inline code" })
keymap({ "n", "x", "i" }, "<D-k>", function() require("personal-plugins.markdown-qol").wrap("mdlink") end, { desc = " Link" })
keymap({ "n", "x", "i" }, "<D-b>", function() require("personal-plugins.markdown-qol").wrap("**") end, { desc = " Bold" })
keymap({ "n", "x", "i" }, "<D-i>", function() require("personal-plugins.markdown-qol").wrap("*") end, { desc = " Italic" })

-- Simple surrounds
keymap("n", '"', function() require("personal-plugins.markdown-qol").wrap('"') end, { desc = ' Surround' })
keymap("n", "(", function() require("personal-plugins.markdown-qol").wrap("(", ")") end, { desc = "󰅲 Surround" })
keymap("n", "[", function() require("personal-plugins.markdown-qol").wrap("[", "]") end, { nowait = true, desc = "󰅪 Surround" })
keymap("n", "{", function() require("personal-plugins.markdown-qol").wrap("{", "}") end, { desc = " Surround" })
-- stylua: ignore end

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
-- Sticky yank
do
	keymap({ "n", "x" }, "y", function()
		vim.b.cursorPreYank = vim.api.nvim_win_get_cursor(0)
		return "y"
	end, { expr = true })
	keymap("n", "Y", function()
		vim.b.cursorPreYank = vim.api.nvim_win_get_cursor(0)
		return "y$"
	end, { expr = true, unique = false }) -- non-unique, since nvim default

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "User: Sticky yank",
		callback = function()
			if vim.v.event.operator == "y" and vim.v.event.regname == "" and vim.b.cursorPreYank then
				vim.api.nvim_win_set_cursor(0, vim.b.cursorPreYank)
				vim.b.cursorPreYank = nil
			end
		end,
	})
end

-- Yankring
do
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
	local curLine = vim.api.nvim_get_current_line():gsub("%s*$", "")
	local reg = vim.trim(vim.fn.getreg("+"))
	vim.api.nvim_set_current_line(curLine .. " " .. reg)
end, { desc = " Paste at EoL" })

-- insert mode paste
-- 1. trim if register is charwise
-- 2. add undopoint before the paste
-- 3. skip auto-indent
keymap("i", "<D-v>", function()
	vim.fn.setreg("+", vim.trim(vim.fn.getreg("+"))) -- trim
	if vim.fn.mode() == "R" then return "<C-r>+" end
	return "<C-g>u<C-r><C-o>+" -- `<C-g>u` adds undopoint before, `<C-r><C-o>` skips auto-indent
end, { desc = " Paste", expr = true })

keymap("n", "<D-v>", "p", { desc = " Paste" }) -- compatibility w/ macOS clipboard managers

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

-- stylua: ignore start
keymap("n", "qw", function() require("personal-plugins.comment").commentHr() end, { desc = "󰆈 Horizontal divider" })
keymap("n", "qr", function() require("personal-plugins.comment").commentHr("replaceMode") end, { desc = "󰆈 Horizontal divider w/ label" })
keymap("n", "wq", function() require("personal-plugins.comment").duplicateLineAsComment() end, { desc = "󰆈 Duplicate line as comment" })
keymap("n", "qf", function() require("personal-plugins.comment").docstring() end, { desc = "󰆈 Function docstring" })
keymap("n", "Q", function() require("personal-plugins.comment").addComment("eol") end, { desc = "󰆈 Add comment at EoL" })
keymap("n", "qO", function() require("personal-plugins.comment").addComment("above") end, { desc = "󰆈 Add comment above" })
keymap("n", "qo", function() require("personal-plugins.comment").addComment("below") end, { desc = "󰆈 Add comment below" })
keymap("n", "gS", function() require("personal-plugins.comment").gotoCommentHeader() end, { desc = "󰆈 Goto comment header" })
require("personal-plugins.comment").setupReplaceModeHelpersForComments()
-- stylua: ignore end

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
keymap({ "n", "x" }, "<leader>h", function() vim.lsp.buf.hover { max_width = 70 } end, { desc = "󰋽 LSP hover" })

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
	vim.fn.setreg("+", vim.trim(vim.fn.getreg("+"))) -- trim
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

---INSPECT & EVAL---------------------------------------------------------------
keymap("n", "<leader>ii", vim.cmd.Inspect, { desc = "󱈄 Inspect at cursor" })
keymap("n", "<leader>it", vim.cmd.InspectTree, { desc = " TS syntax tree" })
keymap("n", "<leader>iT", "<cmd>checkhealth nvim-treesitter<CR>", { desc = " TS Parsers" })
keymap("n", "<leader>id", function()
	local diag = vim.diagnostic.get_next()
	vim.notify(vim.inspect(diag), nil, { ft = "lua" })
end, { desc = "󰋽 Next diagnostic" })

-- stylua: ignore start
keymap("n", "<leader>iL", function() vim.cmd.edit(vim.lsp.log.get_filename()) end, { desc = "󱂅 LSP log" })
-- stylua: ignore
keymap("n", "<leader>ib", function() require("personal-plugins.misc").inspectBuffer() end, { desc = "󰽙 Buffer info" })

keymap({ "n", "x" }, "<leader>ee", function()
	local selection = vim.fn.mode() == "n" and ""
		or vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))[1]
	return ":lua = " .. selection
end, { expr = true, desc = "󰢱 Eval lua expr" })

keymap("n", "<leader>ey", function()
	local cmd = vim.fn.getreg(":")
	local lastExcmd = cmd:gsub("^lua ", ""):gsub("^= ?", "")
	if lastExcmd == "" then return vim.notify("Nothing to copy", vim.log.levels.TRACE) end
	local syntax = vim.startswith(cmd, "lua") and "lua" or "vim"
	vim.notify(lastExcmd, nil, { title = "Copied", icon = "󰅍", ft = syntax })
	vim.fn.setreg("+", lastExcmd)
end, { desc = " Yank last ex-cmd" })

---WINDOWS & SPLITS-------------------------------------------------------------
keymap({ "n", "v", "i" }, "<C-CR>", "<C-w>w", { desc = " Cycle windows" })
keymap({ "n", "x" }, "<C-v>", "<cmd>vertical split #<CR>", { desc = " Split altfile" })
keymap({ "n", "x" }, "<D-W>", vim.cmd.only, { desc = " Close other windows" })

keymap("n", "<C-Up>", "<C-w>3-")
keymap("n", "<C-Down>", "<C-w>3+")
keymap("n", "<C-Left>", "<C-w>5<")
keymap("n", "<C-Right>", "<C-w>5>")

---BUFFERS & FILES--------------------------------------------------------------

-- stylua: ignore start
keymap({ "n", "x" }, "<CR>", function() require("personal-plugins.magnet").gotoAltFile() end, { desc = "󰬈 Goto alt-file" })
keymap({ "n", "x" }, "<D-CR>", function() require("personal-plugins.magnet").gotoMostChangedFile() end, { desc = "󰊢 Goto most changed file" })
-- stylua: ignore end

-- close window or buffer
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

keymap("n", "<leader>r<Tab>", function()
	vim.bo.expandtab = false
	vim.cmd.retab { bang = true }
	vim.notify("Now using tabs", nil, { title = ":retab", icon = "󰌒" })
end, { desc = "󰌒 Use tabs" })
keymap("n", "<leader>r<Space>", function()
	vim.bo.expandtab = true
	vim.bo.shiftwidth = 2
	vim.cmd.retab { bang = true }
	vim.notify("Now using spaces (2)", nil, { title = ":retab", icon = "󱁐" })
end, { desc = "󱁐 Use spaces" })

---OPTION TOGGLING--------------------------------------------------------------
keymap("n", "<leader>on", "<cmd>set number!<CR>", { desc = " Line numbers" })
keymap("n", "<leader>ow", "<cmd>set wrap!<CR>", { desc = "󰖶 Wrap" })
keymap("n", "<leader>od", function()
	local isEnabled = vim.diagnostic.is_enabled { bufnr = 0 }
	vim.diagnostic.enable(not isEnabled, { bufnr = 0 })
end, { desc = "󰋽 Diagnostics" })
-- stylua: ignore
keymap("n", "<leader>oc", function() vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0 end, { desc = "󰈉 Conceal" })

--------------------------------------------------------------------------------
