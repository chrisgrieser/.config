-- require("config.lazy")

--------------------------------------------------------------------------------
local pluginDir = "plugins"
local pluginPath = vim.fn.stdpath("config") .. "/lua/" .. pluginDir

for name, type in vim.fs.dir(pluginPath) do
	assert
	if name:find("%..*%.lua") then
		vim.notify("plugin-spec name must not contain dots")
	elseif type == "file" and vim.endswith(name, ".lua") then
		require(pluginDir .. "." .. name:gsub("%.lua$", ""))
	end
end
