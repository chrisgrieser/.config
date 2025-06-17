vim.bo.commentstring = "/* %s */" -- add spaces

--------------------------------------------------------------------------------
local bkeymap = require("config.utils").bufKeymap

bkeymap("n", "!", function()
	local line = vim.api.nvim_get_current_line()
	if line:find("!important") then
		line = line:gsub(" ?!important", "")
	else
		line = line:gsub(";?$", " !important;", 1)
	end
	vim.api.nvim_set_current_line(line)
end, { desc = " Toggle !important" })

-- custom formatting function to run fix all actions before
bkeymap("n", "<D-s>", function()
	vim.lsp.buf.code_action {
		context = { only = { "source.action.useSortedProperties.biome" } }, ---@diagnostic disable-line: assign-type-mismatch,missing-fields
		apply = true,
	}
	vim.defer_fn(vim.lsp.buf.format, 50)
end, { desc = " Fixall & Format" })
