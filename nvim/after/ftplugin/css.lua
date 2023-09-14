local expand = vim.fn.expand
local keymap = vim.keymap.set
--------------------------------------------------------------------------------

-- stylua: ignore start
keymap({ "o", "x" }, "is", "<cmd>lua require('various-textobjs').cssSelector('inner')<CR>", { desc = "󱡔 inner CSS Selector textobj", buffer = true })
keymap({ "o", "x" }, "as", "<cmd>lua require('various-textobjs').cssSelector('outer')<CR>", { desc = "󱡔 outer CSS Selector textobj", buffer = true })

keymap({ "o", "x" }, "ix", "<cmd>lua require('various-textobjs').htmlAttribute('inner')<CR>", { desc = "󱡔 inner HTML Attribute textobj", buffer = true })
keymap({ "o", "x" }, "ax", "<cmd>lua require('various-textobjs').htmlAttribute('outer')<CR>", { desc = "󱡔 outer HTML Attribute textobj", buffer = true })
-- stylua: ignore end

-- toggle !important
keymap("n", "<leader>i", function()
	local lineContent = vim.api.nvim_get_current_line()
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";?$", " !important;", 1)
	end
	vim.api.nvim_set_current_line(lineContent)
end, { buffer = true, desc = " Toggle !important", nowait = true })

-- SHIMMERING FOCUS SPECIFIC
if expand("%:t") == "source.css" then require("funcs.shimmering-focus") end
