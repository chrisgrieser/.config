-- Bootstrap Lazy.nvim plugin manager https://github.com/folke/lazy.nvim#-installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- DOCS https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
require("lazy").setup("plugins", {
	defaults = { lazy = true },
	dev = {
		path = os.getenv("HOME") .. "/Repos",
		fallback = true, -- use remote repo when local repo doesn't exist
	},
	ui = {
		wrap = true,
		border = require("config.utils").borderStyle,
		size = { width = 1, height = 0.92 }, -- full sized, except statusline
	},
	checker = {
		enabled = true, -- automatically check for plugin updates, required for statusline
		notify = false, -- no notice when updates are found, since done via statusline
		frequency = 86400, -- only check for updates every 24 hours
	},
	git = { timeout = 60 }, -- 1min timeout for tasks
	diff = { cmd = "browser" }, -- view diffs with "d" in the browser
	change_detection = { notify = false },
	readme = { enabled = false },
	performance = {
		rtp = {
			disabled_plugins = { -- disable unused builtin plugins from neovim
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

-- remap lazy's K
vim.api.nvim_create_autocmd("FileType", {
	pattern = "lazy",
	callback = function()
		vim.defer_fn(function() vim.keymap.set("n", "K", "6k", { buffer = true }) end, 1)
	end,
})
