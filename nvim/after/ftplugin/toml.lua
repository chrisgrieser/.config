require("config.utils")
--------------------------------------------------------------------------------

-- do not autowrap
Bo.formatoptions = Bo.formatoptions:gsub("t", "") 

-- link textobj
Keymap(
	{ "o", "x" },
	"il",
	function() require("various-textobjs").mdlink(true) end,
	{ desc = "inner md link textobj", buffer = true }
)
Keymap(
	{ "o", "x" },
	"al",
	function() require("various-textobjs").mdlink(false) end,
	{ desc = "outer md link textobj", buffer = true }
)
