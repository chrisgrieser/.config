local keymap = vim.keymap.set
local cmd = vim.cmd
local bo = vim.bo
local autocmd = vim.api.nvim_create_autocmd
local u = require("config.utils")
--------------------------------------------------------------------------------

-- REMAPPING OF BUILTIN TEXT OBJECTS
keymap({ "o", "x" }, "iq", 'i"') -- [q]uote
keymap({ "o", "x" }, "aq", 'a"')
keymap({ "o", "x" }, "iy", "i'") -- s[y]ngle quote
keymap({ "o", "x" }, "ay", "a'")
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
keymap("n", "<Space>", '"_ciw', { desc = "󱡔 change word" })
keymap("n", "<F2>", '"_daw', { desc = "󱡔 delete word" }) -- HACK since <S-Space> not fully supported, requires karabiner remapping it
keymap("i", "<F2>", "<Space>") -- FIX accidental triggering in insert mode when typing quickly

--------------------------------------------------------------------------------
-- STICKY COMMENT TEXT OBJECT ACTIONS
-- HACK effectively creating "q" as comment textobj, can't map directly to q since
-- overlap in visual mode where q can be object and operator. However, this
-- method here also has the advantage of making it possible to preserve cursor
-- position.
keymap("n", "dq", function()
	local prevCursor = u.getCursor(0)
	cmd.normal { "d&&&" } -- without bang for remapping of COM
	u.setCursor(0, prevCursor)
end, { remap = true, desc = " delete comment" })

-- manually changed cq to preserve the commentstring
keymap("n", "cq", function()
	cmd.normal { "d&&&" } -- without bang for remapping
	cmd.normal { "x" }
	cmd.normal { "Q" }
	cmd.startinsert { bang = true }
end, { desc = " change comment" })

-- INFO omap q &&& is done is treesitter config, takes care of other operators
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
	until next(line) == nil or not is_commented(line[1])
	rs = rs + 1
	repeat
		re = re + 1
		line = vim.api.nvim_buf_get_lines(0, re - 1, re, false)
	until next(line) == nil or not is_commented(line[1])
	re = re - 1
	vim.fn.execute("normal! " .. rs .. "GV" .. re .. "G")
end

keymap("o", "u", commented_lines_textobject, { desc = "󱡔  Big Comment textobj" })

-- Git Hunks
keymap({ "x", "o" }, "gh", ":Gitsigns select_hunk<CR>", { desc = "󱡔 󰊢 hunk textobj" })

--------------------------------------------------------------------------------

-- VARIOUS TEXTOBJS KEYMAPS

-- stylua: ignore start
-- space: subword
keymap({"o", "x"}, "<Space>", "<cmd>lua require('various-textobjs').subword(true)<CR>", { desc = "󱡔 inner subword textobj" })

-- L: link
keymap("o", "L", "<cmd>lua require('various-textobjs').url()<CR>", { desc = "󱡔 link textobj" })

-- iv/av: value textobj
keymap({ "x", "o" }, "iv", "<cmd>lua require('various-textobjs').value(true)<CR>", { desc = "󱡔 inner value textobj" })
keymap({ "x", "o" }, "av", "<cmd>lua require('various-textobjs').value(false)<CR>", { desc = "󱡔 outer value textobj" })

