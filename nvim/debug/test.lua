--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- https://github.com/chrisgrieser/gitfred
-- https://github.com/chrisgrieser/gitfred
-- https://github.com/chrisgrieser/gitfred

local urlPattern = require("various-textobjs.charwise-textobjs").urlPattern

local bufText = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
local urls = {}
for url in bufText:gmatch(urlPattern) do
	table.insert(urls, url)
end

vim.ui.select(urls, { prompt = "Select URL:" }, function (choice)
	if choice then vim.fn.system { "open", choice } end
end)
