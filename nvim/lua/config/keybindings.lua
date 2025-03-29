local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------
-- META

local pathOfThisFile = debug.getinfo(1, "S").source:sub(2)
local desc = "⌨️ Edit " .. vim.fs.basename(pathOfThisFile)
keymap("n", "<D-,>", function() vim.cmd.edit(pathOfThisFile) end, { desc = desc })

-- `cmd-q` remapped to `ZZ` via Karabiner, PENDING https://github.com/neovide/neovide/issues/2558
keymap("n", "ZZ", function() vim.cmd.wqall { bang = true } end)

local pluginDir = vim.fn.stdpath("data") --[[@as string]]
keymap("n", "<leader>pd", function() vim.ui.open(pluginDir) end, { desc = "󰝰 Plugin dir" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- make j/k on wrapped lines
keymap({ "n", "x" }, "j", "gj")
keymap({ "n", "x" }, "k", "gk")

-- HJKL behaves like hjkl, but bigger distance
-- (not mapping in op-pending, since using custom textobjects for those)
keymap({ "n", "x" }, "H", "0^", { desc = "󰲠 char" }) -- scroll fully to the left
keymap("o", "H", "^", { desc = "󰲠 char" })
keymap({ "n", "x" }, "L", "$zv", { desc = "󰬓 char" }) -- zv: unfold under cursor
keymap({ "n", "x" }, "J", "6gj", { desc = "6j" })
keymap({ "n", "x" }, "K", "6gk", { desc = "6k" })

-- Jump history
keymap("n", "<C-h>", "<C-o>", { desc = "󱋿 Jump back" })
-- non-unique, since it overwrites nvim default: https://neovim.io/doc/user/vim_diff.html#default-mappings
keymap("n", "<C-l>", "<C-i>", { desc = "󱋿 Jump forward", unique = false })

-- Search
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = " Search IN selection" })

-- Goto matching parenthesis (`remap` needed to use builtin `MatchIt` plugin)
keymap("n", "gm", "%", { desc = "󰅪 Goto match", remap = true })

-- Close all top-level folds
keymap("n", "zz", "<cmd>%foldclose<CR>", { desc = "󰘖 Close toplevel folds" })

