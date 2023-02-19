require("config.utils")

--------------------------------------------------------------------------------
-- STICKY COMMENT TEXT OBJECT ACTIONS

-- HACK effectively creating "q" as comment textobj, can't map directly to q since
-- overlap in visual mode where q can be object and operator. However, this
-- method here also has the advantage of making it possible to preserve cursor
-- position.
keymap("n", "yq", "y<<<", {remap = true, desc = "yank comment"}) -- BUG highlight does work, but yanking works correctly
keymap("n", "dq", function ()
	local prevCursor = getCursor(0)
	cmd.normal { "d<<<" } -- without bang for remapping of COM
	setCursor(0, prevCursor)
end, {remap = true, desc = "delete comment"}) 
keymap("n", "cq", function ()
	cmd.normal { "d<<<" } -- without bang for remapping 
	cmd.normal { "x" }
	cmd.normal { "Q" }
	cmd.startinsert{bang = true}
end, {desc = "change comment"}) 

--------------------------------------------------------------------------------
-- Duplicate line as comment
keymap("n", "qd", "Rkqqj", {desc = "Duplicate Line as Comment", remap = true})

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------

-- TEXTOBJECT FOR ADJACENT COMMENTED LINES
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

keymap("o", "u", commented_lines_textobject, {desc = "Big comment textobj"})
