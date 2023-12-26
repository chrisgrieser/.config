local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local u = require("config.utils")
local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------
-- META

local pathOfThisFile = debug.getinfo(1).source:sub(2)
keymap(
	"n",
	"<D-,>",
	function() vim.cmd.edit(pathOfThisFile) end,
	{ desc = "⌨️ Edit " .. vim.fs.basename(pathOfThisFile) }
)

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance
keymap({ "n", "o", "x" }, "H", "0^") -- `0` ensures fully scrolling to the left on long, indented lines
keymap({ "n", "x" }, "L", "$zv") -- zv: unfold

keymap({ "n", "x" }, "j", "gj")
keymap({ "n", "x" }, "k", "gk")
keymap({ "n", "x" }, "J", "6gj")
keymap({ "n", "x" }, "K", "6gk")

-- Jump history
-- non-unique, since it overwrites nvim default: https://neovim.io/doc/user/vim_diff.html#default-mappings
keymap("n", "<C-l>", "<C-i>", { desc = "󱋿 Jump forward", unique = false })
keymap("n", "<C-h>", "<C-o>", { desc = "󱋿 Jump back" })

keymap("n", "g,", "g;", { desc = " Goto Last Change" })

-- Search
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = "Search IN sel" })

-- Diagnostics
keymap("n", "ge", vim.diagnostic.goto_next, { desc = "󰒕 Next Diagnostic" })
keymap("n", "gE", vim.diagnostic.goto_prev, { desc = "󰒕 Previous Diagnostic" })
keymap({ "n", "v", "i" }, "<D-g>", vim.lsp.buf.signature_help, { desc = "󰏪 Signature" })

-- needs remapping since `gf` is used for LSP-references
keymap("n", "gP", "gf", { desc = " Goto Path under cursor" })

-- quickfix
keymap("n", "gq", "<cmd>cnext<CR>zv", { desc = " Next Quickfix" })
keymap("n", "gQ", "<cmd>cprevious<CR>zv", { desc = " Prev Quickfix" })
keymap("n", "dQ", "<cmd>cexpr []<CR>", { desc = " Delete Qf List" })

--------------------------------------------------------------------------------
-- TEXTOBJECTS

-- remapping of builtin text objects
for remap, original in pairs(u.textobjRemaps) do
	keymap({ "o", "x" }, "i" .. remap, "i" .. original, { desc = "󱡔 inner " .. original })
	keymap({ "o", "x" }, "a" .. remap, "a" .. original, { desc = "󱡔 outer " .. original })
end

-- special remaps
keymap("o", "J", "2j") -- dd = 1 line, dj = 2 lines, dJ = 3 lines
keymap("n", "<Space>", '"_ciw', { desc = "󱡔 change word" })
keymap("n", "<S-Space>", '"_daw', { desc = "󱡔 delete word" })

--------------------------------------------------------------------------------
-- EDITING

-- Delete trailing stuff
-- (wrapping in normal avoids temporarily scrolling to the side)
keymap("n", "X", "<cmd>normal!mz$x`z<CR>", { desc = "󱎘 Delete char at EoL" })

-- COMMENTS
keymap(
	"n",
	"qw",
	function() require("funcs.mini-plugins").commentHr() end,
	{ desc = " Horizontal Divider" }
)
keymap(
	"n",
	"wq",
	function() require("funcs.mini-plugins").duplicateAsComment() end,
	{ desc = " Duplicate Line as Comment" }
)

-- WHITESPACE & INDENTATION
keymap("n", "=", "mzO<Esc>`z", { desc = "  blank above" })
keymap("n", "_", "mzo<Esc>`z", { desc = "  blank below" })

keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent selection" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent selection" })
keymap("n", "<Tab>", ">>", { desc = "󰉶 indent line" })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent line" })
keymap("i", "<S-Tab>", "<C-d>", { desc = "󰉵 outdent line" })
keymap("i", "<Tab>", function() require("funcs.mini-plugins").tabout() end, { desc = " Tabout" })

