require("config.utils")
--------------------------------------------------------------------------------

-- do not autowrap
Bo.formatoptions = Bo.formatoptions:gsub("t", "") 

-- link textobj
Keymap(
	{ "o", "x" },
	"il",
	"<cmd>lua require('various-textobjs').mdlink(true)<CR>",
	{ desc = "inner md link textobj", buffer = true }
)
Keymap(
	{ "o", "x" },
	"al",
	"<cmd>lua require('various-textobjs').mdlink(false)<CR>",
	{ desc = "outer md link textobj", buffer = true }
)
