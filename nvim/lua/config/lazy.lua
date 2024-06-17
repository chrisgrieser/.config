local keymap = require("config.utils").uniqueKeymap
local notify = require("config.utils").notify
--------------------------------------------------------------------------------

-- BOOTSTRAP LAZY.NVIM
-- https://github.com/folke/lazy.nvim#-installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if vim.uv.fs_stat(lazypath) == nil then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.system({ "git", "clone", "--filter=blob:none", lazyrepo, "--branch=stable", lazypath }):wait()
end
vim.opt.runtimepath:prepend(lazypath)

--------------------------------------------------------------------------------

-- DOCS https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
require("lazy").setup("plugins", {
	defaults = { lazy = true },
	lockfile = vim.fn.stdpath("config") .. "/.lazy-lock.json", -- make file hidden
	dev = {
		patterns = { "chrisgrieser" }, -- for repos matching `patterns` …
		path = vim.g.localRepos, -- …use local repo, if one exists in `path` …
		fallback = true, -- … and if not, fallback to fetching from GitHub
	},
	git = {
		log = { "--since=3 days ago" }, -- Lazy Log shows commits since last 3 days
		-- log = { "-8" } -- default
	},
	ui = {
		wrap = true,
		border = vim.g.borderStyle,
		pills = false,
		size = { width = 0.85, height = 0.85 },
		backdrop = 50, -- 0-100 opacity
		custom_keys = {
			["<localleader>l"] = false,
			["<localleader>t"] = false,
			["gx"] = { function(plugin) vim.ui.open(plugin.url) end, desc = "󰖟 Plugin repo" },
			["gi"] = { function(plugin)
				local issue = vim.api.nvim_get_current_line():match("#(%d+)")
				vim.ui.open(plugin.url .. "/issues/" .. issue)
			end, desc = " Open issue" },
			["go"] = {
				function(plugin)
					vim.cmd.close()
					require("telescope.builtin").find_files {
						prompt_title = plugin.name,
						cwd = plugin.dir,
					}
				end,
				desc = "󰭎 Open plugin code",
			},
		},
	},
	checker = {
		enabled = true, -- automatically check for plugin updates
		notify = false, -- done on my own to use minimum condition for less noise
		frequency = 60 * 60 * 24, -- = 1 day
	},
	diff = { cmd = "browser" }, -- view diffs with "d" in the browser
	change_detection = { enabled = false }, -- messes up writing config
	readme = { enabled = false },
	performance = {
		rtp = {
			-- Disable unused builtin plugins from neovim
			disabled_plugins = {
				"rplugin", -- needed when using `:UpdateRemotePlugins` (e.g. magma.nvim)
				-- stylua: ignore
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

-- KEYMAPS FOR LAZY UI
-- https://github.com/folke/lazy.nvim/blob/main/lua/lazy/view/config.lua
require("lazy.view.config").keys.hover = "o"
require("lazy.view.config").keys.details = "<Tab>"

--------------------------------------------------------------------------------
-- KEYMAPS
keymap("n", "<leader>pp", require("lazy").sync, { desc = "󰒲 Lazy Sync" })
keymap("n", "<leader>pl", require("lazy").home, { desc = "󰒲 Lazy Home" })
keymap("n", "<leader>pi", require("lazy").install, { desc = "󰒲 Lazy Install" })

local pluginTypeIcons = {
	["editing-support"] = "󰏫 ",
	["appearance"] = " ",
	["lsp-plugins"] = "󰒕 ",
	["lsp-config"] = "󰒕 ",
	["ai-plugins"] = "󰚩 ",
	["git-plugins"] = "󰊢 ",
	["debugger-dap"] = " ",
	["treesitter"] = " ",
	["formatter-conform"] = "󰉿 ",
	["completion-and-snippets"] = " ",
	["lazy.nvim"] = "󰒲 ",
	["themes"] = " ",
	["noice-and-notification"] = "󰎟 ",
	["folding"] = "󰘖 ",
	["mason"] = " ",
	["motions-and-textobjects"] = "󱡔 ",
	["telescope-config"] = "󰭎 ",
	["lualine"] = "󰇘 ",
}

-- goto plugin config, replaces telescope-lazy-plugins.nvim
keymap("n", "g,", function()
	local specRoot = require("lazy.core.config").options.spec.import
	local function getModule(plugin)
		local module = (plugin._.super and not plugin._.super._.dep) and plugin._.super._.module
			or plugin._.module
		if not module then return "lazy.nvim" end
		return module:sub(#specRoot + 2)
	end

	vim.api.nvim_create_autocmd("FileType", {
		once = true,
		pattern = "TelescopeResults",
		callback = function() vim.fn.matchadd("Title", [[^..\zs.]]) end,
	})

	vim.ui.select(require("lazy").plugins(), {
		prompt = "󰣖 Select Plugin:",
		format_item = function(plugin)
			local icon = pluginTypeIcons[getModule(plugin)] or "󰣖 "
			return icon .. vim.fs.basename(plugin[1])
		end,
	}, function(plugin)
		if not plugin then return end
		if plugin[1] == "folke/lazy.nvim" then
			local pathOfThisFile = debug.getinfo(1).source:sub(2)
			vim.cmd.edit(pathOfThisFile)
		else
			local module = getModule(plugin):gsub("%.", "/")
			local filepath = vim.fn.stdpath("config") .. ("/lua/%s/%s.lua"):format(specRoot, module)
			local repo = plugin[1]:gsub("/", "\\/") -- escape slashes for `:edit`
			vim.cmd(("edit +/%q %s"):format(repo, filepath))
		end
	end)
end, { desc = "󰒲 Goto Plugin Config" })

--------------------------------------------------------------------------------
-- CHECK FOR UPDATES AND DUPLICATE KEYS

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
	vim.iter(require("lazy").plugins()):each(function(plugin)
		vim
			.iter(plugin.keys or {})
			:filter(function(key) return key.ft == nil end) -- not ft-specific keys
			:each(function(lazyKey)
				local lhs = lazyKey[1] or lazyKey -- keys can be just a string
				for _, mode in ipairs(modes) do
					if isMode(lazyKey, mode) then
						if vim.tbl_contains(allKeys[mode], lhs) then
							notify("Lazy", ("Duplicate %smap: %s"):format(mode, lhs), "warn")
						else
							table.insert(allKeys[mode], lhs)
						end
					end
				end
			end)
	end)
end

vim.defer_fn(checkForPluginUpdates, 10000)
vim.defer_fn(checkForDuplicateKeys, 4000)
