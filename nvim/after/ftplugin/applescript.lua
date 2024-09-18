vim.bo.commentstring = "-- %s"
vim.opt_local.comments = { ":#", ":--" }

vim.opt_local.formatoptions:append("r") -- `<CR>` in insert mode
vim.opt_local.formatoptions:append("o") -- `o` in normal mode

--------------------------------------------------------------------------------
-- ABBREVIATIONS
local abbr = require("config.utils").bufAbbrev

abbr("sleep", "delay")
abbr("//", "--")

--------------------------------------------------------------------------------
-- KEYMAPS
local keymap = require("config.utils").bufKeymap

keymap(
	"n",
	"<D-s>",
	function() vim.cmd.normal { "m`gg=G``", bang = true } end,
	{ desc = "󰛦 Format" }
)
