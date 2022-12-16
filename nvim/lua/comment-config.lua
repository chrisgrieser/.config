require("utils")
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
		above = "<Nop>",
		below = "<Nop>",
		eol = "Q",
	},
}

--------------------------------------------------------------------------------
-- STICKY TEXT OBJECTS ACTIONS

-- effectively creating "q" as comment textobj, can't map directly to q since
-- overlap in visual mode where q can be object and operator. However, this
-- method here also has the advantage of making it possible to preserve cursor
-- position.
-- requires remap for treesitter and comments.nvim mappings
keymap("n", "dq", [[:normal!mz<CR>dCOM`z]], {remap = true}) -- since remap is required, using mz via :normal, since m has been remapped
keymap("n", "yq", "yCOM", {remap = true}) -- thanks to yank position saving, doesn't need to be done here
keymap("n", "cq", '"_dCOMxQ', {remap = true}) -- delete & append comment to preserve commentstring


--------------------------------------------------------------------------------
-- Search only comments
augroup("commentSearch", {})
autocmd("FileType", {
	pattern = "?*", -- only active when there is a filetype
	group = "commentSearch",
	callback = function()
		local comStr = bo.commentstring:gsub("%%s.*", "")-- remove replaceholder and back side of comment
		keymap("n", "gq", "/\v"..comStr, {buffer = true, desc = "Search only Comments for a string"})
	end
})


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
	local comStrLength = #(comStr:gsub("%%s", ""):gsub(" ", ""))

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
		cmd.normal {"j==", bang = true} -- move down and indent
		cmd [[normal! j==]]
		local hrIndent = fn.indent(".")
		-- cannot use simply :sub, since it assumes one-byte-size chars
		local hrLine = fn.getline(".") ---@diagnostic disable-next-line: assign-type-mismatch, undefined-field
		hrLine = hrLine:gsub(linechar, "", hrIndent)
		fn.setline(".", hrLine)
	else
		cmd.normal {"jj==", bang = true} 
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

keymap("o", "u", commented_lines_textobject, {silent = true})
keymap("o", "Q", commented_lines_textobject, {silent = true})