-- ak: outer key textobj
-- INFO `ik` defined via treesitter to exclude `local` and `let`
-- INFO mapping the *inner* obj to `ak`, since it includes `local` and `let`
-- (various textobjs' outer key includes the "=" and ":" as well)
keymap({ "x", "o" }, "ak", "<cmd>lua require('various-textobjs').key(true)<CR>", { desc = "󱡔 outer key textobj" })

-- n: [n]ear end of the line
keymap({ "o", "x" }, "n", "<cmd>lua require('various-textobjs').nearEoL()<CR>", { desc = "󱡔 near EoL textobj" })

-- m: to next closing bracket
keymap({ "o", "x" }, "m", "<cmd>lua require('various-textobjs').toNextClosingBracket()<CR>", { desc = "󱡔 to next closing bracket textobj" })

-- o: c[o]lumn textobj
keymap("o", "o", "<cmd>lua require('various-textobjs').column()<CR>", { desc = "󱡔 column textobj" })

-- ag: entire buffer textobj
keymap({ "x", "o" }, "ag", "<cmd>lua require('various-textobjs').entireBuffer()<CR>", { desc = "󱡔 entire buffer textobj" })

-- v: visible in window
keymap("o" , "v", "<cmd>lua require('various-textobjs').visibleInWindow()<CR>", { desc = "󱡔 visible in window textobj" })

-- az/iz: fold textobj
keymap( { "x", "o" }, "az", "<cmd>lua require('various-textobjs').closedFold(false)<CR>", { desc = "󱡔 outer fold textobj" })
keymap( { "x", "o" }, "iz", "<cmd>lua require('various-textobjs').closedFold(true)<CR>", { desc = "󱡔 inner fold textobj" })

-- a./i.: chainMember textobj
keymap( { "x", "o" }, "a.", "<cmd>lua require('various-textobjs').chainMember(false)<CR>", { desc = "󱡔 outer chainMember textobj" })
keymap( { "x", "o" }, "i.", "<cmd>lua require('various-textobjs').chainMember(true)<CR>", { desc = "󱡔 inner chainMember textobj" })

-- r: [r]est of ... (linewise)
-- INFO not setting in visual mode, to keep visual block mode replace
keymap("o", "rv", "<cmd>lua require('various-textobjs').restOfWindow()<CR>", { desc = "󱡔 rest of viewpower textobj" })
keymap("o", "rp", "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", { desc = "󱡔 rest of paragraph textobj" })
keymap("o", "ri", "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", { desc = "󱡔 rest of indentation textobj" })
keymap("o", "rg", "G", { desc = "󱡔 rest of buffer textobj" })

-- ge: diagnostic textobj (similar to ge for the next diagnostic)
keymap({ "x", "o" }, "ge", "<cmd>lua require('various-textobjs').diagnostic()<CR>", { desc = "󱡔 diagnostic textobj" })

-- iR/aR: double square brackets
keymap( { "x", "o" }, "iR", "<cmd>lua require('various-textobjs').doubleSquareBrackets(true)<CR>", { desc = "󱡔 inner double square bracket" })
keymap( { "x", "o" }, "aR", "<cmd>lua require('various-textobjs').doubleSquareBrackets(false)<CR>", { desc = "󱡔 outer double square bracket" })

-- ii/ai: indentation textobj
keymap({ "x", "o" }, "ii", "<cmd>lua require('various-textobjs').indentation(true, true)<CR>", { desc = "󱡔 inner indent textobj" })
keymap({ "x", "o" }, "ai", "<cmd>lua require('various-textobjs').indentation(false, false)<CR>", { desc = "󱡔 outer indent textobj" })

autocmd("FileType", {
	callback = function()
		local indentedFts = { "python", "yaml", "markdown", "gitconfig" }
		if vim.tbl_contains(indentedFts, bo.filetype) then
			keymap( { "x", "o" }, "ai", "<cmd>lua require('various-textobjs').indentation(false, true)<CR>", { buffer = true, desc = "󱡔 indent textobj w/ start border" })
		end
	end,
})

autocmd("FileType", {
	callback = function()
		local pipeFiletypes = { "sh", "zsh", "bash" }
		if vim.tbl_contains(pipeFiletypes, bo.filetype) then
			keymap( { "x", "o" }, "i|", "<cmd>lua require('various-textobjs').shellPipe(true)<CR>", { buffer = true, desc = "󱡔 inner pipe textobj" })
			keymap( { "x", "o" }, "a|", "<cmd>lua require('various-textobjs').shellPipe(false)<CR>", { buffer = true, desc = "󱡔 outer pipe textobj" })
		end
	end,
})
