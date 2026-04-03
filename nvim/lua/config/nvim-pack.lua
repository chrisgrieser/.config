-- DOCS
-- https://neovim.io/doc/user/pack/#vim.pack
-- https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack#many-vim-pack-add
--------------------------------------------------------------------------------

-- TODO
-- * local dev with vim.pack https://www.reddit.com/r/neovim/comments/1s8cbye/the_feature_im_missing_the_most_after_migrating/
-- * mini.icons bug
-- * \e[1;31m

--------------------------------------------------------------------------------
local u = require("config.utils")

-- empty funcs to prevent errors when bisecting plugins (-> lualine / whichkey are disabled)
vim.g.lualineAdd = function() end ---@diagnostic disable-line: duplicate-set-field
vim.g.whichkeyAddSpec = function() end ---@diagnostic disable-line: duplicate-set-field

---AUTO-INSTALL AND LOAD--------------------------------------------------------
local pluginDir = "plugins"
local pluginPath = vim.fn.stdpath("config") .. "/lua/" .. pluginDir

for name, type in vim.fs.dir(vim.g.localRepos) do
	if type == "directory" then
		local localPlugin = vim.g.localRepos .. "/" .. name
		local managedPlugin = pluginPath .. "/" .. name
		vim.defer_fn(function() vim.notify(managedPlugin) end, 1000)
		vim.fn.delete(managedPlugin, "rf")
		vim.uv.fs_symlink(localPlugin, managedPlugin)
	end
end

for name, type in vim.fs.dir(pluginPath) do
	assert(not name:find("%..*%.lua"), "Filename must not contain dots due `require`: " .. name)
	if type == "file" and vim.endswith(name, ".lua") then
		u.safeRequire(pluginDir .. "." .. name:gsub("%.lua$", ""))
	end
end

---AUTO-CLEANUP-----------------------------------------------------------------
vim.defer_fn(function()
	local outdatedPlugins = vim.iter(vim.pack.get())
		:filter(function(x) return not x.active end)
		:map(function(x) return x.spec.name end)
		:totable()
	if #outdatedPlugins == 0 then return end
	vim.pack.del(outdatedPlugins)
end, 1000)

---GLOBAL KEYMAPS---------------------------------------------------------------
u.uniqueKeymap("n", "<leader>pl", function()
	local plugData = vim.pack.get()
	local allPlugins = vim.iter(plugData):map(function(x) return "* " .. x.spec.name end):join("\n")
	vim.notify(allPlugins, nil, { title = #plugData .. " plugins", icon = "󰐱", timeout = false })
end, { desc = "󰐱 List plugins" })

u.uniqueKeymap("n", "<leader>pL", function()
	vim.cmd.edit(vim.fn.stdpath("log") .. "/nvim-pack.log")
	vim.schedule(function()
		vim.bo.filetype = "nvim-pack"
		vim.cmd.normal { "G", bang = true } -- bottom of file
		vim.fn.search("========== Update", "b") -- goto last update
	end)
end, { desc = "󰐱 Log of updates" })

u.uniqueKeymap(
	"n",
	"<leader>pr",
	function() vim.pack.update(nil, { offline = true, target = "lockfile" }) end,
	{ desc = "󰐱 Restore from lockfile" }
)

u.uniqueKeymap(
	"n",
	"<leader>pp",
	function() vim.pack.update() end,
	{ desc = "󰐱 Update plugins" }
)

---NVIM-PACK WINDOW KEYMAPS-----------------------------------------------------
local function openCommitOrIssue()
	local curLine = vim.api.nvim_get_current_line()
	local issue = curLine:match("#(%d+)")
	local commit = curLine:match("^> (%x+) ")
	if not issue and not commit then
		vim.notify("No commit or issue on current line.", vim.log.levels.WARN)
		return
	end

	local row = vim.api.nvim_win_get_cursor(0)[1]
	local repoLine
	while row > 1 do
		repoLine = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, false)[1]
		if vim.startswith(repoLine, "Source: ") then break end
		row = row - 1
	end
	assert(repoLine, "No source line found.")
	local repo = repoLine:match("Source: *(%S+)")
	local url = repo .. (issue and "/issues/" .. issue or "/commit/" .. commit)
	vim.ui.open(url)
end

vim.api.nvim_create_autocmd("FileType", {
	desc = "User: nvim-pack keymaps",
	pattern = "nvim-pack",
	callback = function()
		u.bufKeymap("n", "q", vim.cmd.bdelete, { desc = "󰐱 Quit" })
		u.bufKeymap("n", "<D-CR>", vim.cmd.write, { desc = "󰐱 Confirm update" })
		u.bufKeymap("n", "<C-j>", "]]", { remap = true, desc = "󰐱 Next plugin" })
		u.bufKeymap("n", "<C-k>", "[[", { remap = true, desc = "󰐱 Previous plugin" })
		u.bufKeymap("n", "gi", openCommitOrIssue, { desc = "󰐱 Open commit or issue" })
	end,
})
