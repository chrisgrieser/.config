-- DOCS
-- https://neovim.io/doc/user/pack/#vim.pack
-- https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack#many-vim-pack-add
--------------------------------------------------------------------------------

-- TODO
-- * local dev with vim.pack https://www.reddit.com/r/neovim/comments/1s8cbye/the_feature_im_missing_the_most_after_migrating/
-- * mini.icons bug
-- * measure startup time
-- * auto-cleanup unused plugins
-- * \e[1;31m

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
	"<leader>pL",
	function()
		vim.cmd.edit(vim.fn.stdpath("log") .. "/nvim-pack.log")

	end,
	{ desc = "󰐱 Log of updated plugins" }
)
u.uniqueKeymap(
	"n",
	"<leader>pl",
	function() vim.pack.update(nil, { offline = true }) end,
	{ desc = "󰐱 List plugins" }
)
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
		u.bufKeymap("n", "q", vim.cmd.quit, { desc = "󰐱 Quit" })
		u.bufKeymap("n", "<D-CR>", vim.cmd.write, { desc = "󰐱 Confirm update" })
		u.bufKeymap("n", "<C-j>", "]]", { remap = true, desc = "󰐱 Next plugin" })
		u.bufKeymap("n", "<C-k>", "[[", { remap = true, desc = "󰐱 Previous plugin" })
		u.bufKeymap("n", "gi", openCommitOrIssue, { desc = "󰐱 Open commit or issue" })
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	desc = "User: nvim-pack log filetype",
	pattern = "log",
	callback = function(ctx)
		if ctx.file == vim.fn.stdpath("log") .. "/nvim-pack.log" then
			vim.bo[ctx.buf].filetype = "nvim-pack"
		end
	end,
})
