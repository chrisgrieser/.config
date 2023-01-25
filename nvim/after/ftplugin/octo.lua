---@diagnostic disable: param-type-mismatch
require("config.utils")
--------------------------------------------------------------------------------

-- decrease line length without zen mode plugins 
vim.defer_fn(function ()
	wo.showbreak=""
	opt_local.colorcolumn = ""
	opt_local.signcolumn = "yes:2"
end, 100)
