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
-- config https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
require("lazy").setup("plugins", {
	dev = {
		path = vim.env.ICLOUD .. "/Repos",
		fallback = true, -- use remote repo when local repo doesn't exist
	},
	ui = {
		wrap = true,
		border = require("config.utils").borderStyle,
		size = { width = 1, height = 0.85 }, -- full sized
	},
	checker = {
		enabled = true, -- automatically check for plugin updates, required for statusline
		notify = false, -- don't a notification when new updates are found
		frequency = 86400, -- only check for updates every 24 hours
	},
	diff = { cmd = "browser" }, -- view diffs with "d" in the browser
	change_detection = { notify = false },
	readme = { enabled = false },
	performance = {
		rtp = {
			-- disable unused builtin plugins from neovim
			disabled_plugins = {
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
