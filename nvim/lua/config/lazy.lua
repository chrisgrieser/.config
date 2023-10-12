-- Bootstrap Lazy.nvim plugin manager https://github.com/folke/lazy.nvim#-installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazyIsInstalled = vim.loop.fs_stat(lazypath)
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

-- change lazy keymaps
vim.api.nvim_create_autocmd("FileType", {
	pattern = "lazy",
	callback = function()
		vim.defer_fn(function()
			vim.keymap.set("n", "K", "6k", { buffer = true })
			vim.keymap.set("n", "<Tab>", "<CR>", { buffer = true, remap = true })
		end, 1)
	end,
})

-- DOCS https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
require("lazy").setup("plugins", {
	defaults = { lazy = true },
	dev = { -- use remote repo when local repo doesn't exist
		path = os.getenv("HOME") .. "/Repos",
		patterns = { "chrisgrieser" }, -- set `dev = true` for all my repos
		fallback = true,
	},
	ui = {
		wrap = true,
		border = require("config.utils").borderStyle,
		size = {
			width = 0.98, -- fixes breaking in word
			height = 1,
		},
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
			-- disable unused builtin plugins from neovim
			disabled_plugins = {
				"man",
				"matchparen",
				"matchit",
				"netrw",
				"netrwPlugin",
				"gzip",
				"zip",
				"tar",
				"tarPlugin",
				"tutor",
				"rplugin",
				"health",
				"tohtml",
				"zipPlugin",
			},
		},
	},
})

--------------------------------------------------------------------------------
-- KEYMAPS
local keymap = require("config.utils").uniqueKeymap
keymap("n", "<leader>pp", require("lazy").sync, { desc = "󰒲 Lazy Update" })
keymap("n", "<leader>ph", require("lazy").home, { desc = "󰒲 Lazy Overview" })
keymap("n", "<leader>pi", require("lazy").install, { desc = "󰒲 Lazy Install" })

-- 5s after startup, notify if there many plugin updates
vim.defer_fn(function()
	if not require("lazy.status").has_updates() then return end
	local threshold = 15
	local numberOfUpdates = tonumber(require("lazy.status").updates():match("%d+"))
	if numberOfUpdates < threshold then return end
	vim.notify(
		("󱧕 %s plugin updates"):format(numberOfUpdates),
		vim.log.levels.INFO,
		{ title = "Lazy" }
	)
end, 5000)
