--------------------------------------------------------------------------------

local history = require("yanky.history").all()
local historyOfFt = vim.tbl_filter(function(item) return item.filetype == vim.bo.ft end, history)
local historyStrings = vim.tbl_map(function(item) return item.regcontents end, historyOfFt)
vim.notify(vim.inspect(historyOfFt[8]))