keymap("n", "[", "<", { desc = "󰉵 outdent" })
keymap("n", "]", ">", { desc = "󰉶 indent" })

-- Close all top-level folds
keymap("n", "zz", "<cmd>%foldclose<CR>", { desc = "󰘖 Close toplevel folds" })

-- [O]pen new scope / brace
keymap(
	{ "n", "i" },
	"<D-o>",
	function() require("funcs.mini-plugins").openNewScope() end,
	{ desc = " Open new scope" }
)

-- Spelling (works even with `spell=false`)
keymap("n", "z.", "1z=", { desc = "󰓆 Fix Spelling" })

-- ~ without moving don't move cursor, useful for vertical changes
-- (`v~` instead of `~h` so dot-repetition also doesn't move the cursor)
keymap("n", "~", "v~")

-- Merging
keymap({ "n", "x" }, "M", "J", { desc = "󰗈 Merge line up" })
keymap({ "n", "x" }, "gm", "ddpkJ", { desc = "󰗈 Merge line down" })

-- Increment/Decrement + Toggle if true/false
keymap(
	{ "n", "x" },
	"+",
	function() return require("funcs.mini-plugins").toggleOrIncrement() end,
	{ desc = " Increment/Toggle", expr = true }
)
keymap({ "n", "x" }, "ö", "<C-x>", { desc = " Decrement" })

-- Undo
keymap("n", "U", "<cmd>silent redo<CR>")
keymap("n", "u", "<cmd>silent undo<CR>")

-- cmd+E: inline code
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = " Inline Code" }) -- no selection = word under cursor
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = " Inline Code" })
keymap("i", "<D-e>", "``<Left>", { desc = " Inline Code" })

-- DocString (simplified version of neogen.nvim)
keymap(
	"n",
	"qf",
	function() require("funcs.mini-plugins").docstring() end,
	{ desc = " Function Docstring" }
)

