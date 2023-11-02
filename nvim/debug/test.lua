--------------------------------------------------------------------------------
--
-- local history = require("yanky.history").all()
-- local historyOfFt = vim.tbl_filter(function(item) return item.filetype == vim.bo.ft end, history)
-- local historyStrings = vim.tbl_map(function(item) return item.regcontents end, historyOfFt)
-- vim.notify(vim.inspect(historyOfFt[8]))

local hist_type = ":"
local seen_items = {}
local items = {}
for i = 1, vim.fn.histnr(hist_type) do
	local item = vim.fn.histget(hist_type, -i)
	if #item > 0 and not seen_items[item] then
		seen_items[item] = true
		items[#items + 1] = { label = item, dup = 0 }
	end
end
vim.notify("🪚 items: " .. vim.inspect(items))
