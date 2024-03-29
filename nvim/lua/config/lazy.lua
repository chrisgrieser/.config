local keymap = require("config.utils").uniqueKeymap
local notify = require("config.utils").notify
--------------------------------------------------------------------------------

-- Bootstrap Lazy.nvim plugin manager https://github.com/folke/lazy.nvim#-installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazyIsInstalled = vim.loop.fs_stat(lazypath) ~= nil
if not lazyIsInstalled then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system { "git", "clone", "--filter=blob:none", lazyrepo, "--branch=stable", lazypath }
end
vim.opt.runtimepath:prepend(lazypath)

--------------------------------------------------------------------------------

-- change keymaps for the UI https://github.com/folke/lazy.nvim/blob/main/lua/lazy/view/config.lua
require("lazy.view.config").keys.hover = "o"
require("lazy.view.config").keys.details = "<Tab>"

vim.api.nvim_create_autocmd("FileType", {
	pattern = "lazy",
	callback = function()
		local opts = { buffer = true, remap = true, desc = "󰒲 Open next issue" }
		vim.keymap.set("n", "gi", [[/#<CR>o``]], opts)
	end,
})

--------------------------------------------------------------------------------

-- DOCS https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
require("lazy").setup("plugins", {
	defaults = { lazy = true },
	lockfile = vim.fn.stdpath("config") .. "/.lazy-lock.json", -- make file hidden

	-- for repos matching <patterns>, use local repos if one exists in <path>
	dev = {
		path = os.getenv("HOME") .. "/Repos",
		patterns = { "chrisgrieser" },
		fallback = true,
	},
	-- colorschemes to use during installation
	install = { colorscheme = { "tokyonight", "dawnfox", "habamax" } },
	ui = {
		wrap = true,
		border = vim.g.borderStyle,
		pills = false,
		size = { width = 0.85, height = 0.85 },
		backdrop = 70, -- 0-100 opacity
	},
	checker = {
		enabled = true, -- automatically check for plugin updates
		notify = false, -- done on my own to use minimum condition for less noise
		frequency = 60 * 60 * 24, -- = 1 day
	},
	diff = { cmd = "browser" }, -- view diffs with "d" in the browser
	change_detection = { notify = false },
	readme = { enabled = false },
	performance = {
		rtp = {
			-- Disable unused builtin plugins from neovim
			disabled_plugins = {
				"rplugin", -- comment out for `:UpdateRemotePlugins` (e.g. magma.nvim)
				"matchparen",
				"matchit",
				"netrwPlugin",
				"man",
				"tutor",
				"health",
				"tohtml",
				"gzip",
				"zipPlugin",
				"tarPlugin",
			},
		},
	},
})

--------------------------------------------------------------------------------

keymap("n", "<leader>pp", require("lazy").sync, { desc = "󰒲 Lazy Sync" })
keymap("n", "<leader>pl", require("lazy").home, { desc = "󰒲 Lazy" })
keymap("n", "<leader>pi", require("lazy").install, { desc = "󰒲 Lazy Install" })

keymap("n", "g,", function ()
	local plugins = require("lazy").plugins()
	vim.ui.select(plugins, {
		prompt = "󰣖 Select Plugin:",
		format_item = function(plugin) return vim.fs.basename(plugin[1]) end,
	}, function(plugin)
		if not plugin then return end
		local module = plugin._.module:gsub("%.", "/")
		local filepath = vim.fn.stdpath("config") .. "/lua/" .. module .. ".lua"
		local repo = plugin[1]:gsub("/", "\\/") -- escape for `:edit`
		vim.cmd(("edit +/%q %s"):format(repo, filepath))
	end)
end, { desc = "󰣖 Goto Plugin Config" })

--------------------------------------------------------------------------------

local function checkForPluginUpdates()
	if not require("lazy.status").has_updates() then return end
	local threshold = 20
	local numberOfUpdates = tonumber(require("lazy.status").updates():match("%d+"))
	if numberOfUpdates < threshold then return end
	notify("Lazy", ("󱧕 %s plugin updates"):format(numberOfUpdates))
end

local function checkForDuplicateKeys()
	local modes = { "n", "x", "o", "i" }

	---@param lazyKey {mode?: string|table}
	---@param mode string
	---@return boolean
	local function isMode(lazyKey, mode)
		if not lazyKey.mode then return mode == "n" end
		if type(lazyKey.mode) == "string" then return lazyKey.mode == mode end
		if type(lazyKey.mode) == "table" then return vim.tbl_contains(lazyKey.mode, mode) end ---@diagnostic disable-line: param-type-mismatch
		return false
	end

	local allKeys = {}
	for _, mode in ipairs(modes) do
		allKeys[mode] = {}
	end
	for _, plugin in ipairs(require("lazy").plugins()) do
		local globalKeys = vim.tbl_filter(function(key) return key.ft == nil end, plugin.keys or {})

		for _, lazyKey in ipairs(globalKeys) do
			for _, mode in ipairs(modes) do
				local lhs = lazyKey[1] or lazyKey
				if isMode(lazyKey, mode) then
					if vim.tbl_contains(allKeys[mode], lhs) then
						notify("Lazy", ("Duplicate %smap: %s"):format(mode, lhs), "warn")
					else
						table.insert(allKeys[mode], lhs)
					end
				end
			end
		end
	end
end

vim.defer_fn(checkForPluginUpdates, 10000)
vim.defer_fn(checkForDuplicateKeys, 5000)
