-- DOCS https://lazy.folke.io/configuration
--------------------------------------------------------------------------------
-- BOOTSTRAP https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local repo = "https://github.com/folke/lazy.nvim.git"
	local args = { "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath }
	local out = vim.system(args):wait()
	if out.code ~= 0 then
		vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out.stderr, "ErrorMsg" } }, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.runtimepath:prepend(lazypath)
--------------------------------------------------------------------------------

require("lazy").setup {
	spec = { import = "plugin-specs" },
	defaults = { lazy = true },
	lockfile = vim.fn.stdpath("config") .. "/.lazy-lock.json", -- make lockfile hidden
	dev = { ---@diagnostic disable-line: assign-type-mismatch
		patterns = { "nvim" }, -- for repos matching `patterns`… (`nvim` = all nvim repos)
		path = vim.g.localRepos, -- …use local repo, if one exists in `path`…
		fallback = true, -- …and if not, fallback to fetching from GitHub
	},
	install = {
		-- load one of these during installation at startup
		colorscheme = { "tokyonight-moon", "dawnfox", "habamax" },
	},
	git = {
		log = { "--since=4 days ago" }, -- Lazy log shows commits since last x days
		cooldown = 180, -- seconds before a plugin is updated again
	},
	ui = {
		title = " 󰒲 lazy.nvim ",
		wrap = true,
		border = vim.g.borderStyle,
		pills = false,
		backdrop = 40,
		size = { width = 0.85, height = 0.85 },
		custom_keys = {
			["<localleader>l"] = false,
			["<localleader>t"] = false,
			["<localleader>i"] = false,
			["gi"] = {
				function(plug)
					local url = plug.url:gsub("%.git$", "")
					local line = vim.api.nvim_get_current_line()
					local issue = line:match("#(%d+)")
					local commit = line:match(("%x"):rep(6) .. "+") -- `%x` = hex/hash char
					if issue then
						vim.ui.open(url .. "/issues/" .. issue)
					elseif commit then
						vim.ui.open(url .. "/commit/" .. commit)
					end
				end,
				desc = " Open issue/commit",
			},
		},
	},
	checker = {
		enabled = true, -- automatically check for plugin updates
		frequency = 60 * 60 * 24 * 7, -- = 7 days
	},
	diff = { cmd = "browser" }, -- view diffs in the browser with `d`
	change_detection = { notify = false },
	readme = {
		-- needed to make helpdocs of lazy-loaded plugins available:
		-- https://github.com/folke/lazy.nvim/issues/1777#issuecomment-2529369369
		enabled = true,
		skip_if_doc_exists = false,
	},
	performance = {
		rtp = {
			-- Disable unused builtin plugins from neovim
			-- stylua: ignore
			disabled_plugins = {
				"rplugin", -- needed when using `:UpdateRemotePlugins` (e.g. magma.nvim)
				"netrwPlugin", "man", "tutor", "health", "tohtml", "gzip",
				"zipPlugin", "tarPlugin", "osc52",
			},
		},
	},
}

--------------------------------------------------------------------------------

-- KEYMAPS FOR LAZY-GENERATED HELP FILES IN MARKDOWN
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: Setup for lazy-generated help in markdown",
	pattern = "markdown",
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype == "help" then
			-- inerihit the config of help files
			vim.cmd.source(vim.fn.stdpath("config") .. "/after/ftplugin/help.lua")
		end
	end,
})

-- KEYMAPS FOR LAZY UI
-- https://github.com/folke/lazy.nvim/blob/main/lua/lazy/view/config.lua
require("lazy.view.config").keys.hover = "o" -- prevent Lazy overwriting `K`
require("lazy.view.config").keys.details = "<Tab>"

--------------------------------------------------------------------------------
-- KEYMAPS FOR NVIM TRIGGERING LAZY
local keymap = require("config.utils").uniqueKeymap

keymap("n", "<leader>pp", require("lazy").sync, { desc = "󰒲 Lazy sync" })
keymap("n", "<leader>pl", require("lazy").home, { desc = "󰒲 Lazy home" })
keymap("n", "<leader>pi", require("lazy").install, { desc = "󰒲 Lazy install" })

--------------------------------------------------------------------------------
-- TEST FOR DUPLICATE KEYS on every startup

local function checkForDuplicateKeys()
	---@type fun(lazyKey: {mode?: string|table}): string[]
	local function getModesOfKey(lazyKey)
		if not lazyKey.mode then return {"n"} end
		if type(lazyKey.mode) == "string" then return { lazyKey.mode  } end
		if type(lazyKey.mode) == "table" then return  lazyKey.mode end ---@diagnostic disable-line: param-type-mismatch
	end

	local allKeys = { n = {}, x = {}, o = {}, i = {} }
	local allModes = vim.tbl_keys(allKeys)

	local plugins = require("lazy").plugins()
	vim.iter(plugins):each(function(plugin) -- for each plugin
		vim
			.iter(plugin.keys or {})
			:filter(function(key) return key.ft == nil end) 
			:each(function(lazyKey) -- for each keymap of the plugin
				local lhs = lazyKey[1] or lazyKey
				vim.iter(allModes):each(function(mode) -- for each mode of a keymap
					if not getModesOfKey(lazyKey, mode) then return end
					if allKeys[mode].lhs then
						local msg = ("Duplicate %smap: [%s]"):format(mode, lhs)
						vim.notify(msg, vim.log.levels.WARN, { title = "lazy.nvim", timeout = false })
					else
						allKeys[mode].lhs = true
					end
				end)
			end)
	end)
end

vim.defer_fn(checkForDuplicateKeys, 5000)