--------------------------------------------------------------------------------
-- LINE & CHARACTER MOVEMENT
keymap("n", "<Down>", [[<cmd>. move +1<CR>==]], { desc = "󰜮 Move Line Down" })
keymap("n", "<Up>", [[<cmd>. move -2<CR>==]], { desc = "󰜷 Move Line Up" })
keymap("n", "<Right>", [["zx"zp]], { desc = "➡️ Move Char Right" })
keymap("n", "<Left>", [["zdh"zph]], { desc = "⬅ Move Char Left" })
keymap("x", "<Down>", [[:move '>+1<CR>gv=gv]], { desc = "󰜮 Move Selection down", silent = true })
keymap("x", "<Up>", [[:move '<-2<CR>gv=gv]], { desc = "󰜷 Move Selection up", silent = true })
keymap("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move Selection right" })
keymap("x", "<Left>", [["zdh"zPgvhoho]], { desc = "⬅ Move Selection left" })

--------------------------------------------------------------------------------

-- COMMAND & INSERT MODE
keymap("c", "<C-u>", "<C-e><C-u>") -- kill whole line
keymap("c", "<D-v>", "<C-r>+", { desc = " Paste" })
keymap({ "i", "c" }, "<C-a>", "<Home>")
keymap({ "i", "c" }, "<C-e>", "<End>")
keymap("c", "<BS>", function()
	if vim.fn.getcmdline() == "" then return end
	return "<BS>"
end, { desc = "Restricted <BS>", expr = true })

-- indent properly when entering insert mode on empty lines
keymap("n", "i", function()
	if api.nvim_get_current_line():find("^%s*$") then return [["_cc]] end
	return "i"
end, { desc = "indented i", expr = true })

-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated V selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` starts Visual Block" })

-- TERMINAL MODE
-- (also relevant for REPLs such as iron.nvim)
keymap("t", "<C-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste (Terminal Mode)" })
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = " Esc (Terminal Mode)" })

--------------------------------------------------------------------------------
-- BUFFERS & WINDOWS & FILES

keymap({ "n", "x", "i" }, "<C-CR>", "<C-w>w", { desc = " Next Window" })

keymap(
	{ "n", "x" },
	"<CR>",
	function() require("funcs.alt-alt").gotoAltBuffer() end,
	{ desc = "󰽙 Alt Buffer" }
)

keymap({ "n", "x", "i" }, "<D-w>", function()
	local onlyOneBuffer = #(vim.fn.getbufinfo { buflisted = 1 }) == 1
	if onlyOneBuffer then return end
	vim.cmd("silent! update")
	vim.cmd.bdelete()
end, { desc = "󰽙 :bdelete" })

--------------------------------------------------------------------------------
-- CLIPBOARD

-- sticky yank operations
local cursorPreYank
keymap({ "n", "x" }, "y", function()
	cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y"
end, { desc = "󰅍 Sticky yank", expr = true })
keymap("n", "Y", function()
	cursorPreYank = vim.api.nvim_win_get_cursor(0)
	return "y$"
end, { desc = "󰅍 Sticky yank", expr = true, unique = false })

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		-- do not trigger for `d` or yanks to helper-register `z`
		if vim.v.event.operator ~= "y" or vim.v.event.regname == "z" then return end
		-- FIX for vim-visual-multi
		if vim.b["VM_Selection"] and vim.b["VM_Selection"].Regions then return end

		vim.api.nvim_win_set_cursor(0, cursorPreYank)
	end,
})

-- keep the register clean
keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')

-- do not clutter the register if blank line is deleted
keymap("n", "dd", function()
	if vim.api.nvim_get_current_line():find("^%s*$") then return '"_dd' end
	return "dd"
end, { expr = true })

-- paste without switching with register
keymap("x", "p", "P")

-- always paste characterwise when in insert mode
keymap("i", "<D-v>", function()
	local regContent = vim.trim(fn.getreg("+"))
	fn.setreg("+", regContent, "v") ---@diagnostic disable-line: param-type-mismatch
	return "<C-g>u<C-r><C-o>+" -- "<C-g>u" adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

-- use register `y` as secondary clipboard
keymap({ "n", "x" }, "gy", '"yy', { desc = "󰅍 Yank to 2ndary" })
keymap({ "n", "x" }, "gp", '"yp', { desc = " Paste from 2ndary" })

--------------------------------------------------------------------------------

-- Open regex in regex101
keymap(
	"n",
	"g/",
	function() require("funcs.mini-plugins").openAtRegex101() end,
	{ desc = " Open in regex101" }
)

------------------------------------------------------------------------------
-- MAC-SPECIFIC-KEYBINDINGS

keymap(
	{ "n", "x" },
	"<D-l>",
	function() fn.system { "open", "-R", vim.api.nvim_buf_get_name(0) } end,
	{ desc = "󰀶 Reveal in Finder" }
)
keymap(
	{ "n", "x" },
	"<D-5>",
	function() require("funcs.mini-plugins").openAlfredPref() end,
	{ desc = "󰮤 Reveal in Alfred" }
)

--------------------------------------------------------------------------------
-- QUITTING
keymap({ "n", "x" }, "<MiddleMouse>", "<cmd>try|wqall|catch|qall|endtry<CR>", { desc = "Quit App" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qf", "help", "checkhealth" },
	callback = function()
		vim.keymap.set("n", "q", cmd.close, { buffer = true, nowait = true, desc = "Close" })
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "gitcommit", "gitrebase" },
	callback = function()
		if vim.bo.buftype == "nofile" then return end -- do not trigger in DressingInput
		-- INFO cquit exists non-zero, aborting the commit/rebase
		vim.keymap.set("n", "q", cmd.cquit, { buffer = true, nowait = true, desc = "Abort" })
	end,
})

--------------------------------------------------------------------------------
