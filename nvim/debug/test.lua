---@param str string
---@param filePath string
---@return string|nil -- error message
local function overwriteFile(filePath, str)
	local file, _ = io.open(filePath, "w")
	if not file then return end
	file:write(str)
	file:close()
end

vim.uv.fs_mkdir("./debug/ffff", 493)

overwriteFile("./debug/ffff/test.txt", "hello")
