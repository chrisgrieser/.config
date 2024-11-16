---@param dir "next"|"prev"
local function nextFileInFolder(dir)
	local curPath = vim.api.nvim_buf_get_name(0)

	local itemsInFolder = vim.fs.dir(vim.fs.dirname(curPath))
	local filesInFolder = vim
		.iter(itemsInFolder)
		:filter(function(_, type) return type == "file" end)
		:map(function(item, _) return item end) -- select only name
		:totable()
	-- INFO no need for sorting, since it's already sorted alphabetically

	local curIdx
	local curFile = vim.fs.basename(curPath)
	for idx = 1, #filesInFolder do
		if filesInFolder[idx] == curFile then
			curIdx = idx
			break
		end
	end
	local nextIdx = curIdx + (dir == "next" and 1 or -1)
	if nextIdx < 1 then nextIdx = #filesInFolder end
	if nextIdx > #filesInFolder then nextIdx = 1 end
	vim.cmd.edit(filesInFolder[nextIdx])
end
