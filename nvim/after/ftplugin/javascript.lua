require("config/utils")
--------------------------------------------------------------------------------
bo.path = ".,,../" -- also search parent directory (useful for Alfred)

keymap(
	{ "o", "x" },
	"aR",
	function() require("various-textobjs").jsRegexTextobj(false) end,
	{ desc = "inner regex textobj" }
)
keymap(
	{ "o", "x" },
	"iR",
	function() require("various-textobjs").jsRegexTextobj(true) end,
	{ desc = "inner regex textobj" }
)
