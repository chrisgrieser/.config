require("config.utils")
--------------------------------------------------------------------------------

-- REMAPPING OF BUILTIN TEXT OBJECTS
Keymap({ "o", "x" }, "iq", 'i"') -- [q]uote
Keymap({ "o", "x" }, "aq", 'a"')
Keymap({ "o", "x" }, "iz", "i'") -- [z]ingle quote
Keymap({ "o", "x" }, "az", "a'")
Keymap({ "o", "x" }, "ae", "a`") -- t[e]mplate-string / inline cod[e]
Keymap({ "o", "x" }, "ie", "i`")
Keymap({ "o", "x" }, "ir", "i]") -- [r]ectangular brackets
Keymap({ "o", "x" }, "ar", "a]")
Keymap({ "o", "x" }, "ic", "i}") -- [c]urly brackets
Keymap({ "o", "x" }, "ac", "a}")
Keymap({ "o", "x" }, "am", "aW") -- [m]assive word
Keymap({ "o", "x" }, "im", "iW")

--------------------------------------------------------------------------------
-- QUICK TEXTOBJ OPERATIONS
Keymap("n", "<Space>", '"_ciw', { desc = "change word" })
Keymap("n", "<M-S-CR>", '"_daw', { desc = "delete word" }) -- HACK since <S-Space> not fully supported, requires karabiner remapping it
Keymap("i", "<M-S-CR>", "<Space>") -- FIX accidental triggering in insert mode when typing quickly

--------------------------------------------------------------------------------
-- STICKY COMMENT TEXT OBJECT ACTIONS
-- HACK effectively creating "q" as comment textobj, can't map directly to q since
-- overlap in visual mode where q can be object and operator. However, this
-- method here also has the advantage of making it possible to preserve cursor
-- position.
Keymap("n", "dq", function()
	local prevCursor = GetCursor(0)
	Cmd.normal { "d<<<" } -- without bang for remapping of COM
	SetCursor(0, prevCursor)
end, { remap = true, desc = "delete comment" })

-- manually changed cq to preserve the commentstring
Keymap("n", "cq", function()
	Cmd.normal { "d<<<" } -- without bang for remapping
	Cmd.normal { "x" }
	Cmd.normal { "Q" }
	Cmd.startinsert { bang = true }
end, { desc = "change comment" })

-- INFO omap q <<< is done is treesitter config, takes care of other operators
-- like `y`
--------------------------------------------------------------------------------

-- TEXTOBJECT FOR ADJACENT COMMENTED LINES
-- https://github.com/numToStr/Comment.nvim/issues/22#issuecomment-1272569139
local function commented_lines_textobject()
	local U = require("Comment.utils")
	local cl = vim.api.nvim_win_get_cursor(0)[1] -- current line
	local range = { srow = cl, scol = 0, erow = cl, ecol = 0 }
	local ctx = { ctype = U.ctype.linewise, range = range }
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
	-- fsfs
	until next(line) == nil or not is_commented(line[1])
	rs = rs + 1
	repeat
		re = re + 1
		line = vim.api.nvim_buf_get_lines(0, re - 1, re, false)
	until next(line) == nil or not is_commented(line[1])
	re = re - 1
	vim.fn.execute("normal! " .. rs .. "GV" .. re .. "G")
end

Keymap("o", "u", commented_lines_textobject, { desc = "Big comment textobj" })

--------------------------------------------------------------------------------

-- VARIOUS TEXTOBJS KEYMAPS
-- stylua: ignore start

-- space: subword
Keymap({"o", "x"}, "<Space>", "<cmd>lua require('various-textobjs').subword(true)<CR>", { desc = "inner subword textobj" })

-- L: link
Keymap("o", "L", "<cmd>lua require('various-textobjs').url()<CR>", { desc = "link textobj" })

-- iv/av: value textobj
Keymap({ "x", "o" }, "iv", "<cmd>lua require('various-textobjs').value(true)<CR>", { desc = "inner value textobj" })
Keymap({ "x", "o" }, "av", "<cmd>lua require('various-textobjs').value(false)<CR>", { desc = "outer value textobj" })

-- ak: outer key textobj
-- INFO `ik` defined via treesitter to exclude `local` and `let`
-- INFO mapping the *inner* obj to `ak`, since it includes `local` and `let`
-- (various textobjs' outer key includes the "=" and ":" as well)
Keymap({ "x", "o" }, "ak", "<cmd>lua require('various-textobjs').key(true)<CR>", { desc = "outer key textobj" })

-- n: [n]ear end of the line
Keymap({ "o", "x" }, "n", "<cmd>lua require('various-textobjs').nearEoL()<CR>", { desc = "near EoL textobj" })

-- m: to next closing bracket
Keymap({ "o", "x" }, "m", "<cmd>lua require('various-textobjs').toNextClosingBracket()<CR>", { desc = "to next closing bracket textobj" })

-- o: c[o]lumn textobj
Keymap("o", "o", "<cmd>lua require('various-textobjs').column()<CR>", { desc = "column textobj" })

-- ag: entire buffer textobj
Keymap( { "x", "o" }, "ag", "<cmd>lua require('various-textobjs').entireBuffer()<CR>", { desc = "entire buffer textobj" })

-- r: [r]est of paragraph/indentation (linewise)
-- INFO not setting in visual mode, to keep visual block mode replace
Keymap("o", "rp", "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", { desc = "rest of paragraph textobj" })
Keymap("o", "ri", "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", { desc = "rest of indentation textobj" })
Keymap( "o", "rg", "G", { desc = "rest of buffer textobj" })

-- ge: diagnostic textobj (similar to ge for the next diagnostic)
Keymap({ "x", "o" }, "ge", "<cmd>lua require('various-textobjs').diagnostic()<CR>", { desc = "diagnostic textobj" })

-- iR/aR: double square brackets
Keymap( { "x", "o" }, "iR", "<cmd>lua require('various-textobjs').doubleSquareBrackets(true)<CR>", { desc = "inner double square bracket" })
Keymap( { "x", "o" }, "aR", "<cmd>lua require('various-textobjs').doubleSquareBrackets(false)<CR>", { desc = "outer double square bracket" })

-- ii/ai: indentation textobj
Keymap({ "x", "o" }, "ii", "<cmd>lua require('various-textobjs').indentation(true, true)<CR>", { desc = "inner indent textobj" })
Keymap({ "x", "o" }, "ai", "<cmd>lua require('various-textobjs').indentation(false, false)<CR>", { desc = "outer indent textobj" })

Autocmd("FileType", {
	callback = function()
		local indentedFts = { "python", "yaml", "markdown", "gitconfig" }
		if vim.tbl_contains(indentedFts, Bo.filetype) then
			Keymap( { "x", "o" }, "ai", "<cmd>lua require('various-textobjs').indentation(false, true)<CR>", { buffer = true, desc = "indent textobj w/ start border" })
		end
	end,
})

Autocmd("FileType", {
	callback = function()
		local pipeFiletypes = { "sh", "zsh", "bash" }
		if vim.tbl_contains(pipeFiletypes, Bo.filetype) then
			Keymap( { "x", "o" }, "i|", "<cmd>lua require('various-textobjs').shellPipe(true)<CR>", { buffer = true, desc = "inner pipe textobj" })
			Keymap( { "x", "o" }, "a|", "<cmd>lua require('various-textobjs').shellPipe(false)<CR>", { buffer = true, desc = "outer pipe textobj" })
		end
	end,
})

-- Git Hunks
Keymap({ "x", "o" }, "gh", ":Gitsigns select_hunk<CR>", { desc = "hunk textobj" })
