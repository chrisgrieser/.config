local api = vim.api
local cmd = vim.cmd
local expand = vim.fn.expand
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
keymap({ "o", "x" }, "H", "^")
keymap("n", "H", "0^") -- `0` ensures fully scrolling to the left on long, indented lines
keymap({ "n", "x" }, "L", "$zv") -- zv: unfold
keymap({ "n", "x" }, "J", "6j")
keymap({ "n", "x" }, "K", "6k")

-- Jump history
-- non-unique, since it overwrites nvim default: https://neovim.io/doc/user/vim_diff.html#default-mappings
keymap("n", "<C-l>", "<C-i>", { desc = "󱋿 Jump forward", unique = false })
keymap("n", "<C-h>", "<C-o>", { desc = "󱋿 Jump back" })

-- Search
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = "Search IN sel" })

-- Diagnostics
keymap("n", "ge", vim.diagnostic.goto_next, { desc = "󰒕 Next Diagnostic" })
keymap("n", "gE", vim.diagnostic.goto_prev, { desc = "󰒕 Previous Diagnostic" })
keymap({ "n", "v", "i" }, "<D-g>", vim.lsp.buf.signature_help, { desc = "󰏪 Signature" })

--------------------------------------------------------------------------------
-- TEXTOBJECTS

-- remapping of builtin text objects
for remap, original in pairs(u.textobjRemaps) do
	keymap({ "o", "x" }, "i" .. remap, "i" .. original, { desc = "󱡔 inner " .. original })
	keymap({ "o", "x" }, "a" .. remap, "a" .. original, { desc = "󱡔 outer " .. original })
end

-- special remaps
keymap("o", "k", 'i"', { desc = "󱡔 inner quote" })
keymap("o", "J", "2j") -- dj = delete 2 lines, dJ = delete 3 lines

-- quick textobj operations
keymap("n", "<Space>", '"_ciw', { desc = "󱡔 change word" })
keymap("n", "<S-Space>", '"_daw', { desc = "󱡔 delete word" })

--------------------------------------------------------------------------------
-- EDITING

-- Delete trailing stuff
-- (wrapping in normal avoids temporarily scrolling to the side)
keymap("n", "X", "<cmd>normal!mz$x`z<CR>", { desc = "󱎘 Delete char at EoL" })

-- QUICKFIX
keymap("n", "gq", cmd.cnext, { desc = " Next Quickfix" })
keymap("n", "gQ", cmd.cprevious, { desc = " Prev Quickfix" })
keymap("n", "dQ", function() cmd.cexpr("[]") end, { desc = " Delete Quickfix List" })

-- COMMENTS
keymap(
	"n",
	"qw",
	function() require("funcs.quality-of-life").commentHr() end,
	{ desc = " Horizontal Divider" }
)
keymap(
	"n",
	"wq",
	function() require("funcs.quality-of-life").duplicateAsComment() end,
	{ desc = " Duplicate Line as Comment" }
)

-- WHITESPACE CONTROL
keymap("n", "=", "mzO<Esc>`z", { desc = "  blank above" })
keymap("n", "_", "mzo<Esc>`z", { desc = "  blank below" })
keymap("n", "<Tab>", ">>", { desc = "󰉶 indent line" })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent line" })
keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent selection" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent selection" })
keymap("i", "<S-Tab>", "<C-d>", { desc = "󰉵 outdent" })

keymap("n", "[", "<", { desc = "󰉵 outdent" })
keymap("n", "]", ">", { desc = "󰉶 indent" })

-- Close all top-level folds
keymap("n", "zz", function() cmd("%foldclose") end, { desc = "󰘖 Close toplevel folds" })

-- [O]pen new scope / brace
keymap(
	{ "n", "i" },
	"<D-o>",
	function() require("funcs.quality-of-life").openNewScope() end,
	{ desc = " Open new scope" }
)

-- Spelling & Casing
keymap("n", "z.", "1z=", { desc = "󰓆 Fix Spelling" }) -- works even with `spell=false`
keymap("n", "~", "~h") -- don't move cursor, useful for vertical changes

