local rootFiles = {
	"info.plist",
	".git",
}
-- local parentDir = ".config"
local function exists(path) return vim.loop.fs_stat(path) ~= nil end

local function getProjectRoot(startPath)
	for _, file in ipairs(rootFiles) do
		local path = startPath .. "/" .. file
		if exists(path) then return path end
	end
	return "no"
end

local root = getProjectRoot(vim.loop.cwd())

print(root)
