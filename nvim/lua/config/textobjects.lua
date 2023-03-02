require("config.utils")
--------------------------------------------------------------------------------
-- New Text objects
-- af -> a [f]unction (treesitter)
-- ao -> a c[o]ndition (treesitter)
-- q -> comment (mnemonic: [q]uiet text) (treesitter)
-- u -> consec[u]tive comment (comments.nvim / custom)
-- aa -> an [a]rgument (treesitter)
-- al -> a cal[l] (treesitter)
-- gh -> [g]it [h]unk (gitsigns.nvim)
-- ai -> an [i]ndentation (custom)
-- ad -> a [d]iagnostic (custom)
-- an -> a [n]umber (custom)
-- n -> [n]ear the [e]nding of line (custom)
-- r -> [r]est of paragraph, linewise (custom)
-- av -> a value / right side of assignment (custom)
-- ak -> a [k]ey / left side of assignment (custom)
-- aL -> a [L]oop (treesitter)
-- <Space> -> inner subword (custom)
-- ge -> diagnostic (custom)
-- o -> c[o]lumn (custom)

-- FILE-TYPE-SPECIFIC TEXT OBJECTS
-- al: a [l]ink (markdown, custom) → overwrites in markdown unused call textobj
-- as: a [s]elector (css, custom) → overwrites in css unused sentence textobj
-- a/: a regex (js/ts, custom)
-- aE: a Cod(e) block (markdown, custom, mnemonic: big cod[e])
-- aR: a Double Square Brackets (custom, mnemonic: big [r]ectangular bracket)

-- BUILTIN ONES KEPT
-- ab: bracket
-- as: sentence
-- ap: paragraph
-- aw: word

-- REMAPPING OF BUILTIN TEXT OBJECTS
keymap({ "o", "x" }, "iq", 'i"') -- [q]uote
keymap({ "o", "x" }, "aq", 'a"')
keymap({ "o", "x" }, "iz", "i'") -- [z]ingle quote
keymap({ "o", "x" }, "az", "a'")
keymap({ "o", "x" }, "ae", "a`") -- t[e]mplate-string / inline cod[e]
keymap({ "o", "x" }, "ie", "i`")
keymap({ "o", "x" }, "ir", "i]") -- [r]ectangular brackets
keymap({ "o", "x" }, "ar", "a]")
keymap({ "o", "x" }, "ic", "i}") -- [c]urly brackets
keymap({ "o", "x" }, "ac", "a}")
keymap({ "o", "x" }, "am", "aW") -- [m]assive word
keymap({ "o", "x" }, "im", "iW")

--------------------------------------------------------------------------------
-- QUICK TEXTOBJ OPERATIONS
keymap("n", "<Space>", '"_ciw', { desc = "change word" })
keymap("n", "<M-S-CR>", '"_daw', { desc = "delete word" }) -- HACK since <S-Space> not fully supported, requires karabiner remapping it
keymap("i", "<M-S-CR>", '<Space>') -- prevent accidental triggering in insert mode when typing quickly


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

-- TEXTOBJECT FOR ADJACENT COMMENTED LINES
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

--------------------------------------------------------------------------------
-- VARIOUS TEXTOBJS
-- stylua: ignore start

-- space: subword
keymap({"o", "x"}, "<Space>", function() require("various-textobjs").subword(true) end, { desc = "inner subword textobj" })

-- L: link
keymap("o", "L", function() require("various-textobjs").url() end, { desc = "link textobj" })

-- n: [n]ear end of the line
keymap({ "o", "x" }, "n", function() require("various-textobjs").nearEoL() end, { desc = "near EoL textobj" })

-- m: to next closing bracket
keymap({ "o", "x" }, "m", function() require("various-textobjs").toNextClosingBracket() end, { desc = "to next closing bracket textobj" })

-- o: c[o]lumn textobj
keymap("o", "o", function() require("various-textobjs").column() end, { desc = "column textobj" })

-- gG: entire buffer textobj
keymap( { "x", "o" }, "gG", function() require("various-textobjs").entireBuffer() end, { desc = "entire buffer textobj" })

-- r: [r]est of paragraph/indentation (linewise)
-- INFO not setting in visual mode, to keep visual block mode replace
keymap( "o", "r", function() require("various-textobjs").restOfParagraph() end, { desc = "rest of paragraph textobj" })
keymap("o", "R", function() require("various-textobjs").restOfIndentation() end, { desc = "rest of indentation textobj" })

-- iv/av: value textobj
keymap({ "x", "o" }, "iv", function() require("various-textobjs").value(true) end, { desc = "inner value textobj" })
keymap({ "x", "o" }, "av", function() require("various-textobjs").value(false) end, { desc = "outer value textobj" })

-- ik/ak: value textobj
keymap({ "x", "o" }, "ik", function() require("various-textobjs").key(true) end, { desc = "inner key textobj" })
keymap({ "x", "o" }, "ak", function() require("various-textobjs").key(false) end, { desc = "outer key textobj" })

-- ge: diagnostic textobj (similar to ge for the next diagnostic)
keymap({ "x", "o" }, "ge", function() require("various-textobjs").diagnostic() end, { desc = "diagnostic textobj" })

-- in/an: number textobj
keymap( { "x", "o" }, "in", function() require("various-textobjs").number(true) end, { desc = "inner number textobj" })
keymap( { "x", "o" }, "an", function() require("various-textobjs").number(false) end, { desc = "outer number textobj" })

-- iR/aR: double square brackets
keymap( { "x", "o" }, "iR", function() require("various-textobjs").doubleSquareBrackets(true) end, { desc = "inner double square bracket" })
keymap( { "x", "o" }, "aR", function() require("various-textobjs").doubleSquareBrackets(false) end, { desc = "outer double square bracket" })

-- ii/ai: indentation textobj
keymap({ "x", "o" }, "ii", function() require("various-textobjs").indentation(true, true) end, { desc = "inner indent textobj" })
keymap({ "x", "o" }, "ai", function() require("various-textobjs").indentation(false, false) end, { desc = "outer indent textobj" })

augroup("IndentedFileTypes", {})
autocmd("FileType", {
	group = "IndentedFileTypes",
	callback = function()
		local indentedFts = { "python", "yaml", "markdown", "gitconfig" }
		if vim.tbl_contains(indentedFts, bo.filetype) then
			keymap( { "x", "o" }, "ai", function() require("various-textobjs").indentation(false, true) end, { buffer = true, desc = "indent textobj w/ start border" })
		end
	end,
})

augroup("filetypesWithPipe", {})
autocmd("FileType", {
	group = "filetypesWithPipe",
	callback = function()
		local pipeFiletypes = { "sh", "zsh", "bash" }
		if vim.tbl_contains(pipeFiletypes, bo.filetype) then
			keymap( { "x", "o" }, "i|", function() require("various-textobjs").indentation(true) end, { buffer = true, desc = "inner pipe textobj" })
			keymap( { "x", "o" }, "a|", function() require("various-textobjs").indentation(false) end, { buffer = true, desc = "outer pipe textobj" })
		end
	end,
})

-- Git Hunks
keymap({ "x", "o" }, "gh", ":Gitsigns select_hunk<CR>", { desc = "hunk textobj" })
