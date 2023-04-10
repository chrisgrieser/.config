require("config.utils")
--------------------------------------------------------------------------------

-- do not autowrap
bo.formatoptions = bo.formatoptions:gsub("t", "") 

-- link textobj
keymap(
	{ "o", "x" },
	"il",
	"<cmd>lua require('various-textobjs').mdlink(true)<CR>",
	{ desc = "inner md link textobj", buffer = true }
)
keymap(
	{ "o", "x" },
	"al",
	"<cmd>lua require('various-textobjs').mdlink(false)<CR>",
	{ desc = "outer md link textobj", buffer = true }
)
