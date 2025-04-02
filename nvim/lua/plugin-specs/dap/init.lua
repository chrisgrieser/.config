-- return table with all modules in this directory
--------------------------------------------------------------------------------
local absPathOfThisFile = debug.getinfo(1, "S").source:sub(2)
local relPath = absPathOfThisFile:sub(#(vim.fn.stdpath("config") .. "/lua/") + 1)
local module = relPath:gsub("/init%.lua$", ""):gsub("/", ".")

local parentDirIter = vim.fs.dir(vim.fs.dirname(absPathOfThisFile))
local out = vim.iter(parentDirIter)
	:filter(function(name, _) return name ~= "init.lua" and vim.endswith(name, ".lua") end)
	:map(function(name, _)
		name = name:gsub("%.lua$", "")
		return require(module .. "." .. name)
	end)
	:totable()

return out
