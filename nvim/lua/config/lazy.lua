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
		vim.fn.getchar() -- wait for keypress
		os.exit(1)
	end
end
vim.opt.runtimepath:prepend(lazypath)
--------------------------------------------------------------------------------

require("lazy").setup {
	spec = { import = "plugin-specs" },
	defaults = { lazy = true },
	lockfile = vim.fn.stdpath("config") .. "/.lazy-lock.json", -- make lockfile hidden
	dev = {
		patterns = { "nvim", "blink.cmp" }, -- for repos matching `patterns`… (`nvim` = all nvim repos)
		path = vim.g.localRepos, -- …use local repo, if one exists in `path`…
		fallback = true, -- …and if not, fallback to fetching from GitHub
	},
	install = {
		-- load one of these during installation at startup
		colorscheme = { "tokyonight-moon", "nightfox", "gruvbox-material", "habamax" },
	},
	git = {
		log = { "--since=4 days ago" }, -- `:Lazy log` shows commits since last x days
	},
	ui = {
		title = " 󰒲 lazy.nvim ",
		wrap = true,
		border = vim.o.winborder, -- PENDING https://github.com/folke/lazy.nvim/issues/1951
		pills = false,
		backdrop = 60,
		size = { width = 0.85, height = 0.85 },
		custom_keys = {
			["gi"] = {
				function(plugin)
					local repo = plugin.url:gsub("%.git$", "")
					local line = vim.api.nvim_get_current_line()
					local issue = line:match("#(%d+)")
					local commit = line:match(("%x"):rep(6) .. "+") -- `%x` = hex/hash char
					if not issue and not commit then return end
					local url = repo .. (issue and "/issues/" .. issue or "/commit/" .. commit)
					vim.ui.open(url)
				end,
				desc = " Open issue/commit",
			},
		},
	},
	checker = {
		enabled = true, -- automatically check for plugin updates
		frequency = 60 * 60 * 24 * 7, -- = 7 days
	},
	diff = { cmd = "terminal_git" }, -- view diffs with `delta` (cursor needs to be on hash)
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
-- FIXES
local group = vim.api.nvim_create_augroup("lazynvim-fixes", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
	desc = "User: winfixbuf for lazy window",
	group = group,
	pattern = "lazy",
	callback = function() vim.wo.winfixbuf = true end,
})

-- FIX Backdrop
-- PENDING https://github.com/folke/lazy.nvim/issues/1951
vim.api.nvim_create_autocmd("FileType", {
	desc = "User: fix backdrop for lazy window",
	pattern = "lazy_backdrop",
	group = group,
	callback = function(ctx)
		local win = vim.fn.win_findbuf(ctx.buf)[1]
		vim.api.nvim_win_set_config(win, { border = "none" })
	end,
})

--------------------------------------------------------------------------------

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
	local alreadyMapped = {}
	local plugins = require("lazy").plugins()

	-- 1) each plugin
	vim.iter(plugins):each(function(plugin)
		if not plugin.keys then return end

		-- 2) each keymap of a plugin (only none-ft-specific keymaps)
		vim.iter(plugin.keys)
			:filter(function(lazyKey) return lazyKey.ft == nil end)
			:each(function(lazyKey)
				local lhs = lazyKey[1] or lazyKey
				local modes = lazyKey.mode or "n" ---@type string|string[]
				if type(modes) ~= "table" then modes = { modes } end

				-- 3) each mode of a keymap
				vim.iter(modes):each(function(mode)
					if not alreadyMapped[mode] then alreadyMapped[mode] = {} end
					if alreadyMapped[mode][lhs] then
						local msg = ("[[%s]] %s"):format(mode, lhs)
						local opts = { title = "Duplicate keymap", timeout = false }
						vim.notify(msg, vim.log.levels.WARN, opts)
					else
						alreadyMapped[mode][lhs] = true
					end
				end)
			end)
	end)
end

vim.defer_fn(checkForDuplicateKeys, 5000)
