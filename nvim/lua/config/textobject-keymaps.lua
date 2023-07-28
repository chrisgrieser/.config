local keymap = vim.keymap.set
local cmd = vim.cmd
local u = require("config.utils")
--------------------------------------------------------------------------------

-- REMAPPING OF BUILTIN TEXT OBJECTS
for remap, original in pairs(u.textobjectRemaps) do
	keymap({ "o", "x" }, "i" .. remap, "i" .. original, { desc = "󱡔 inner " .. original })
	keymap({ "o", "x" }, "a" .. remap, "a" .. original, { desc = "󱡔 outer " .. original })
end

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
end, { remap = true, desc = " Delete Comment" })

-- manually changed cq to preserve the commentstring
keymap("n", "cq", function()
	cmd.normal { "d&&&" } -- without bang for remapping
	cmd.normal { "x" }
	cmd.normal { "Q" }
	cmd.startinsert { bang = true }
end, { desc = " Change Comment" })

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
-- space: subword-fff
keymap({"o", "x"}, "<Space>", "<cmd>lua require('various-textobjs').subword(true)<CR>", { desc = "󱡔 inner subword textobj" })
keymap({"o", "x"}, "i<Space>", "<cmd>lua require('various-textobjs').subword(true)<CR>", { desc = "󱡔 inner subword textobj" })
keymap({"o", "x"}, "a<Space>", "<cmd>lua require('various-textobjs').subword(false)<CR>", { desc = "󱡔 outer subword textobj" })

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
keymap({ "o", "x" }, "w", "<cmd>lua require('various-textobjs').toNextQuotationMark()<CR>", { desc = "󱡔 to next quotation mark textobj", nowait = true })

-- o: c[o]lumn textobj
keymap({"x", "o"}, "O", "<cmd>lua require('various-textobjs').column()<CR>", { desc = "󱡔 column textobj" })

-- ag: entire buffer textobj
keymap({ "x", "o" }, "ag", "<cmd>lua require('various-textobjs').entireBuffer()<CR>", { desc = "󱡔 entire buffer textobj" })

-- v: viewport
keymap("o" , "v", "<cmd>lua require('various-textobjs').visibleInWindow()<CR>", { desc = "󱡔 visible in window textobj" })

-- az/iz: fold textobj
keymap( { "x", "o" }, "az", "<cmd>lua require('various-textobjs').closedFold(false)<CR>", { desc = "󱡔 outer fold textobj" })
keymap( { "x", "o" }, "iz", "<cmd>lua require('various-textobjs').closedFold(true)<CR>", { desc = "󱡔 inner fold textobj" })

-- r: [r]est of …
-- INFO not setting in visual mode, to keep visual block mode replace
keymap("o", "rv", "<cmd>lua require('various-textobjs').restOfWindow()<CR>", { desc = "󱡔 rest of viewport textobj" })
keymap("o", "rp", "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", { desc = "󱡔 rest of paragraph textobj" })
keymap("o", "ri", "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", { desc = "󱡔 rest of indentation textobj" })
keymap("o", "rg", "G", { desc = "󱡔 rest of buffer textobj" })

-- ge: diagnostic textobj (similar to ge for the next diagnostic)
keymap({ "x", "o" }, "ge", "<cmd>lua require('various-textobjs').diagnostic()<CR>", { desc = "󱡔 diagnostic textobj" })

-- iR/aR: double square brackets
keymap( { "x", "o" }, "i"..u.textobjectMaps["doubleSquareBracket"], "<cmd>lua require('various-textobjs').doubleSquareBrackets(true)<CR>", { desc = "󱡔 inner double square bracket" })
keymap( { "x", "o" }, "a"..u.textobjectMaps["doubleSquareBracket"], "<cmd>lua require('various-textobjs').doubleSquareBrackets(false)<CR>", { desc = "󱡔 outer double square bracket" })

-- ii/ai: indentation textobj
keymap({ "x", "o" }, "ii", "<cmd>lua require('various-textobjs').indentation(true, true)<CR>", { desc = "󱡔 inner indent textobj" })
keymap({ "x", "o" }, "ai", "<cmd>lua require('various-textobjs').indentation(false, false)<CR>", { desc = "󱡔 outer indent textobj" })
keymap({ "x", "o" }, "ij", "<cmd>lua require('various-textobjs').indentation(false, true)<CR>", { desc = "󱡔 top-border indent textobj" })
keymap({ "x", "o" }, "aj", "<cmd>lua require('various-textobjs').indentation(false, true)<CR>", { desc = "󱡔 top-border indent textobj" })

--------------------------------------------------------------------------------

-- delete surrounding indentation
keymap("n", "dsi", function()
	-- select inner indentation
	require("various-textobjs").indentation(true, true)
	-- when textobj is found, will switch to visual line mode
	local notOnIndentedLine = vim.fn.mode():find("V") == nil
	if notOnIndentedLine then return end

	-- dedent indentation
	u.normal("<")

	-- delete start- and end-border
	local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1] + 1
	local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1] - 1

	-- don't delete endborder when language does not have them
	local ft = vim.bo.filetype
	if not (ft == "python" or ft == "yaml" or ft == "markdown") then
		-- delete end first so line index is not shifted
		cmd(tostring(endBorderLn) .. " delete")
	end
	cmd(tostring(startBorderLn) .. " delete")
end, { desc = "Delete surrounding indentation" })
