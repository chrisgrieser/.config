local curPath = vim.api.nvim_buf_get_name(0)
local curFile = vim.fs.basename(curPath)

local itemsInFolder = vim.fs.dir(vim.fs.dirname(curPath))
local filesInFolder = vim.iter(itemsInFolder)
	:filter(function(_, type) return type == "file" end)
	:map(function(item, _) return item end) -- 
	:totable()
-- table.sort(filesInFolder, function (a, b) return a < b end)


vim.notify("🖨️ filesInFolder: " .. vim.inspect(filesInFolder))
