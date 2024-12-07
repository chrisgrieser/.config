vim.bo.commentstring = "-- %s"
vim.opt_local.comments = { ":#", ":--" }

--------------------------------------------------------------------------------
-- ABBREVIATIONS
local abbr = require("config.utils").bufAbbrev

abbr("sleep", "delay")
abbr("//", "--")

--------------------------------------------------------------------------------
-- FORMATTING
local bkeymap = require("config.utils").bufKeymap
bkeymap("n", "<D-s>", function()
	vim.cmd.normal { "m`gg=G``", bang = true }
	require("personal-plugins.misc").formatWithFallback()
end, { desc = "󰀵 Format" })
