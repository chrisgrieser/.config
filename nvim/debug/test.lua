local function mydebug()
	local acc = {}
	for level = 2, math.huge do
		local info = debug.getinfo(level, "Sln")
		if not info then break end
		local source = info.source:gsub("^@", "")
		local line = "- " .. (info.name or vim.fs.basename(info.source)) .. ":" .. info.currentline
		table.insert(acc, line)
	end
	local msg = table.concat(acc, "\n")
	vim.notify(msg, vim.log.levels.DEBUG)
end

--------------------------------------------------------------------------------

local function one() mydebug() end
local function two() one() end
two()
