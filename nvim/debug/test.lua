local rootFiles = {
	"info.plist",
	".git",
}
local ancestorDirs = { ".config" }

local function getProjectRoot()
	local function exists(path) return vim.loop.fs_stat(path) ~= nil end

	local startPath = vim.fn.expand("%:p:h")
	repeat
		for _, file in ipairs(rootFiles) do
			local path = startPath .. "/" .. file
			if exists(path) then return vim.fs.dirname(path) end
		end
		for _, dir in ipairs(ancestorDirs) do
			if vim.fs.basename(vim.fs.dirname(startPath)) == dir then return startPath end
		end
		startPath = vim.fs.dirname(startPath)
	until startPath == "/"
	return "no"
end

vim.notify(getProjectRoot())
