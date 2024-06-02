---@param str string
---@param filePath string
---@return string|nil -- error message
local function overwriteFile(filePath, str)
	local file, _ = io.open(filePath, "w")
	if not file then return end
	file:write(str)
	file:close()
end

vim.fn.mkdir("./debug/ffff/aaaa/bla.txt", "p")

overwriteFile("./debug/ffff/test.txt", "hello")