-- Merging
keymap({ "n", "x" }, "M", "J", { desc = "󰗈 Merge line up" })
keymap({ "n", "x" }, "gM", "gJ", { desc = "󰗈 Merge line up (+ trim)" })

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
keymap({ "i", "c" }, "<C-a>", "<Home>")
keymap({ "i", "c" }, "<C-e>", "<End>")
keymap("c", "<BS>", function()
	local cmdLine = vim.fn.getcmdline()
	local cmdPos = vim.fn.getcmdpos()
	local isIncRename = cmdLine:find("^IncRename ") and cmdPos < 12
	local isSubstitute = cmdLine:find("^%% s/") and cmdPos < 6
	if cmdLine == "" or isIncRename or isSubstitute then return end
	return "<BS>"
end, { desc = "Restricted <BS>", expr = true })

-- indent properly when entering insert mode on empty lines
keymap("n", "i", function()
	if api.nvim_get_current_line():find("^%s*$") then return [["_cc]] end
	return "i"
end, { expr = true, desc = "better i" })

-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated V selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` from Normal starts Visual Block" })

-- TERMINAL MODE
-- also relevant for REPLs such as iron.nvim
keymap("t", "<C-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste (Terminal Mode)" })
keymap("t", "<Esc>", [[<C-\><C-n>]], { desc = " Esc (Terminal Mode)" })

--------------------------------------------------------------------------------
-- BUFFERS & WINDOWS & FILES

keymap("n", "<CR>", function()
	if vim.bo.buftype == "terminal" then
		u.normal("a") -- enter terminal mode
	elseif vim.bo.buftype == "" then
		require("funcs.alt-alt").gotoAltBuffer()
	else
		return -- disable in other buffertypes
	end
end, { desc = "󰽙 Alt Buffer" })
keymap({ "n", "x", "i" }, "<C-CR>", "<C-w>w", { desc = " Next Window" })

keymap(
	{ "n", "x", "i" },
	"<D-w>",
	function() require("funcs.alt-alt").betterClose() end,
	{ desc = "󰽙 close buffer/window" }
)

--------------------------------------------------------------------------------
-- CLIPBOARD

-- keep the register clean
keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')

-- do not clutter the register if blank line is deleted
keymap("n", "dd", function()
	if api.nvim_get_current_line():find("^%s*$") then return '"_dd' end
	return "dd"
end, { expr = true })

-- paste w/o switching register
keymap("x", "p", "P")

-- always paste characterwise when in insert mode
keymap("i", "<D-v>", function()
	local regContent = vim.trim(fn.getreg("+"))
	fn.setreg("+", regContent, "v") ---@diagnostic disable-line: param-type-mismatch
	return "<C-g>u<C-r><C-o>+" -- "<C-g>u" adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

--- paste via cmd+v
keymap("n", "<D-v>", "p")
keymap("c", "<D-v>", "<C-r>+", { desc = " Paste" })

------------------------------------------------------------------------------
-- CMD-KEYBINDINGS

keymap(
	{ "n", "x" },
	"<D-l>",
	function() fn.system { "open", "-R", expand("%:p") } end,
	{ desc = "󰀶 Reveal in Finder" }
)
keymap(
	{ "n", "x" },
	"<D-5>",
	function() require("funcs.quality-of-life").openAlfredPref() end,
	{ desc = "󰮤 Reveal in Alfred" }
)

-- cmd+e: inline code
keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = "  Inline Code" }) -- no selection = word under cursor
keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = "  Inline Code" })
keymap("i", "<D-e>", "``<Left>", { desc = "  Inline Code" })

--------------------------------------------------------------------------------

-- quick quitting
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "qf", "help" },
	callback = function()
		vim.keymap.set("n", "q", cmd.close, { buffer = true, nowait = true, desc = "Quit" })
	end,
})

--------------------------------------------------------------------------------
