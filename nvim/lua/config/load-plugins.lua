-- make update progress clear
vim.g.neovide_progress_bar_height = 30

-- empty funcs to prevent errors when bisecting plugins (-> lualine / whichkey are disabled)
vim.g.lualineAdd = function() end ---@diagnostic disable-line: duplicate-set-field
vim.g.whichkeyAddSpec = function() end ---@diagnostic disable-line: duplicate-set-field
--------------------------------------------------------------------------------
local pluginDir = "plugins"
local pluginPath = vim.fn.stdpath("config") .. "/lua/" .. pluginDir
local sRequire = require("config.utils").safeRequire

for name, type in vim.fs.dir(pluginPath) do
	assert(not name:find("%..*%.lua"), "filename must not contain dots due `require`: " .. name)
	if type == "file" and vim.endswith(name, ".lua") then
		sRequire(pluginDir .. "." .. name:gsub("%.lua$", ""))
	end
end
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
	desc = "User: nvim-pack keymaps",
	pattern = "nvim-pack",
	callback = function() vim.keymap.set("n", "q", vim.cmd.quit, { nowait = true, buffer = true }) end,
})
