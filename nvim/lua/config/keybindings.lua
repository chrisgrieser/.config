local keymap = require("config.utils").uniqueKeymap
local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------
-- META

local pathOfThisFile = debug.getinfo(1).source:sub(2)
local desc = "⌨️ Edit " .. vim.fs.basename(pathOfThisFile)
keymap("n", "<D-,>", function() vim.cmd.edit(pathOfThisFile) end, { desc = desc })

--------------------------------------------------------------------------------
-- MOVEMENTS

-- j/k should on wrapped lines
keymap({ "n", "x" }, "j", "gj")
keymap({ "n", "x" }, "k", "gk")

-- HJKL behaves like hjkl, but bigger distance
-- (not mapping in op-pending, since using custom textobjects for most of those)
keymap({ "n", "x" }, "H", "0^", { desc = "1st char" }) -- scroll fully to the left
keymap("o", "H", "^", { desc = "1st char" })
keymap({ "n", "x" }, "L", "$zv", { desc = "last char" }) -- zv: unfold under cursor
keymap({ "n", "x" }, "J", "6gj", { desc = "6j" })
keymap({ "n", "x" }, "K", "6gk", { desc = "6k" })

-- Jump history
keymap("n", "<C-h>", "<C-o>", { desc = "󱋿 Jump back" })
-- non-unique, since it overwrites nvim default: https://neovim.io/doc/user/vim_diff.html#default-mappings
keymap("n", "<C-l>", "<C-i>", { desc = "󱋿 Jump forward", unique = false })

-- Telescope's LSP functions populate the tagstack, so this allow us to go back
-- after exploring LSP references, skipping irrelevant entries in the jump list.
keymap("n", "<C-g>", vim.cmd.pop, { desc = "󱋿 Tagstack back" })

-- Search
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = " Search in sel" })

-- Match
keymap("n", "gm", "%", { desc = "Goto Match", remap = true }) -- `remap` -> use builtin `MatchIt` plugin

-- Diagnostics
keymap("n", "ge", vim.diagnostic.goto_next, { desc = "󰒕 Next Diagnostic" })
keymap("n", "gE", vim.diagnostic.goto_prev, { desc = "󰒕 Previous Diagnostic" })

--------------------------------------------------------------------------------
-- EDITING

-- Undo
keymap("n", "u", "<cmd>silent undo<CR>zv") -- just to silence it
keymap("n", "U", "<cmd>silent redo<CR>zv")

-- Toggles
keymap("n", "~", "v~", { desc = "󰬴 Toggle char case (w/o moving)" })
keymap(
	"n",
	"<",
	function() require("funcs.nano-plugins").toggleWordCasing() end,
	{ desc = "󰬴 Toggle word case" }
)

keymap(
	"n",
	">",
	function() require("funcs.nano-plugins").camelSnakeToggle() end,
	{ desc = "󰬴 Toggle camel and snake case" }
)

-- Increment/Decrement, or toggle true/false
keymap(
	{ "n", "x" },
	"+",
	function() return require("funcs.nano-plugins").toggleOrIncrement() end,
	{ desc = "󰐖 Increment/Toggle", expr = true }
)
keymap({ "n", "x" }, "ü", "<C-x>", { desc = "󰍵 Decrement" })

-- Delete trailing character
keymap("n", "X", function()
	local updatedLine = vim.api.nvim_get_current_line():gsub("%S%s*$", "")
	vim.api.nvim_set_current_line(updatedLine)
end, { desc = "󱎘 Delete char at EoL" })

-- WHITESPACE & INDENTATION
keymap("n", "=", "mzO<Esc>`z", { desc = " blank above" })
keymap("n", "_", "mzo<Esc>`z", { desc = " blank below" })

keymap("n", "<Tab>", ">>", { desc = "󰉶 indent" })
keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent" })
keymap("i", "<Tab>", "<C-t>", { desc = "󰉶 indent" })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent" })
keymap("i", "<S-Tab>", "<C-d>", { desc = "󰉵 outdent" })

-- Close all top-level folds
keymap("n", "zz", "<cmd>%foldclose<CR>", { desc = "󰘖 Close toplevel folds" })

-- Spelling (works even with `spell=false`)
keymap("n", "z.", "1z=", { desc = "󰓆 Fix Spelling" })

