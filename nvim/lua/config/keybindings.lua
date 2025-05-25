local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------
-- META

keymap("n", "<D-,>", function()
	local pathOfThisFile = debug.getinfo(1, "S").source:sub(2)
	vim.cmd.edit(pathOfThisFile)
end, { desc = "󰌌 Edit keybindings" })

-- save before quitting (non-unique, since also set by Neovide)
keymap("n", "<D-q>", "ZZ", { desc = " Save & quit", unique = false })

-- stylua: ignore
keymap("n", "<leader>pd", function() vim.ui.open(vim.fn.stdpath("data") --[[@as string]]) end, { desc = "󰝰 Data dir" })
keymap("n", "<leader>ps", function() vim.ui.open(vim.g.icloudSync) end, { desc = "󰝰 Sync dir" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- make j/k on wrapped lines
keymap({ "n", "x" }, "j", "gj")
keymap({ "n", "x" }, "k", "gk")

-- HJKL behaves like hjkl, but bigger distance
-- (not mapping in op-pending, since using custom textobjects for those)
keymap({ "n", "x" }, "H", "0^", { desc = "󰲠 char" }) -- scroll fully to the left
keymap("o", "H", "^", { desc = "󰲠 char" })
keymap({ "n", "x" }, "L", "$", { desc = "󰬓 char" })
keymap({ "n", "x" }, "J", "6gj", { desc = "6j" })
keymap({ "n", "x" }, "K", "6gk", { desc = "6k" })

-- Jump history
keymap("n", "<C-h>", "<C-o>", { desc = "󱋿 Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "󱋿 Jump forward", unique = false })

-- Search
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = " Search IN selection" })

-- [g]oto [m]atching parenthesis (`remap` needed to use builtin `MatchIt` plugin)
keymap("n", "gm", "%", { desc = "󰅪 Goto match", remap = true })

-- Diagnostics
keymap("n", "ge", "]d", { desc = "󰋼 Next diagnostic", remap = true })
keymap("n", "gE", "[d", { desc = "󰋼 Previous diagnostic", remap = true })

--------------------------------------------------------------------------------
-- MARKS
do
	require("personal-plugins.marks").setup {
		marks = { "A", "B", "C", "D" },
		signs = {
			hlgroup = "StandingOut",
			icons = { A = "󰬈", B = "󰬉", C = "󰬊", D = "󰬋" },
		},
	}
	local leader = "<leader>m"

	if vim.g.whichkeyAddSpec then vim.g.whichkeyAddSpec { leader, group = "󰃃 Marks" } end

	-- stylua: ignore
	keymap("n", leader .. "m", function() require("personal-plugins.marks").cycleMarks() end, { desc = "󰃀 Cycle marks" })
	-- stylua: ignore
	keymap("n", leader .. "<BS>", function() require("personal-plugins.marks").deleteAllMarks() end, { desc = "󰃆 Delete marks" })

	for _, mark in pairs(require("personal-plugins.marks").config.marks) do
		-- stylua: ignore
		keymap("n", leader .. mark:lower(), function() require("personal-plugins.marks").setUnsetMark(mark) end, { desc = "󰃃 Set " .. mark })
	end
end

--------------------------------------------------------------------------------
-- EDITING

-- Undo
keymap("n", "u", "<cmd>silent undo<CR>zv", { desc = "󰜊 Silent undo" })
keymap("n", "U", "<cmd>silent redo<CR>zv", { desc = "󰛒 Silent redo" })
keymap("n", "<leader>uu", ":earlier ", { desc = "󰜊 Undo to earlier" })
-- stylua: ignore
keymap("n", "<leader>ur", function() vim.cmd.later(vim.o.undolevels) end, { desc = "󰛒 Redo all" })

-- Duplicate
-- stylua: ignore
keymap("n", "ww", function() require("personal-plugins.misc").smartDuplicate() end, { desc = "󰲢 Duplicate line" })

-- Toggles
keymap("n", "~", "v~", { desc = "󰬴 Toggle char case (w/o moving)" })
-- stylua: ignore
keymap("n", "<", function() require("personal-plugins.misc").toggleTitleCase() end, { desc = "󰬴 Toggle lower/Title case" })
keymap("n", ">", "gUiw", { desc = "󰬴 Uppercase cword" })

-- Increment/decrement, or toggle true/false
-- stylua: ignore
keymap({ "n", "x" }, "+", function() require("personal-plugins.misc").toggleOrIncrement() end, { desc = "󰐖 Increment/toggle" })
keymap({ "n", "x" }, "ü", "<C-x>", { desc = "󰍵 Decrement" })
-- Delete trailing character
keymap("n", "X", function()
	local updatedLine = vim.api.nvim_get_current_line():gsub("%S%s*$", "")
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = "󱎘 Delete char at EoL" })

-- Append to EoL: `<leader>` + `char`
local trailChars = { ",", ")", ";", ".", '"', " \\", " {", "?" }
for _, chars in pairs(trailChars) do
	keymap("n", "<leader>" .. vim.trim(chars), function()
		local updatedLine = vim.api.nvim_get_current_line() .. chars
		vim.api.nvim_set_current_line(updatedLine)
	end)
end

-- Spelling
keymap("n", "z.", "1z=", { desc = "󰓆 Fix spelling" }) -- works even with `spell=false`
-- stylua: ignore
keymap("n", "zl", function() require("personal-plugins.misc").spellSuggest() end, { desc = "󰓆 Spell suggestions" })

-- Merging
keymap("n", "m", "J", { desc = "󰽜 Merge line up" })
keymap("n", "M", "<cmd>. move +1<CR>kJ", { desc = "󰽜 Merge line down" }) -- using `:move` preserves marks

--------------------------------------------------------------------------------

-- WHITESPACE & INDENTATION
keymap("n", "=", "[<Space>", { desc = " Blank above", remap = true }) -- remap, since using nvim default
keymap("n", "_", "]<Space>", { desc = " Blank below", remap = true })

keymap("n", "<Tab>", ">>", { desc = "󰉶 indent" })
keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent" })
keymap("i", "<Tab>", "<C-t>", { desc = "󰉶 indent", unique = false })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent" })
keymap("i", "<S-Tab>", "<C-d>", { desc = "󰉵 outdent", unique = false })

--------------------------------------------------------------------------------
-- QUICKFIX
keymap("n", "gq", "<cmd>silent cnext<CR>zv", { desc = "󰴩 Next quickfix" })
keymap("n", "gQ", "<cmd>silent cprev<CR>zv", { desc = "󰴩 Prev quickfix" })
keymap("n", "<leader>qd", function() vim.cmd.cexpr("[]") end, { desc = "󰚃 Delete qf-list" })

--------------------------------------------------------------------------------
-- FOLDING
keymap("n", "zz", "<cmd>%foldclose<CR>", { desc = " Close toplevel folds" })
keymap("n", "zm", "zM", { desc = " Close all folds" })
keymap("n", "zv", "zv", { desc = "󰘖 Open until cursor visible" }) -- just for which-key
keymap("n", "zr", "zR", { desc = "󰘖 Open all folds" })
keymap("n", "zo", "zO", { desc = "󰘖 Open fold recursively" })
-- stylua: ignore
keymap("n", "zf", function() vim.opt.foldlevel = vim.v.count1 end, { desc = " Set fold level to {count}" })

keymap("n", "zs", function()
	local modeline = vim.bo.commentstring:format("vim foldlevel=" .. vim.o.foldlevel)
	vim.api.nvim_buf_set_lines(0, 0, 0, false, { modeline })
	vim.api.nvim_win_set_cursor(0, { 1, #modeline })
end, { desc = "󰆓 Save foldlevel in modeline" })

--------------------------------------------------------------------------------
-- SNIPPETS

-- exit snippet https://github.com/neovim/neovim/issues/26449#issuecomment-1845293096
keymap({ "i", "s" }, "<Esc>", function()
	vim.snippet.stop()
	return "<Esc>"
end, { desc = "󰩫 Exit snippet", expr = true })

--------------------------------------------------------------------------------
-- CLIPBOARD

-- Sticky yank
do
	keymap({ "n", "x" }, "y", function()
		vim.b.cursorPreYank = vim.api.nvim_win_get_cursor(0)
		Chainsaw(vim) -- 🪚
		return "y"
	end, { expr = true })
	keymap("n", "Y", function()
		vim.b.cursorPreYank = vim.api.nvim_win_get_cursor(0)
		return "y$"
	end, { expr = true, unique = false })

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

-- keep the register clean
keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P")
keymap("n", "dd", function()
	local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
	return (lineEmpty and '"_dd' or "dd")
end, { expr = true })

-- PASTING
keymap("n", "P", function()
	local curLine = vim.api.nvim_get_current_line():gsub("%s*$", "")
	local reg = vim.trim(vim.fn.getreg("+"))
	vim.api.nvim_set_current_line(curLine .. " " .. reg)
end, { desc = " Sticky paste at EoL" })

keymap("i", "<D-v>", function()
	local reg = vim.trim(vim.fn.getreg("+"))
	vim.fn.setreg("+", reg, "v") -- force charwise
	return "<C-g>u<C-r><C-o>+" -- `<C-g>u` adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

-- for compatibility with macOS clipboard managers
keymap("n", "<D-v>", "p", { desc = " Paste" })

--------------------------------------------------------------------------------
-- SURROUND

keymap("n", '"', 'bi"<Esc>ea"<Esc>', { desc = " Surround cword" })
keymap("n", "(", "bi(<Esc>ea)<Esc>", { desc = "󰅲 Surround cword" })
keymap("n", ")", "bi(<Esc>ea)<Esc>", { desc = "󰅲 Surround cword" })
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = " Inline code cword" })
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = " Inline code selection" })
keymap("i", "<D-e>", "``<Left>", { desc = " Inline code" })

