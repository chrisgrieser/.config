vim.bo.commentstring = "/* %s */"

--------------------------------------------------------------------------------
local keymap = require("config.utils").bufKeymap

keymap("n", "!", function()
	local line = vim.api.nvim_get_current_line()
	if line:find("!important") then
		line = line:gsub(" ?!important", "")
	else
		line = line:gsub(";?$", " !important;", 1)
	end
	vim.api.nvim_set_current_line(line)
end, { desc = " Toggle !important" })
