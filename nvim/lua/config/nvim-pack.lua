-- DOCS
-- https://neovim.io/doc/user/pack/#vim.pack
-- https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
--------------------------------------------------------------------------------
local u = require("config.utils")

-- empty funcs to prevent errors when bisecting plugins (-> lualine/whichkey are disabled)
vim.g.lualineAdd = function() end ---@diagnostic disable-line: duplicate-set-field
vim.g.whichkeyAddSpec = function() end ---@diagnostic disable-line: duplicate-set-field

---HANDLE LOCAL PLUGINS---------------------------------------------------------

-- create dummy package for `packpath`
local dummy = vim.fn.stdpath("data") .. "/symlink-to-local-plugins/"
vim.opt.packpath:prepend(dummy)
vim.fn.mkdir(dummy .. "/pack/core/", "p")
vim.uv.fs_symlink(
	vim.g.localRepos,
	dummy .. "/pack/core/start", -- `start` instead of `opt` to not need to call `:packadd`
	{ dir = true }
)

local localPlugins = vim.iter(vim.fs.dir(vim.g.localRepos))
	:filter(function(_name, type) return type == "directory" end)
	:map(function(name, _type)
		local shortName = name:gsub("%.nvim$", ""):gsub("nvim%-", "")
		return shortName -- my plugin-spec-filenames use short form
	end)
	:totable()

---AUTO-INSTALL AND LOAD--------------------------------------------------------
local pluginSpecDir = "plugin-specs"
local pluginSpecPath = vim.fn.stdpath("config") .. "/lua/" .. pluginSpecDir
vim.iter(vim.fs.dir(pluginSpecPath)):each(function(name, type)
	assert(not name:find("%..*%.lua"), "Filename must not contain dots due `require`: " .. name)
	local basename = name:gsub("%.lua$", "")
	if type ~= "file" or not vim.endswith(name, ".lua") then return end
	local isLocallyAvailable = vim.tbl_contains(localPlugins, basename)

	if isLocallyAvailable then
		-- HACK to load plugin config without triggering `vim.pack.add`
		local orig, noop = vim.pack.add, function() end
		vim.pack.add = noop
		u.safeRequire(pluginSpecDir .. "." .. basename)
		vim.pack.add = orig
		vim.schedule(function()
			local msg = ("[%s] loaded from local repo."):format(basename)
			vim.notify(msg, nil, { title = "nvim-pack", icon = "󰐱" })
		end)
	else
		u.safeRequire(pluginSpecDir .. "." .. basename)
	end
end)

---AUTO-CLEANUP-----------------------------------------------------------------
vim.api.nvim_create_autocmd("VimEnter", { -- VimEnter to not uninstall plugins still installing
	desc = "User: auto-cleanup unused plugins",
	callback = function()
		vim.defer_fn(function()
			local outdatedPlugins = vim.iter(vim.pack.get())
				:filter(function(p) return not p.active end)
				:map(function(p) return p.spec.name end)
				:totable()
			if #outdatedPlugins == 0 then return end
			assert(#outdatedPlugins <= 10, "Not uninstalling more than 10 plugins at once.")
			vim.pack.del(outdatedPlugins)
		end, 1000)
	end,
})

---GLOBAL KEYMAPS---------------------------------------------------------------
u.uniqKeymap("n", "<leader>pl", function()
	local data = vim.pack.get()
	local all = vim.iter(data):map(function(p) return "* " .. p.spec.name end):join("\n")
	vim.notify(all, nil, { title = #data .. " plugins (nvim-pack)", icon = "󰐱", timeout = false })
end, { desc = "󰐱 List plugins" })

u.uniqKeymap("n", "<leader>pL", function()
	vim.cmd.edit(vim.fn.stdpath("log") .. "/nvim-pack.log")
	vim.schedule(function()
		vim.bo.filetype = "nvim-pack"
		vim.cmd.normal { "G", bang = true } -- bottom of file
		vim.fn.search("========== Update", "b") -- goto last update
	end)
end, { desc = "󰐱 Log of updates" })

u.uniqKeymap(
	"n",
	"<leader>pr",
	function() vim.pack.update(nil, { offline = true, target = "lockfile" }) end,
	{ desc = "󰐱 Restore from lockfile" }
)

u.uniqKeymap(
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
		u.bufKeymap("n", "<CR>", vim.cmd.write, { desc = "󰐱 Confirm update" })
		u.bufKeymap("n", "<C-j>", "]]", { remap = true, desc = "󰐱 Next plugin" })
		u.bufKeymap("n", "<C-k>", "[[", { remap = true, desc = "󰐱 Previous plugin" })
		u.bufKeymap("n", "gi", openCommitOrIssue, { desc = "󰐱 Open commit or issue" })
	end,
})
