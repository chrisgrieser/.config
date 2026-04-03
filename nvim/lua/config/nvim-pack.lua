-- DOCS https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack#many-vim-pack-add
--------------------------------------------------------------------------------

-- TODO
-- * local dev with vim.pack https://www.reddit.com/r/neovim/comments/1s8cbye/the_feature_im_missing_the_most_after_migrating/
-- * mini.icons bug
-- * measure startup time
-- * auto-cleanup unused plugins

--------------------------------------------------------------------------------
local u = require("config.utils")

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

---GLOBAL KEYMAPS---------------------------------------------------------------
u.uniqueKeymap(
	"n",
	"<leader>pl",
	function() vim.ui.open(vim.fn.stdpath("log") .. "/nvim-pack.log") end,
	{ desc = "󰐱 Log of updated plugins" }
)
u.uniqueKeymap("n", "<leader>pp", function() vim.pack.update() end, { desc = "󰐱 Update plugins" })

---NVIM-PACK WINDOW KEYMAPS-----------------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: nvim-pack keymaps",
	pattern = "nvim-pack",
	callback = function()
		u.bufKeymap("n", "q", vim.cmd.quit)
		u.bufKeymap("n", "<CR>", vim.cmd.write, { desc = "󰐱 Confirm update" })
		u.bufKeymap("n", "<C-j>", "]]", { remap = true, desc = "󰐱 Next plugin" })
		u.bufKeymap("n", "<C-k>", "[[", { remap = true, desc = "󰐱 Previous plugin" })
	end,
})
