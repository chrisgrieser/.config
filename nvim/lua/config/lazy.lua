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
-- INFO `.` lazy requires dot as separator to recognize the plugin module
require("lazy").setup("config.load-plugins", {
	defaults = {
		-- version = "*", -- install the latest *stable* versions of plugins
	},
	dev = {
		path = vim.fn.stdpath("config") .. "/my-plugins/",
	},
	ui = {
		border = borderStyle,
		size = { width = 1, height = 1 }, -- full sized
	},
	checker = {
		enabled = true, -- automatically check for plugin updates, required for statusline
		notify = false, -- get a notification when new updates are found
		frequency = 86400, -- check for updates every 24 hours
	},
	change_detection = { notify = false },
	performance = {
		rtp = { 
			disabled_plugins = {
				-- disable unused builtin plugins from neovim
				"gzip",
				"netrwPlugin",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
				"man",
			},
		},
	},
})
