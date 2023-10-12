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

-- visual instead of logical lines
keymap({ "n", "x" }, "j", "gj")
keymap({ "n", "x" }, "k", "gk")

-- HJKL behaves like hjkl, but bigger distance
keymap({ "o", "x" }, "H", "^") -- `zv` opens folds when navigating a horizontal lines
keymap("n", "H", "0^") -- `0` ensures fully scrolling to the left on long unwrapped lines
keymap({ "n", "x" }, "L", "$zv")
keymap({ "n", "x" }, "J", "6gj")
keymap({ "n", "x" }, "K", "6gk")

-- dj = delete 2 lines, dJ = delete 3 lines
keymap("o", "J", "2j")

-- Jump history
-- non-unique, since it overwrites nvim default: https://neovim.io/doc/user/vim_diff.html#default-mappings
keymap("n", "<C-l>", "<C-i>", { desc = "Jump forward", unique = false })
keymap("n", "<C-h>", "<C-o>", { desc = "Jump back" })

-- SEARCH
keymap("n", "-", "/")
keymap("x", "-", "<Esc>/\\%V", { desc = "Search within selection" })

-- Diagnostics
keymap("n", "ge", vim.diagnostic.goto_next, { desc = "󰒕 Next Diagnostic" })
keymap("n", "gE", vim.diagnostic.goto_prev, { desc = "󰒕 Previous Diagnostic" })

--------------------------------------------------------------------------------
-- TEXTOBJECTS

-- remapping of builtin text objects
for remap, original in pairs(u.textobjRemaps) do
	keymap({ "o", "x" }, "i" .. remap, "i" .. original, { desc = "󱡔 inner " .. original })
	keymap({ "o", "x" }, "a" .. remap, "a" .. original, { desc = "󱡔 outer " .. original })
end

-- quick textobj operations
keymap("n", "<Space>", '"_ciw', { desc = "󱡔 change word" })
keymap("x", "<Space>", '"_c', { desc = "󱡔 change selection" })
keymap("n", "<S-Space>", '"_daw', { desc = "󱡔 delete word" })

keymap(
	"o",
	"u",
	function() require("funcs.quality-of-life").commented_lines_textobject() end,
	{ desc = "󱡔  Big Comment textobj" }
)

--------------------------------------------------------------------------------
-- EDITING

-- Delete trailing stuff
-- (wrapping in normal avoids temporarily scrolling to the side)
keymap("n", "X", "<cmd>normal!mz$x`z<CR>", { desc = "󱎘 Delete char at EoL" })

-- Toggle Char Case
-- stylua: ignore
keymap("n", "~", function() require("funcs.quality-of-life").toggleCase() end, { desc = "better ~" })

-- QUICKFIX
keymap("n", "gq", cmd.cnext, { desc = " Next Quickfix" })
keymap("n", "gQ", cmd.cprevious, { desc = " Prev Quickfix" })
keymap("n", "dQ", function() cmd.cexpr("[]") end, { desc = " Delete Quickfix List" })

-- COMMENTS
-- stylua: ignore
keymap("n", "qw", function () require("funcs.quality-of-life").commentHr() end, { desc = " Horizontal Divider" })
keymap("n", "wq", '"zyy"zpkqqj', { desc = " Duplicate Line as Comment", remap = true })

-- WHITESPACE CONTROL
keymap("n", "=", "mzO<Esc>`z", { desc = "  blank above" })
keymap("n", "_", "mzo<Esc>`z", { desc = "  blank below" })
keymap("n", "<Tab>", ">>", { desc = "󰉶 indent line" })
keymap("n", "<S-Tab>", "<<", { desc = "󰉵 outdent line" })
keymap("x", "<Tab>", ">gv", { desc = "󰉶 indent selection" })
keymap("x", "<S-Tab>", "<gv", { desc = "󰉵 outdent selection" })

keymap("n", "[", "<", { desc = "outdent" })
keymap("n", "]", ">", { desc = "indent" })

-- toggle all top-level folds
keymap("n", "zz", function() cmd("%foldclose") end, { desc = "󰘖 Close toplevel folds" })

-- [O]pen new scope / brace
keymap(
	{ "n", "i" },
	"<D-o>",
	function() require("funcs.quality-of-life").openNewScope() end,
	{ desc = " Open new scope" }
)

-- SPELLING
keymap("n", "z.", "1z=", { desc = "󰓆 Fix Spelling" }) -- works even with `spell=false`

-- Merging
keymap({ "n", "x" }, "M", "J", { desc = "󰗈 Merge line up" })

