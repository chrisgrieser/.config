require("utils")
--------------------------------------------------------------------------------

-- netrw
g.netrw_browse_split = 0
g.netrw_list_hide = ".*\\.DS_Store$,^./$,^../$" -- hide files created by macOS & current directory
g.netrw_banner = 0 -- no ugly top banner
g.netrw_liststyle = 3 -- tree style as default
g.netrw_winsize = 30
g.netrw_localcopydircmd = "cp -r" -- makes copy work with directories
cmd [[highlight! def link netrwTreeBar IndentBlankLineChar]]

--------------------------------------------------------------------------------

-- Hop.nvim
require("hop").setup {
	uppercase_labels = true,
	multi_windows = true,
	hint_position = require "hop.hint".HintPosition.END,
	hint_offset = 0,
}

--------------------------------------------------------------------------------

-- undotree
-- also requires persistent undos in the options
g.undotree_WindowLayout = 3 -- split to the right
g.undotree_SplitWidth = 30
g.undotree_DiffAutoOpen = 0
g.undotree_SetFocusWhenToggle = 1
g.undotree_ShortIndicators = 1 -- for the relative date
g.undotree_HelpLine = 0 -- 0 hides the "Press ? for help"

function g.Undotree_CustomMap()
	local opts = {buffer = true, silent = true}
	keymap("n", "<C-j>", "<Plug>UndotreePreviousState", opts)
	keymap("n", "<C-k>", "<Plug>UndotreeNextState", opts)
	keymap("n", "J", "7j", opts)
	keymap("n", "K", "7k", opts)
	setlocal("list", false)
end

--------------------------------------------------------------------------------

require("indent-o-matic").setup {
	max_lines = 2048,
	standard_widths = {2, 4, 8}, -- Space indentations that should be detected
	skip_multiline = true, -- Skip multi-line comments and strings (more accurate detection but less performant)
}

--------------------------------------------------------------------------------

-- Quick Scope
g.qs_highlight_on_keys = {"f", "F", "t", "T"}
g.qs_max_chars = 200
cmd [[highlight def link QuickScopePrimary CurSearch]]

--------------------------------------------------------------------------------

-- Comments.nvim Undo
-- Textobject for adjacent commented lines
-- = qu for uncommenting
-- big Q also as text object
-- https://github.com/numToStr/Comment.nvim/issues/22#issuecomment-1272569139
local function commented_lines_textobject()
	local U = require("Comment.utils")
	local cl = vim.api.nvim_win_get_cursor(0)[1] -- current line
	local range = {srow = cl, scol = 0, erow = cl, ecol = 0}
	local ctx = {ctype = U.ctype.linewise, range = range}
	local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
	local ll, rr = U.unwrap_cstr(cstr)
	local padding = true
	local is_commented = U.is_commented(ll, rr, padding)
	local line = vim.api.nvim_buf_get_lines(0, cl - 1, cl, false)
	if next(line) == nil or not is_commented(line[1]) then return end
	local rs, re = cl, cl -- range start and end
	repeat
		rs = rs - 1
		line = vim.api.nvim_buf_get_lines(0, rs - 1, rs, false)
	until next(line) == nil or not is_commented(line[1])
	rs = rs + 1
	repeat
		re = re + 1
		line = vim.api.nvim_buf_get_lines(0, re - 1, re, false)
	until next(line) == nil or not is_commented(line[1])
	re = re - 1
	vim.fn.execute("normal! " .. rs .. "GV" .. re .. "G")
end

keymap("o", "u", commented_lines_textobject, {silent = true})
keymap("o", "Q", commented_lines_textobject, {silent = true})
