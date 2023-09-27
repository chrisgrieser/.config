local u = require("config.utils")
--------------------------------------------------------------------------------

-- fix my habits
u.ftAbbr("cosnt", "const")
u.ftAbbr("local", "const")
u.ftAbbr("--", "//")

u.applyTemplateIfEmptyFile("jxa")

--------------------------------------------------------------------------------

-- Open regex in regex101
vim.keymap.set(
	"n",
	"<localleader>r",
	function() require("funcs.quality-of-life").openAtRegex101() end,
	{ desc = " Open next regex in regex101", buffer = true }
)
