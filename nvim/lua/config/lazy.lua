local u = require("config.utils")
--------------------------------------------------------------------------------

-- Bootstrap Lazy.nvim plugin manager https://github.com/folke/lazy.nvim#-installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazyIsInstalled = vim.loop.fs_stat(lazypath) ~= nil
if not lazyIsInstalled then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	}
end
vim.opt.runtimepath:prepend(lazypath)

--------------------------------------------------------------------------------

-- change keymaps for the UI https://github.com/folke/lazy.nvim/blob/main/lua/lazy/view/config.lua
require("lazy.view.config").keys.hover = "o"
require("lazy.view.config").keys.details = "<Tab>"

vim.api.nvim_create_autocmd("FileType", {
	pattern = "lazy",
	callback = function()
		vim.keymap.set(
			"n",
			"gi",
			[[/#<CR>o``]],
			{ buffer = true, remap = true, desc = "󰒲 Open next issue" }
		)
	end,
})

--------------------------------------------------------------------------------

-- DOCS https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
require("lazy").setup("plugins", {
	defaults = { lazy = true },
	lockfile = vim.fn.stdpath("config") .. "/.lazy-lock.json", -- make file hidden

	-- for repos with <pattern>, use local repos if one exists in <path>
	dev = {
		path = os.getenv("HOME") .. "/Repos",
		patterns = { "chrisgrieser" }, -- set `dev = true` for all matching repos
		fallback = true,
	},
	-- colorschemes to use during installation
	install = { colorscheme = { "tokyonight", "nightfox", "habamax" } },
	ui = {
		wrap = true,
		border = vim.g.myBorderStyle,
		pills = false,
		size = { width = 1, height = 0.93 }, -- not full height, so search is visible
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
			-- INFO do not disable `rplugin`, as it breaks plugins like magma.nvim
			disabled_plugins = {
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
-- KEYMAPS

local keymap = u.uniqueKeymap
keymap("n", "<leader>pp", require("lazy").sync, { desc = "󰒲 Lazy Sync" })
keymap("n", "<leader>pl", require("lazy").home, { desc = "󰒲 Lazy" })
keymap("n", "<leader>pi", require("lazy").install, { desc = "󰒲 Lazy Install" })

-- 5s after startup, notify if there many plugin updates
vim.defer_fn(function()
	if not require("lazy.status").has_updates() then return end
	local threshold = 15
	local numberOfUpdates = tonumber(require("lazy.status").updates():match("%d+"))
	if numberOfUpdates < threshold then return end
	local msg = ("󱧕 %s plugin updates"):format(numberOfUpdates)
	u.notify("Lazy", msg)
end, 5000)
