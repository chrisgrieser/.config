local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

-- INFO for `pass` buffers, no plugins are loaded. Manually creating some these
-- mappings as substitute for convenience.
if vim.env.NO_PLUGINS then
	bkeymap("n", "ss", "VP", { desc = "Substitute line" })
	bkeymap("n", "<CR>", "ZZ", { desc = "Save and exit" })
end