-- Merging
keymap("n", "m", "J", { desc = "󰗈 Merge line up" })
keymap("n", "M", '"zdd"zpkJ', { desc = "󰗈 Merge line down" })

--------------------------------------------------------------------------------

-- SURROUND
keymap("n", '"', [[bi"<Esc>ea"<Esc>]], { desc = ' " surround cword' })
keymap("n", "'", [[bi'<Esc>ea'<Esc>]], { desc = " ' surround cword" })
keymap("n", "(", [[bi(<Esc>ea)<Esc>]], { desc = "󰅲 surround cword" })
keymap("n", "[", [[bi[<Esc>ea]<Esc>]], { desc = "󰅪 surround cword", nowait = true })
keymap("n", "{", [[bi{<Esc>ea}<Esc>]], { desc = " surround cword" })
keymap("n", "<D-e>", [[bi`<Esc>ea`<Esc>]], { desc = " Inline Code cword" })
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = " Inline Code selection" })
keymap("i", "<D-e>", "``<Left>", { desc = " Inline Code" })

keymap("i", "<D-t>", "${}<Left>", { desc = "${} Template String" })

--------------------------------------------------------------------------------
-- TEXTOBJECTS

local textobjRemaps = {
	{ "c", "}", "", "curly" }, -- [c]urly brace
	{ "r", "]", "󰅪", "rectangular" }, -- [r]ectangular bracket
	{ "m", "W", "󰬞", "WORD" }, -- [m]assive word
	{ "q", '"', "", "double" }, -- [q]uote
	{ "z", "'", "", "single" }, -- [z]ingle quote
	{ "e", "`", "", "backtick" }, -- t[e]mplate string / inline cod[e]
}
for _, value in pairs(textobjRemaps) do
	local remap, original, icon, label = unpack(value)
	keymap({ "o", "x" }, "i" .. remap, "i" .. original, { desc = icon .. " inner " .. label })
	keymap({ "o", "x" }, "a" .. remap, "a" .. original, { desc = icon .. " outer " .. label })
end

-- special remaps
keymap("o", "J", "2j") -- dd = 1 line, dj = 2 lines, dJ = 3 lines
keymap("n", "<Space>", '"_ciw', { desc = "󰬞 change word" })
keymap("x", "<Space>", '"_c', { desc = "󰒅 change selection" })
keymap("n", "<S-Space>", '"_daw', { desc = "󰬞 delete word" })

--------------------------------------------------------------------------------
-- COMMENTS
-- HACK https://www.reddit.com/r/neovim/comments/1ctc1zd/comment/l4c29rx/
keymap(
	{ "n", "x" },
	"q",
	function() return require("vim._comment").operator() end,
	{ desc = "󰆈 Comment Operator", expr = true }
)
keymap("n", "qq", "q_", { desc = "󰆈 Comment Line", remap = true })
keymap("o", "u", require("vim._comment").textobject, { desc = "󰆈 Comment Text Object" })
keymap("n", "guu", "guu") -- prevent `omap u` above from overwriting `guu`

-- stylua: ignore start
keymap("n", "qw", function() require("funcs.comment").commentHr() end, { desc = "󰆈 Horizontal Divider" })
keymap("n", "wq", function() require("funcs.comment").duplicateLineAsComment() end, { desc = "󰆈 Duplicate Line as Comment" })
keymap("n", "qf", function() require("funcs.comment").docstring() end, { desc = "󰆈 Function Docstring" })
keymap("n", "Q", function() require("funcs.comment").addComment("eol") end, { desc = "󰆈 Append Comment" })
keymap("n", "qo", function() require("funcs.comment").addComment("below") end, { desc = "󰆈 Comment Below" })
keymap("n", "qO", function() require("funcs.comment").addComment("above") end, { desc = "󰆈 Comment Above" })
-- stylua: ignore end

--------------------------------------------------------------------------------
-- LINE & CHARACTER MOVEMENT

