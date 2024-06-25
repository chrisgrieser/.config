local specRoot = require("lazy.core.config").options.spec.import
local specPath = vim.fn.stdpath("config") .. "/lua/" .. specRoot
local handler = vim.loop.fs_scandir(specPath) or nil
if not handler then return end

local specFiles = {}
repeat
	local file, kind = vim.loop.fs_scandir_next(handler)
	if kind == "file" and file then
		local moduleName = file:gsub("%.lua$", "")
		local module = require(specRoot .. "." ..moduleName)
		if type(module[1]) == "string" then module = { module } end
		local plugins = vim.iter(module)
			:map(function(plugin) return { repo = plugin[1], module = moduleName } end)
			:totable()
		vim.list_extend(specFiles, plugins)
	end
until not file

vim.notify("👾 specFiles: " .. vim.inspect(specFiles))
