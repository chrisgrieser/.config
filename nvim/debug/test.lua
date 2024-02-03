

local subfoldersOfCwd = vim.fs.find(
	function(name, path) return not (vim.startswith(name, ".") or path:find("%.app/")) end,
	{ type = "directory", limit = math.huge }
)

vim.notify("👽 subfoldersOfCwd: " .. vim.inspect(subfoldersOfCwd))

