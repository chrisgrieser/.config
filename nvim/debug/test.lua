--------------------------------------------------------------------------------

local history = require("yanky.history").all()
history = vim.tbl_map(function(item)
	return item.regcontent
end, history)
vim.notify(vim.inspect(history))
