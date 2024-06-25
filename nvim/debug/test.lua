local specRoot = require("lazy.core.config").options.spec.import
local specPath = vim.fn.stdpath("config") .. "/lua/" .. specRoot

local handler = vim.loop.fs_scandir(specPath)
if not handler then return end
local specFiles = {}
repeat
	local file, type = vim.loop.fs_scandir_next(handler)
	if type == "file" and file then
		local module = specRoot .. "." .. file:gsub("%.lua$", "")
		local M = require(module)
		if type(M[1]) == "table" then
			vim.list_extend(specFiles, M)
		else
			table.insert(specFiles, M)
		end
	end
until not file

vim.notify("👾 flat: " .. vim.inspect(specFiles))
