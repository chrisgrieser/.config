---@diagnostic disable-next-line: missing-fields
vim.ui.input({ prompt = "Input: " }, function(input)
	if not input then return end
	local curPath = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	local newFile = curPath .. ("/%s.lua"):format(input) 
	vim.cmd.edit(newFile)
	vim.cmd.write(newFile)
end)
