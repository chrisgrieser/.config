-- DOCS https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack#many-vim-pack-add
--------------------------------------------------------------------------------

-- TODO
-- * local dev with vim.pack https://www.reddit.com/r/neovim/comments/1s8cbye/the_feature_im_missing_the_most_after_migrating/
-- * mini.icons bug
-- * measure startup time
-- * delete unused plugins

--------------------------------------------------------------------------------
local u = require("config.utils")

vim.g.neovide_progress_bar_height = 30 -- thicker progress bar already during installs

-- empty funcs to prevent errors when bisecting plugins (-> lualine / whichkey are disabled)
vim.g.lualineAdd = function() end ---@diagnostic disable-line: duplicate-set-field
vim.g.whichkeyAddSpec = function() end ---@diagnostic disable-line: duplicate-set-field

local pluginDir = "plugins"
local pluginPath = vim.fn.stdpath("config") .. "/lua/" .. pluginDir

for name, type in vim.fs.dir(pluginPath) do
	assert(not name:find("%..*%.lua"), "filename must not contain dots due `require`: " .. name)
	if type == "file" and vim.endswith(name, ".lua") then
		u.safeRequire(pluginDir .. "." .. name:gsub("%.lua$", ""))
	end
end

---NVIM-PACK KEYMAPS------------------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: nvim-pack keymaps",
	pattern = "nvim-pack",
	callback = function()
		u.bufKeymap("n", "q", vim.cmd.quit)
		u.bufKeymap("n", "<D-s>", vim.cmd.write) -- = confirm update
	end,
})