keymap("n", "<Down>", [[<cmd>. move +1<CR>==]], { desc = "󰜮 Move line down" })
keymap("n", "<Up>", [[<cmd>. move -2<CR>==]], { desc = "󰜷 Move line up" })
keymap("n", "<Right>", [["zx"zp]], { desc = "➡️ Move char right" })
keymap("n", "<Left>", [["zdh"zph]], { desc = "⬅ Move char left" })
keymap("x", "<Down>", [[:move '>+1<CR>gv=gv]], { desc = "󰜮 Move selection down", silent = true })
keymap("x", "<Up>", [[:move '<-2<CR>gv=gv]], { desc = "󰜷 Move selection up", silent = true })
keymap("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move selection right" })
keymap("x", "<left>", [["zxhh"zpgvhoho]], { desc = "⬅ Move selection left" })

-- LSP
keymap({ "n", "i", "v" }, "<D-g>", vim.lsp.buf.signature_help, { desc = "󰏪 LSP Signature" })
keymap({ "n", "x" }, "<D-s>", function()
	local formattingLsps = #vim.lsp.get_clients { method = "textDocument/formatting", bufnr = 0 }
	if formattingLsps > 0 then
		vim.lsp.buf.format()
	else
		-- remove unneeded whitespace
		vim.cmd([[% substitute_\s\+$__e]]) -- trailing spaces
		vim.cmd([[% substitute _\(\n\n\)\n\+_\1_e]]) -- duplicate blank lines
		vim.cmd([[silent! /^\%(\n*.\)\@!/,$ delete]]) -- blanks at end of file
	end
end, { desc = "󰒕 Save & Format" })

--------------------------------------------------------------------------------
-- COMMAND MODE
keymap("c", "<D-v>", "<C-r>+", { desc = " Paste" })
keymap("c", "<BS>", function()
	if vim.fn.getcmdline() ~= "" then return "<BS>" end
end, { expr = true, desc = "<BS> does not leave cmdline" })

-- INSERT MODE
keymap("n", "i", function()
	if vim.api.nvim_get_current_line():find("^%s*$") then return [["_cc]] end
	return "i"
end, { expr = true, desc = "indented i on empty line" })

-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated `V` selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` starts visual block" })

-- TERMINAL MODE
-- (also relevant for REPLs such as iron.nvim)
keymap("t", "<C-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = " Esc (terminal mode)" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste (terminal mode)" })

--------------------------------------------------------------------------------
-- WINDOWS
keymap({ "n", "x", "i" }, "<C-CR>", "<C-w>w", { desc = " Next window" })
keymap({ "n", "x" }, "<C-v>", "<cmd>vertical leftabove split<CR>", { desc = " Vertical split" })
keymap({ "n", "x" }, "<C-s>", "<cmd>horizontal split<CR>", { desc = " Horizontal split" })

local delta = 5
keymap("n", "<C-up>", "<C-w>" .. delta .. "-")
keymap("n", "<C-down>", "<C-w>" .. delta .. "+")
keymap("n", "<C-left>", "<C-w>" .. delta .. "<")
keymap("n", "<C-right>", "<C-w>" .. delta .. ">")

--------------------------------------------------------------------------------

-- SNIPPETS
keymap({ "n", "i", "s" }, "<D-p>", function()
	if vim.snippet.active() then vim.snippet.jump(1) end
end, { desc = "󰩫 next placeholder" })

vim.api.nvim_create_autocmd("WinScrolled", {
	desc = "User: Exit snippet on scroll",
	callback = function(ctx)
		local scrollWinId = tonumber(ctx.match) -- SIC ctx.match returns id as string
		local mainWinId = 1000
		if scrollWinId == mainWinId then vim.snippet.stop() end
	end,
})

--------------------------------------------------------------------------------

-- BUFFERS & FILES
keymap(
	{ "n", "x" },
	"<CR>",
	function() require("funcs.alt-alt").gotoAltFile() end,
	{ desc = "󰽙 Goto Alt-File" }
)
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: restore default behavior of `<CR>` for qf buffers.",
	pattern = "qf",
	callback = function() bkeymap("n", "<CR>", "<CR>") end,
})

keymap("n", "<D-r>", vim.cmd.edit, { desc = "󰽙 Reload buffer" })
keymap("n", "<BS>", vim.cmd.bprevious, { desc = "󰽙 Prev buffer" })
keymap("n", "<S-BS>", vim.cmd.bnext, { desc = "󰽙 Next buffer" })

keymap(
	{ "n", "x" },
	"<D-CR>",
	function() require("funcs.nano-plugins").gotoMostChangedFile() end,
	{ desc = "󰊢 Goto most changed file" }
)

-- close window or buffer
keymap({ "n", "x", "i" }, "<D-w>", function()
	local winClosed = pcall(vim.cmd.close)
	if not winClosed then require("funcs.alt-alt").closeBuffer() end
end, { desc = "󰽙 Close window/buffer" })

keymap({ "n", "x", "i" }, "<D-N>", function()
	local extensions = { "sh", "json", "mjs", "md", "py" }
	vim.ui.select(extensions, { prompt = " Scratch file", kind = "plain" }, function(ext)
		if not ext then return end
		local filepath = vim.fs.normalize("~/Desktop/scratchpad." .. ext)
		vim.cmd.edit(filepath)
		vim.cmd.write(filepath)
	end)
end, { desc = " Create Scratchpad File" })

--------------------------------------------------------------------------------

-- MAC-SPECIFIC FUNCTIONS
keymap({ "n", "x", "i" }, "<D-l>", function()
	if jit.os ~= "OSX" then return end
	vim.system { "open", "-R", vim.api.nvim_buf_get_name(0) }
end, { desc = "󰀶 Reveal in Finder" })

keymap(
	{ "n", "x", "i" },
	"<D-L>",
	function() require("funcs.nano-plugins").openAlfredPref() end,
	{ desc = "󰮤 Reveal in Alfred" }
)

--------------------------------------------------------------------------------
-- MULTI-CURSOR REPLACEMENT

keymap("n", "<D-j>", '*N"_cgn', { desc = "󰆿 Multi-edit cword" })

keymap("x", "<D-j>", function()
	local chunks = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"), { type = vim.fn.mode() })
	local selection = vim.iter(chunks)
		:map(function(chunk) return vim.fn.escape(chunk, [[/\]]) end)
		:join("\\n")
	vim.fn.setreg("/", "\\V" .. selection)
	return '<Esc>"_cgn'
end, { desc = "󰆿 Multi-edit selection", expr = true })

--------------------------------------------------------------------------------
-- MACROS

local register = "r"
local toggleKey = "0"
keymap(
	"n",
	toggleKey,
	function() require("funcs.nano-plugins").startOrStopRecording(toggleKey, register) end,
	{ desc = "󰕧 Start/stop recording" }
)
keymap("n", "9", "@" .. register, { desc = "󰕧 Play recording" })
-- `remap` since using nvim builtin mapping
keymap("x", "9", "Q", { desc = "󰕧 Play recording on each line", remap = true })

--------------------------------------------------------------------------------
-- CLIPBOARD

-- sticky yank operations
local cursorPreYank
keymap({ "n", "x" }, "y", function()
	cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y"
end, { desc = "Sticky Yank", expr = true })
keymap("n", "Y", function()
	cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y$"
end, { desc = "󰅍 Sticky Yank", expr = true, unique = false })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "User: Sticky yank",
	callback = function()
		if vim.v.event.regname == "z" then return end -- used as temp register for keymaps
		if vim.v.event.operator == "y" then vim.api.nvim_win_set_cursor(0, cursorPreYank) end
	end,
})

-- keep the register clean
keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P", { desc = " Paste w/o switching with register" })
keymap("n", "dd", function()
	if vim.api.nvim_get_current_line():find("^%s*$") then return '"_dd' end
	return "dd"
end, { expr = true, desc = "dd" })

-- pasting
keymap("n", "P", "mzA <Esc>p`z", { desc = " Sticky paste at EoL" })

keymap("i", "<D-v>", function()
	local regContent = vim.trim(vim.fn.getreg("+"))
	vim.fn.setreg("+", regContent, "v")
	return "<C-g>u<C-r><C-o>+" -- `<C-g>u` adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

keymap("n", "<D-v>", "p", { desc = " Paste" }) -- for compatibility with macOS clipboard managers

--------------------------------------------------------------------------------
-- QUITTING

-- `cmd-q` remapped to `ZZ` via Karabiner, PENDING https://github.com/neovide/neovide/issues/2558
keymap("n", "ZZ", "<cmd>wqall!<CR>", { desc = " Quit" })

vim.api.nvim_create_autocmd("FileType", {
	desc = "User: `q` to exit :help or :checkhealth",
	pattern = { "help", "checkhealth" },
	callback = function()
		vim.defer_fn(function() bkeymap("n", "q", vim.cmd.close, { desc = "Close" }) end, 1)
	end,
})

--------------------------------------------------------------------------------