--------------------------------------------------------------------------------
-- LINE & CHARACTER MOVEMENT
keymap("n", "<Down>", [[<cmd>. move +1<CR>==]], { desc = "󰜮 Move Line Down" })
keymap("n", "<Up>", [[<cmd>. move -2<CR>==]], { desc = "󰜷 Move Line Up" })
keymap("n", "<Right>", [["zx"zp]], { desc = "➡️ Move Char Right" })
keymap("n", "<Left>", [["zdh"zph]], { desc = "⬅ Move Char Left" })
keymap("x", "<Down>", [[:move '>+1<CR>gv=gv]], { desc = "󰜮 Move sel down", silent = true })
keymap("x", "<Up>", [[:move '<-2<CR>gv=gv]], { desc = "󰜷 Move sel up", silent = true })
keymap("x", "<Right>", [["zx"zpgvlolo]], { desc = "➡️ Move sel right" })
keymap("x", "<Left>", [["zdh"zPgvhoho]], { desc = "⬅ Move sel left" })

--------------------------------------------------------------------------------

-- INSERT MODE
keymap("i", "<C-e>", "<Esc>A") -- EoL
keymap("i", "<C-a>", "<Esc>I") -- BoL

-- indent properly when entering insert mode on empty lines
keymap("n", "i", function()
	if api.nvim_get_current_line():find("^%s*$") then return [["_cc]] end
	return "i"
end, { expr = true, desc = "better i" })

-- COMMAND MODE
keymap("c", "<C-a>", "<Home>")
keymap("c", "<C-e>", "<End>")
keymap("c", "<C-u>", "<C-e><C-u>") -- clear full line
keymap("c", "<C-w>", "<C-r><C-w>") -- add word under cursor
keymap("c", "<BS>", function()
	local cmdLine = vim.fn.getcmdline()
	local cmdPos = vim.fn.getcmdpos()
	local isIncRename = cmdLine:find("^IncRename ") and cmdPos < 12
	local isSubstitute = cmdLine:find("^%% s/") and cmdPos < 6
	if cmdLine == "" or isIncRename or isSubstitute then return end
	return "<BS>"
end, { desc = "Restricted <BS>", expr = true })

-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated V selects more lines" })
keymap("x", "v", "<C-v>", { desc = "`vv` from Normal starts Visual Block" })

-- TERMINAL MODE
-- also relevant for iron.nvim
keymap("t", "<C-CR>", [[<C-\><C-n><C-w>w]], { desc = " Goto next window" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = " Paste (Terminal Mode)" })
keymap("t", "<Esc>", "<C-\\><C-n>", { desc = " Esc Terminal Mode" })

--------------------------------------------------------------------------------
-- BUFFERS & WINDOWS & SPLITS

keymap("n", "<CR>", function()
	if vim.bo.buftype == "terminal" then
		u.normal("a") -- enter terminal mode
	else
		require("funcs.alt-alt").altBuffer()
	end
end, { desc = "󰽙 Alt Buffer" })
keymap({ "n", "x", "i" }, "<C-CR>", "<C-w>w", { desc = " Next Window" })

keymap(
	{ "n", "x", "i" },
	"<D-w>",
	function() require("funcs.alt-alt").betterClose() end,
	{ desc = "󰽙 close buffer/window" }
)

keymap("n", "<C-w>h", "<cmd>split<CR>", { desc = " horizontal split" })
keymap("n", "<C-w>v", "<cmd>vertical split<CR>", { desc = " vertical split" })
keymap("n", "<C-w><C-h>", "<cmd>split<CR>", { desc = " horizontal split" })

keymap("n", "<C-Right>", "<cmd>vertical resize +3<CR>", { desc = " vertical resize (+)" })
keymap("n", "<C-Left>", "<cmd>vertical resize -3<CR>", { desc = " vertical resize (-)" })
keymap("n", "<C-Up>", "<cmd>resize +3<CR>", { desc = " horizontal resize (+)" })
keymap("n", "<C-Down>", "<cmd>resize -3<CR>", { desc = " horizontal resize (-)" })

-- needs remapping since I use `gf` for references
keymap("n", "ga", "gf", { desc = " Open File under cursor" })
--------------------------------------------------------------------------------
-- CLIPBOARD

--- macOS bindings
keymap({ "n", "x" }, "<D-v>", "p", { desc = "paste" })
keymap("c", "<D-v>", "<C-r>+", { desc = "paste" })

-- keep the register clean
keymap("n", "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')

-- do not clutter the register if blank line is deleted
keymap("n", "dd", function()
	local isBlankLine = api.nvim_get_current_line():find("^%s*$")
	if isBlankLine then return '"_dd' end
	return "dd"
end, { expr = true })

-- always paste characterwise when in insert mode
keymap("i", "<D-v>", function()
	local regContent = vim.trim(fn.getreg("+"))
	fn.setreg("+", regContent, "v") ---@diagnostic disable-line: param-type-mismatch
	return "<C-g>u<C-r><C-o>+" -- "<C-g>u" adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

-- paste w/o switching register
keymap("x", "p", "P")

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
