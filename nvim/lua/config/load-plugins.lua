local useLazy = false
--------------------------------------------------------------------------------
if useLazy then
	require("config.lazy")
	return
end
--------------------------------------------------------------------------------

-- make update progress clear
vim.g.neovide_progress_bar_height = 30

local function safeRequire(module)
	local success, errmsg = pcall(require, module)
	if not success then
		local msg = ("Error loading `%s`: %s"):format(module, errmsg)
		vim.notify(msg)
	end
end
--------------------------------------------------------------------------------
local pluginDir = "plugins"
local pluginPath = vim.fn.stdpath("config") .. "/lua/" .. pluginDir

for name, type in vim.fs.dir(pluginPath) do
	assert(not name:find("%..*%.lua"), "filename must not contain dots due `require`: " .. name)
	if type == "file" and vim.endswith(name, ".lua") then
		safeRequire(pluginDir .. "." .. name:gsub("%.lua$", ""))
	end
end
--------------------------------------------------------------------------------