-- Open first URL in file
keymap("n", "<D-U>", function()
	local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
	local url = text:match([[%l%l%l+://[^%s)%]}"'`>]+]])
	if url then
		vim.ui.open(url)
	else
		vim.notify("No URL found in file.", vim.log.levels.WARN)
	end
end, { desc = " Open first URL in file" })

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
local trailChars = { ",", ")", ";", ".", '"', " \\", " {" }
for _, chars in pairs(trailChars) do
	keymap("n", "<leader>" .. vim.trim(chars), function()
		local updatedLine = vim.api.nvim_get_current_line() .. chars
		vim.api.nvim_set_current_line(updatedLine)
	end)
end

-- WHITESPACE & INDENTATION
keymap("n", "=", "[<Space>", { desc = " Blank above", remap = true }) -- remap, since nvim default
keymap("n", "_", "]<Space>", { desc = " Blank below", remap = true })

keymap("n", "<Tab>", ">>", { desc = "󰉶 indent" })
keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent" })
keymap("i", "<Tab>", "<C-t>", { desc = "󰉶 indent", unique = false })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent" })
keymap("i", "<S-Tab>", "<C-d>", { desc = "󰉵 outdent", unique = false })

-- Spelling (these work even with `spell=false`)
keymap("n", "z.", "1z=", { desc = "󰓆 Fix spelling" })
-- stylua: ignore
keymap("n", "zl", function() require("personal-plugins.misc").spellSuggest() end, { desc = "󰓆 Spell suggestions" })

-- Merging
keymap("n", "m", "J", { desc = "󰽜 Merge line up" })
keymap("n", "M", "<cmd>. move +1<CR>kJ", { desc = "󰽜 Merge line down" }) -- using `:move` preserves marks

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
		return "y"
	end, { expr = true })
	keymap("n", "Y", function()
		vim.b.cursorPreYank = vim.api.nvim_win_get_cursor(0)
		return "y$"
	end, { expr = true, unique = false }) -- non-unique since it's a nvim-builtin

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "User: Sticky yank/delete",
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
	local reg = vim.trim(vim.fn.getreg("+")):gsub("\n%s*$", "\n") -- remove indentation if multi-line
	vim.fn.setreg("+", reg, "v")
	return "<C-g>u<C-r><C-o>+" -- `<C-g>u` adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

-- for compatibility with macOS clipboard managers
keymap("n", "<D-v>", "p", { desc = " Paste" })

keymap("n", "<leader>y:", function()
	local lastExcmd = vim.fn.getreg(":")
	vim.fn.setreg("+", lastExcmd)
	vim.notify(lastExcmd, nil, { title = "Copied", icon = "󰅍" })
end, { desc = "󰓗 Copy last ex-cmd" })

--------------------------------------------------------------------------------
-- SURROUND

keymap("n", '"', 'bi"<Esc>ea"<Esc>', { desc = " Surround cword" })
keymap("n", "'", "bi'<Esc>ea'<Esc>", { desc = " Surround cword" })
keymap("n", "(", "bi(<Esc>ea)<Esc>", { desc = "󰅲 Surround cword" })
keymap("n", "[", "bi[<Esc>ea]<Esc>", { desc = "󰅪 Surround cword", nowait = true })
keymap("n", "{", "bi{<Esc>ea}<Esc>", { desc = " Surround cword" })
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

keymap("o", "J", "2j") -- dd = 1 line, dj = 2 lines, dJ = 3 lines
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
-- stylua: ignore
keymap({ "n", "x" }, "<D-s>", function() require("personal-plugins.misc").formatWithFallback() end, { desc = "󱉯 Save & Format" })

do
	local signatureOpts = {
		max_width = 70,
		max_height = 12,
	}
	-- stylua: ignore
	keymap({ "n", "i", "v" }, "<D-g>", function() vim.lsp.buf.signature_help(signatureOpts) end, { desc = "󰏪 LSP signature" })

	local hoverOpts = {
		max_width = 70,
		silent = true,
		title = " LSP hover ",
	}
	-- stylua: ignore
	keymap({ "n", "x" }, "<leader>h", function() vim.lsp.buf.hover(hoverOpts) end, { desc = "󰋽 LSP hover" })

	local function scrollLspWin(lines)
		local winid = vim.b.lsp_floating_preview --> stores id of last `vim.lsp`-generated win
		if not winid or not vim.api.nvim_win_is_valid(winid) then return end
		vim.api.nvim_win_call(winid, function()
			local topline = vim.fn.winsaveview().topline
			vim.fn.winrestview { topline = topline + lines }
		end)
	end
	keymap("n", "<PageDown>", function() scrollLspWin(5) end, { desc = "↓ Scroll LSP window" })
	keymap("n", "<PageUp>", function() scrollLspWin(-5) end, { desc = "↑ Scroll LSP window" })
end

--------------------------------------------------------------------------------

-- INSERT MODE
keymap("n", "i", function()
	local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
	return lineEmpty and [["_cc]] or "i"
end, { expr = true, desc = "indented i on empty line" })

-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated `V` selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` starts visual block" })

-- TERMINAL MODE
-- (also relevant for REPLs such as iron.nvim)
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

keymap("n", "<leader>ip", vim.show_pos, { desc = " Position at cursor" })
keymap("n", "<leader>it", vim.treesitter.inspect_tree, { desc = " TS tree" })
keymap("n", "<leader>iq", vim.treesitter.query.edit, { desc = " TS query" })

-- stylua: ignore
keymap("n", "<leader>il", function() require("personal-plugins.misc").lspCapabilities() end, { desc = "󱈄 LSP capabilities" })
-- stylua: ignore
keymap("n", "<leader>ib", function() require("personal-plugins.misc").bufferInfo() end, { desc = "󰽙 Buffer info" })

keymap({ "n", "x" }, "<leader>es", function()
	local location = vim.fn.stdpath("config") .. "/debug"
	vim.fn.mkdir(location, "p")
	local currentExt = vim.fn.expand("%:e")
	local path = location .. "/scratch." .. currentExt
	vim.cmd.edit(path)
	vim.cmd.write(path)
end, { desc = "󰈮 Scratch file" })

keymap({ "n", "x" }, "<leader>ee", ":lua = ", { desc = " Eval" })

--------------------------------------------------------------------------------
-- WINDOWS

-- stylua: ignore
keymap({ "n", "v", "i" }, "<C-CR>", function() vim.cmd.wincmd("w") end, { desc = " Cycle windows" })
keymap({ "n", "x" }, "<C-v>", "<cmd>vertical leftabove split<CR>", { desc = " Vertical split" })
keymap({ "n", "x" }, "<D-W>", vim.cmd.only, { desc = " Close other windows" })

local delta = 5
keymap("n", "<C-Up>", "<C-w>" .. delta .. "-")
keymap("n", "<C-Down>", "<C-w>" .. delta .. "+")
keymap("n", "<C-Left>", "<C-w>" .. delta .. "<")
keymap("n", "<C-Right>", "<C-w>" .. delta .. ">")

--------------------------------------------------------------------------------
-- BUFFERS & FILES

do
	-- stylua: ignore
	keymap({ "n", "x" }, "<CR>", function() require("personal-plugins.alt-alt").gotoAltFile() end, { desc = "󰬈 Goto alt-file" })
	vim.api.nvim_create_autocmd("FileType", {
		desc = "User: restore default behavior of `<CR>` for quickfix buffers.",
		pattern = "qf",
		callback = function(ctx) vim.keymap.set("n", "<CR>", "<CR>", { buffer = ctx.buf }) end,
	})
end

keymap("n", "<D-r>", vim.cmd.edit, { desc = "󰽙 Reload buffer" })
keymap("n", "<BS>", function()
	if vim.bo.buftype ~= "" then return end -- prevent accidental triggering in special buffers
	vim.cmd.bprevious()
end, { desc = "󰽙 Prev buffer" })
keymap("n", "<S-BS>", vim.cmd.bnext, { desc = "󰽙 Next buffer" })

-- stylua: ignore
keymap({ "n", "x" }, "<D-CR>", function() require("personal-plugins.misc").gotoMostChangedFile() end, { desc = "󰊢 Goto most changed file" })

-- close window or buffer
keymap({ "n", "x", "i" }, "<D-w>", function()
	local winClosed = pcall(vim.cmd.close)
	if not winClosed then require("personal-plugins.alt-alt").deleteBuffer() end
end, { desc = "󰽙 Close window/buffer" })

-- stylua: ignore
keymap({ "n", "x", "i" }, "<D-L>", function() require("personal-plugins.misc").openAlfredPref() end, { desc = "󰮤 Reveal in Alfred" })

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

keymap("n", "<leader>v", vim.lsp.buf.rename, { desc = "󰑕 LSP rename" })

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

--------------------------------------------------------------------------------
