local bo = vim.bo
local keymap = vim.keymap.set
--------------------------------------------------------------------------------

-- do not autowrap
bo.formatoptions = bo.formatoptions:gsub("t", "") 

-- link textobj
keymap(
	{ "o", "x" },
	"il",
	"<cmd>lua require('various-textobjs').mdlink('inner')<CR>",
	{ desc = "󱡔 inner md link", buffer = true }
)
keymap(
	{ "o", "x" },
	"al",
	"<cmd>lua require('various-textobjs').mdlink('outer')<CR>",
	{ desc = "󱡔 outer md link", buffer = true }
)
