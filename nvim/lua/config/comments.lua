require("config.utils")
--------------------------------------------------------------------------------

-- COMMENTS (mnemonic: [q]uiet text)
require("Comment").setup {
	ignore = "^$", -- ignore empty lines
	toggler = {
		line = "qq",
		block = "<Nop>",
	},
	opleader = {
		line = "q",
		block = "<Nop>",
	},
	extra = {
		above = "qO",
		below = "qo",
		eol = "Q",
	},
}

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
-- HORIZONTAL DIVIDER

---@diagnostic disable: param-type-mismatch
local function divider()
	local linechar = "─"
	local wasOnBlank = fn.getline(".") == ""
	local indent = fn.indent(".")
	local textwidth = bo.textwidth
	local comStr = bo.commentstring
	local ft = bo.filetype
	local comStrLength = #(comStr:gsub(" ?%%s ?", ""))

	if comStr == "" then
		vim.notify(" No commentstring for this filetype available.", logWarn)
		return
	end
	if comStr:find("-") then linechar = "-" end

	local linelength = textwidth - indent - comStrLength
	local fullLine = string.rep(linechar, linelength)
	local hr = comStr:gsub(" ?%%s ?", fullLine)
	if ft == "markdown" then hr = "---" end

	local linesToAppend = {"", hr, ""}
	if ft == "yaml" then linesToAppend = {hr}
	elseif wasOnBlank then linesToAppend = {hr, ""} end

	fn.append(".", linesToAppend)

	-- shorten if it was on blank line, since fn.indent() does not return indent
	-- line would have if it has content
	if wasOnBlank then
		normal("j==")
		local hrIndent = fn.indent(".")
		-- cannot use simply :sub, since it assumes one-byte-size chars
		local hrLine = fn.getline(".") ---@diagnostic disable-next-line: assign-type-mismatch, undefined-field
		hrLine = hrLine:gsub(linechar, "", hrIndent)
		fn.setline(".", hrLine)
	else
		normal("jj==")
	end
end
---@diagnostic enable: param-type-mismatch

keymap("n", "qw", divider)

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