--------------------------------------------------------------------------------
-- TEXTOBJECTS

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

--------------------------------------------------------------------------------
-- COMMENTS
-- requires `remap` or method from: https://www.reddit.com/r/neovim/comments/1ctc1zd/comment/l4c29rx/
keymap({ "n", "x" }, "q", "gc", { desc = "󰆈 Comment operator", remap = true })
keymap("n", "qq", "gcc", { desc = "󰆈 Comment line", remap = true })
do
	keymap("o", "u", "gc", { desc = "󰆈 Multiline comment", remap = true })
	keymap("n", "guu", "guu") -- prevent mapping above from overwriting `guu`
end

-- stylua: ignore start
keymap("n", "qw", function() require("personal-plugins.comment").commentHr() end, { desc = "󰆈 Horizontal divider" })
keymap("n", "wq", function() require("personal-plugins.comment").duplicateLineAsComment() end, { desc = "󰆈 Duplicate line as comment" })
keymap("n", "qf", function() require("personal-plugins.comment").docstring() end, { desc = "󰆈 Function docstring" })
keymap("n", "Q", function() require("personal-plugins.comment").addComment("eol") end, { desc = "󰆈 Append comment" })
keymap("n", "qo", function() require("personal-plugins.comment").addComment("below") end, { desc = "󰆈 Comment below" })
keymap("n", "qO", function() require("personal-plugins.comment").addComment("above") end, { desc = "󰆈 Comment above" })
-- stylua: ignore end

