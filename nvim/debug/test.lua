local normalModeKeys = {}
local plugins = require("lazy").plugins()
for _, plugin in ipairs(plugins) do
	if plugin.keys then
		for _, map in ipairs(plugin.keys) do
			local isNormalMode = map.mode == nil
				or map.mode == "n"
				or (type(map.mode) == "table" and vim.tbl_contains(map.mode, "n"))
			local isGlobalMap = not map.ft
			if isGlobalMap and isNormalMode then table.insert(normalModeKeys, map[1]) end
		end
	end
end
local uniqueKeys = {}
for _, key in pairs(normalModeKeys) do
	if not vim.tbl_contains(uniqueKeys, key) then
		table.insert(uniqueKeys, key)
	end
end
vim.notify("🪚 keys: " .. vim.inspect(normalModeKeys))
