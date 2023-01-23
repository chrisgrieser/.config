require("config.utils")
--------------------------------------------------------------------------------

-- do not autowrap
bo.formatoptions = bo.formatoptions:gsub("t", "") 

-- link textobj
keymap(
	{ "o", "x" },
	"il",
	function() require("various-textobjs").mdlink(true) end,
	{ desc = "inner md link textobj", buffer = true }
)
keymap(
	{ "o", "x" },
	"al",
	function() require("various-textobjs").mdlink(false) end,
	{ desc = "outer md link textobj", buffer = true }
)
