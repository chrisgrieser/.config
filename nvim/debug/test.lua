
local function readFile(filePath, str)
	local file, err = io.open(path, "r")
	if not file then return "ERROR: " .. err end
	local content = file:read("*a")
	file:close()
	return content
end

local snippetDir = vim.fn.stdpath("config") .. "/snippets"
local snippets = {}
for name, type in vim.fs.dir(snippetDir, { depth = 2 }) do
	if type == "file" and name ~= "package.json" then
		local path = snippetDir .. "/" .. name
		local file, err = io.open(path, "r")
		if not file then return "ERROR: " .. err end
		local content = file:read("*a")
		file:close()
		return content
	end
end
