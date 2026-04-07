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
vim.opt.packpath:prepend(dummy) -- prepend to prioritize local plugins
vim.fn.mkdir(dummy .. "/pack/core/", "p")
vim.uv.fs_symlink(vim.g.localRepos, dummy .. "/pack/core/opt", { dir = true })

local localPlugins = {}
for name, type in vim.fs.dir(vim.g.localRepos) do
	if type == "directory" then
		local shortName = name:gsub("%.nvim$", ""):gsub("nvim%-", "")
		localPlugins[shortName] = name -- my plugin-specs use the short plugin name
	end
end

---AUTO-INSTALL AND LOAD--------------------------------------------------------
local pluginSpecDir = "plugin-specs"
local pluginSpecPath = vim.fn.stdpath("config") .. "/lua/" .. pluginSpecDir
vim.iter(vim.fs.dir(pluginSpecPath)):each(function(name, type)
	assert(not name:find("%..*%.lua"), "Filename must not contain dots due `require`: " .. name)
	if type ~= "file" or not vim.endswith(name, ".lua") then return end
	local basename = name:gsub("%.lua$", "") -- = the short name
	local localName = localPlugins[basename]

	if localName then
		-- HACK to load plugin config without triggering `vim.pack.add`
		local orig, noop = vim.pack.add, function() end
		vim.pack.add = noop

		vim.cmd.packadd(localName)
		u.safeRequire(pluginSpecDir .. "." .. basename)

		vim.pack.add = orig
		vim.schedule(function()
			local msg = ("[%s] loaded from local repo."):format(localName)
			vim.notify(msg, nil, { title = "nvim-pack", icon = "󰐱" })
		end)
	else
		u.safeRequire(pluginSpecDir .. "." .. basename)
	end
end)

---AUTO-CLEANUP-----------------------------------------------------------------
vim.api.nvim_create_autocmd("FocusLost", { -- on `FocusLost`, since `vim.pack.get()` is blocking?
	desc = "User: auto-cleanup unused plugins",
	once = true,
	callback = function()
		local outdatedPlugins = vim.iter(vim.pack.get())
			:filter(function(p) return not p.active end)
			:map(function(p) return p.spec.name end)
			:totable()
		if #outdatedPlugins == 0 then return end
		assert(#outdatedPlugins <= 10, "Not uninstalling more than 10 plugins at once.")
		vim.pack.del(outdatedPlugins)
	end,
})

---GLOBAL KEYMAPS---------------------------------------------------------------

Keymap {
	"<leader>pl",
	function()
		vim.cmd.edit(vim.fn.stdpath("log") .. "/nvim-pack.log")
		vim.schedule(function()
			vim.bo.filetype = "nvim-pack"
			vim.cmd.normal { "G", bang = true } -- bottom of file
			vim.fn.search("========== Update", "b") -- goto last update
		end)
	end,
	desc = "󰐱 Log of updates",
}

Keymap {
	"<leader>pr",
	function() vim.pack.update(nil, { offline = true, target = "lockfile" }) end,
	desc = "󰐱 Restore from lockfile",
}

Keymap { "<leader>pp", function() vim.pack.update() end, desc = "󰐱 Update plugins" }

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

Keymap { "q", vim.cmd.bdelete, ft = "nvim-pack", nowait = true, desc = "󰐱 Quit" }
Keymap { "<CR>", vim.cmd.write, ft = "nvim-pack", desc = "󰐱 Confirm update" }
Keymap { "<C-j>", "]]", remap = true, ft = "nvim-pack", desc = "󰐱 Next plugin" }
Keymap { "<C-k>", "[[", remap = true, ft = "nvim-pack", desc = "󰐱 Previous plugin" }
Keymap { "gi", openCommitOrIssue, ft = "nvim-pack", desc = "󰐱 Open commit or issue" }

---CONCEAL NOISE-IN NVIM-PACK-WINDOW--------------------------------------------
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: Conceal noise in nvim-pack window",
	pattern = "nvim-pack",
	callback = function(ctx)
		vim.opt_local.foldmethod = "manual"

		local lines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
		local foldlength = 6 -- 6 for `# Updates`, 3 for `# Same`

		for lnum = 1, #lines do
			if vim.startswith(lines[lnum], "## ") then
				local startLn, endLn = lnum, lnum + foldlength
				vim.cmd.fold { range = { startLn, endLn } }
			end
			if vim.startswith(lines[lnum], "# Same") then foldlength = 3 end
		end
	end,
})