--------------------------------------------------------------------------------
-- LINE & CHARACTER MOVEMENT

keymap("n", "<Down>", [[<cmd>. move +1<CR>==]], { desc = "󰜮 Move line down" })
keymap("n", "<Up>", [[<cmd>. move -2<CR>==]], { desc = "󰜷 Move line up" })
keymap("n", "<Right>", [["zx"zp]], { desc = "➡️ Move char right" })
keymap("n", "<Left>", [["zdh"zph]], { desc = "⬅ Move char left" })
keymap("x", "<Up>", [[:move '<-2<CR>gv=gv]], { desc = "󰜷 Move selection up", silent = true })
keymap("x", "<Down>", [[:move '>+1<CR>gv=gv]], { desc = "󰜮 Move selection down", silent = true })
keymap("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move selection right" })
keymap("x", "<left>", [["zxhh"zpgvhoho]], { desc = "⬅ Move selection left" })

--------------------------------------------------------------------------------

-- LSP
keymap({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "󱐋 Code action" })
-- stylua: ignore start
keymap({ "n", "x" }, "<D-s>", function() require("personal-plugins.misc").formatWithFallback() end, { desc = "󱉯 Save & Format" })
keymap({ "n", "i", "v" }, "<D-g>", function() vim.lsp.buf.signature_help { max_width = 70 } end, { desc = "󰏪 LSP signature" })
keymap({ "n", "x" }, "<leader>h", function() vim.lsp.buf.hover { max_width = 70 } end, { desc = "󰋽 LSP hover" })
-- stylua: ignore end

do
	local function scrollLspWin(lines)
		local winid = vim.b.lsp_floating_preview --> stores id of last `vim.lsp`-generated win
		if not winid or not vim.api.nvim_win_is_valid(winid) then
			vim.notify("No LSP window found.", vim.log.levels.TRACE, { icon = "" })
			return
		end
		vim.api.nvim_win_call(winid, function()
			local topline = vim.fn.winsaveview().topline
			vim.fn.winrestview { topline = topline + lines }
		end)
	end
	keymap("n", "<PageDown>", function() scrollLspWin(5) end, { desc = "↓ Scroll LSP win" })
	keymap("n", "<PageUp>", function() scrollLspWin(-5) end, { desc = "↑ Scroll LSP win" })
end

--------------------------------------------------------------------------------

-- Open first URL in file
keymap("n", "<D-U>", function()
	local bufLines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	for _, line in pairs(bufLines) do
		local url = line:match([[%l%l%l+://[^%s)%]}"'`>]+]])
		if url then
			vim.ui.open(url)
			return
		end
	end
	vim.notify("No URL found in file.", vim.log.levels.WARN)
end, { desc = " Open first URL in file" })

--------------------------------------------------------------------------------

-- INSERT MODE
keymap("n", "i", function()
	local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
	return lineEmpty and '"_cc' or "i"
end, { expr = true, desc = "indented i on empty line" })

-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated `V` selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` starts visual block" })

-- TERMINAL MODE
keymap("t", "<C-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = " Esc" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste" })

-- COMMAND MODE
keymap("c", "<D-v>", "<C-r>+", { desc = " Paste" })
keymap("c", "<BS>", function()
	if vim.fn.getcmdline() ~= "" then return "<BS>" end
end, { expr = true, desc = "<BS> does not leave cmdline" })

--------------------------------------------------------------------------------
-- INSPECT & EVAL

keymap("n", "<leader>ii", vim.cmd.Inspect, { desc = "󱈄 :Inspect" })
keymap("n", "<leader>it", vim.cmd.InspectTree, { desc = " :InspectTree" })
keymap("n", "<leader>iq", vim.cmd.EditQuery, { desc = " :EditQuery" })

-- stylua: ignore
keymap("n", "<leader>il", function() require("personal-plugins.misc").lspCapabilities() end, { desc = "󱈄 LSP capabilities" })
-- stylua: ignore
keymap("n", "<leader>ib", function() require("personal-plugins.misc").bufferInfo() end, { desc = "󰽙 Buffer info" })

--------------------------------------------------------------------------------
-- WINDOWS

-- stylua: ignore
keymap({ "n", "v", "i" }, "<C-CR>", "<C-w>w", { desc = " Cycle windows" })
keymap({ "n", "x" }, "<C-v>", "<cmd>vertical leftabove split<CR>", { desc = " Vertical split" })
keymap({ "n", "x" }, "<D-W>", vim.cmd.only, { desc = " Close other windows" })

local delta = 5
keymap("n", "<C-Up>", "<C-w>" .. delta .. "-")
keymap("n", "<C-Down>", "<C-w>" .. delta .. "+")
keymap("n", "<C-Left>", "<C-w>" .. delta .. "<")
keymap("n", "<C-Right>", "<C-w>" .. delta .. ">")

--------------------------------------------------------------------------------
-- BUFFERS & FILES

-- stylua: ignore
keymap({ "n", "x" }, "<CR>", function() require("personal-plugins.alt-alt").gotoAltFile() end, { desc = "󰬈 Goto alt-file" })

-- close window or buffer
keymap({ "n", "x", "i" }, "<D-w>", function()
	vim.cmd("silent! update")
	local winClosed = pcall(vim.cmd.close)
	if winClosed then return end

	local bufCount = #vim.fn.getbufinfo { buflisted = 1 }
	if bufCount == 1 then
		vim.notify("Only one buffer open.", vim.log.levels.TRACE)
	else
		vim.cmd.bdelete()
	end
end, { desc = "󰽙 Close window/buffer" })

keymap("n", "<BS>", function()
	if vim.bo.buftype ~= "" then return end -- prevent accidental triggering in special buffers
	vim.cmd.bprevious()
end, { desc = "󰽙 Prev buffer" })
keymap("n", "<S-BS>", vim.cmd.bnext, { desc = "󰽙 Next buffer" })

-- stylua: ignore
keymap({ "n", "x" }, "<D-CR>", function() require("personal-plugins.alt-alt").gotoMostChangedFile() end, { desc = "󰊢 Goto most changed file" })

-- stylua: ignore
keymap({ "n", "x", "i" }, "<D-L>", function() require("personal-plugins.misc").openWorkflowInAlfredPrefs() end, { desc = "󰮤 Reveal in Alfred" })

--------------------------------------------------------------------------------
-- MACROS

do
	local reg = "r"
	local toggleKey = "0"
	keymap(
		"n",
		toggleKey,
		function() require("personal-plugins.misc").startOrStopRecording(toggleKey, reg) end,
		{ desc = "󰃽 Start/stop recording" }
	)
	keymap("n", "9", "@" .. reg, { desc = "󰃽 Play recording" })
end

--------------------------------------------------------------------------------
-- REFACTORING

keymap("n", "<leader>rr", vim.lsp.buf.rename, { desc = "󰑕 LSP rename" })

-- stylua: ignore
keymap("n", "<leader>rc", function() require("personal-plugins.misc").camelSnakeLspRename() end, { desc = "󰑕 LSP rename: camel/snake" })

keymap("n", "<leader>rq", function()
	local line = vim.api.nvim_get_current_line()
	local updatedLine = line:gsub("[\"']", function(q) return (q == [["]] and [[']] or [["]]) end)
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = " Switch quotes in line" })

--------------------------------------------------------------------------------

-- TEMPLATE STRINGS
-- stylua: ignore
keymap("i", "<D-t>", function() require("personal-plugins.auto-template-str").insertTemplateStr() end, { desc = "󰅳 Insert template string" })

-- MULTI-EDIT
keymap("n", "<D-j>", '*N"_cgn', { desc = "󰆿 Multi-edit cword" })
keymap("x", "<D-j>", function()
	local selection = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = "v" })[1]
	vim.fn.setreg("/", "\\V" .. vim.fn.escape(selection, [[/\]]))
	return '<Esc>"_cgn'
end, { desc = "󰆿 Multi-edit selection", expr = true })

--------------------------------------------------------------------------------
-- OPTION TOGGLING

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
	local names = vim.iter(clients):map(function(client) return "- " .. client.name end):join("\n")
	vim.notify(names, vim.log.levels.TRACE, { title = "Restarting LSPs", icon = "󰑓" })
	vim.lsp.stop_client(clients)
	vim.defer_fn(vim.cmd.edit, 1000) -- wait for shutdown -> reload via `:edit` -> re-attaches LSPs
end, { desc = "󰑓 LSPs restart" })
