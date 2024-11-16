-- BOOTSTRAP https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local lazyLocallyAvailable = vim.uv.fs_stat(lazypath) ~= nil
if not lazyLocallyAvailable then
	local repo = "https://github.com/folke/lazy.nvim.git"
	local out =
		vim.system({ "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath }):wait()
	if out.code ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit…" },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
--------------------------------------------------------------------------------

-- DOCS https://lazy.folke.io/configuration
require("lazy").setup {
	spec = { import = "plugins" }, -- = use specs stored in `./lua/plugins`
	defaults = { lazy = true },
	lockfile = vim.fn.stdpath("config") .. "/.lazy-lock.json", -- make lockfile hidden
	dev = { ---@diagnostic disable-line: assign-type-mismatch faulty annotation
		patterns = { "nvim" }, -- for repos matching `patterns`… (`nvim` = all nvim repos)
		path = vim.g.localRepos, -- …use local repo, if one exists in `path`…
		fallback = true, -- …and if not, fallback to fetching from GitHub
	},
	git = {
		log = { "--since=7 days ago" }, -- Lazy log shows commits since last x days
		cooldown = 120, -- seconds before a plugin is updated again
	},
	ui = {
		title = " 󰒲 lazy.nvim ",
		wrap = true,
		border = vim.g.borderStyle,
		pills = false,
		size = { width = 0.85, height = 0.85 },
		backdrop = 50, -- 0-100
		custom_keys = {
			["<localleader>l"] = false,
			["<localleader>t"] = false,
			["<localleader>i"] = false,
			["gi"] = {
				function(plug)
					local url = plug.url:gsub("%.git$", "")
					local line = vim.api.nvim_get_current_line()
					local issue = line:match("#(%d+)")
					local commit = line:match(("%x"):rep(6) .. "+")
					if issue then
						vim.ui.open(url .. "/issues/" .. issue)
					elseif commit then
						vim.ui.open(url .. "/commit/" .. commit)
					end
				end,
				desc = " Open issue/commit",
			},
		},
	},
	checker = {
		enabled = true, -- automatically check for plugin updates
		frequency = 60 * 60 * 24 * 7, -- = 7 days
	},
	diff = { cmd = "browser" }, -- view diffs with "d" in the browser
	change_detection = { notify = false },
	readme = { enabled = false },
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

-- KEYMAPS FOR LAZY UI
-- https://github.com/folke/lazy.nvim/blob/main/lua/lazy/view/config.lua
require("lazy.view.config").keys.hover = "o" -- prevent Lazy overwriting `K`
require("lazy.view.config").keys.details = "<Tab>"

--------------------------------------------------------------------------------
-- KEYMAPS FOR NVIM TRIGGERING LAZY
local keymap = require("config.utils").uniqueKeymap

keymap("n", "<leader>pp", require("lazy").sync, { desc = "󰒲 Lazy Sync" })
keymap("n", "<leader>pl", require("lazy").home, { desc = "󰒲 Lazy Home" })
keymap("n", "<leader>pi", require("lazy").install, { desc = "󰒲 Lazy Install" })

local pluginTypeIcons = {
	["editing-support"] = "󰏫",
	["files-and-buffers"] = "󰞇",
	["appearance"] = "",
	["refactoring"] = "󱗘",
	["lsp-plugins"] = "󰒕",
	["lsp-config"] = "󰒕",
	["ai-plugins"] = "󰚩",
	["git-plugins"] = "󰊢",
	["treesitter"] = "",
	["scissors"] = "󰩫",
	["blink-cmp"] = "󰩫",
	["lazy.nvim"] = "󰒲",
	["themes"] = "",
	["notification"] = "󰎟",
	["folding"] = "󰘖",
	["mason"] = "",
	["motions-and-textobjects"] = "󱡔",
	["telescope-config"] = "󰭎",
	["lualine"] = " ",
}

keymap("n", "g,", function()
	vim.api.nvim_create_autocmd("FileType", {
		desc = "User (once): Colorize icons in `TelescopeResults`",
		once = true,
		pattern = "TelescopeResults",
		callback = function() vim.fn.matchadd("Title", [[^..\zs.]]) end,
	})
	local specRoot = require("lazy.core.config").options.spec.import
	local specPath = vim.fn.stdpath("config") .. "/lua/" .. specRoot
	local specFiles = vim.fs.dir(specPath)

	local allPlugins = vim.iter(specFiles):fold({}, function(acc, name, _)
		if not vim.endswith(name, ".lua") then return acc end
		local moduleName = name:gsub("%.lua$", "")
		local module = require(specRoot .. "." .. moduleName)
		if type(module[1]) == "string" then module = { module } end
		local plugins = vim.iter(module)
			:map(function(plugin) return { repo = plugin[1], module = moduleName } end)
			:totable()
		return vim.list_extend(acc, plugins)
	end)

	vim.ui.select(allPlugins, {
		prompt = "󰒲 Goto Config",
		format_item = function(plugin)
			local icon = pluginTypeIcons[plugin.module] or "󰒓"
			return icon .. " " .. vim.fs.basename(plugin.repo)
		end,
	}, function(plugin)
		if not plugin then return end
		local filepath = specPath .. "/" .. plugin.module .. ".lua"
		local repo = plugin.repo:gsub("/", "\\/") -- escape slashes for `:edit`
		vim.cmd(("edit +/%q %s"):format(repo, filepath))
	end)
end, { desc = "󰒲 Goto Plugin Config" })

keymap("n", "gp", function()
	vim.ui.select(
		require("lazy").plugins(),
		{ prompt = "󰒲 Local Code", format_item = function(plugin) return plugin.name end },
		function(plugin)
			if not plugin then return end
			require("telescope.builtin").find_files { prompt_title = plugin.name, cwd = plugin.dir }
		end
	)
end, { desc = "󰒲 Local Plugin Code" })

--------------------------------------------------------------------------------
-- TEST CHECK FOR DUPLICATE KEYS

local function checkForDuplicateKeys()
	---@param lazyKey {mode?: string|table}
	---@param mode string
	---@return boolean
	local function isMode(lazyKey, mode)
		if not lazyKey.mode then return mode == "n" end
		if type(lazyKey.mode) == "string" then return lazyKey.mode == mode end
		if type(lazyKey.mode) == "table" then return vim.tbl_contains(lazyKey.mode, mode) end ---@diagnostic disable-line: param-type-mismatch
		return false
	end

	local allKeys = { n = {}, x = {}, o = {}, i = {} }
	local allModes = vim.tbl_keys(allKeys)

	local plugins = require("lazy").plugins()
	vim.iter(plugins):each(function(plugin)
		vim
			.iter(plugin.keys or {})
			:filter(function(key) return key.ft == nil end) -- not ft-specific keys
			:each(function(lazyKey)
				local lhs = lazyKey[1] or lazyKey -- keys can be just a string
				for _, mode in ipairs(allModes) do
					if isMode(lazyKey, mode) then
						if vim.tbl_contains(allKeys[mode], lhs) then
							vim.notify(("Duplicate %smap: %s"):format(mode, lhs), vim.log.levels.WARN)
						else
							table.insert(allKeys[mode], lhs)
						end
					end
				end
			end)
	end)
end

vim.defer_fn(checkForDuplicateKeys, 5000)
