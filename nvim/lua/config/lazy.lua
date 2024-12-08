-- DOCS https://lazy.folke.io/configuration
--------------------------------------------------------------------------------
-- BOOTSTRAP https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	local repo = "https://github.com/folke/lazy.nvim.git"
	local args = { "git", "clone", "--filter=blob:none", "--branch=stable", repo, lazypath }
	local out = vim.system(args):wait()
	if out.code ~= 0 then
		vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
--------------------------------------------------------------------------------

require("lazy").setup {
	spec = { import = "plugin-configs" }, -- = use specs stored in `./lua/plugins`
	defaults = { lazy = true },
	lockfile = vim.fn.stdpath("config") .. "/.lazy-lock.json", -- make lockfile hidden
	dev = { ---@diagnostic disable-line: assign-type-mismatch faulty annotation
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

keymap("n", "<leader>pp", require("lazy").sync, { desc = "󰒲 Lazy sync" })
keymap("n", "<leader>pl", require("lazy").home, { desc = "󰒲 Lazy home" })
keymap("n", "<leader>pi", require("lazy").install, { desc = "󰒲 Lazy install" })

local pluginTypeIcons = {
	["ai-plugins"] = "󰚩",
	["appearance"] = "",
	["colorschemes"] = "",
	["completion-and-snippets"] = "󰩫",
	["editing-support"] = "󰏫",
	["folding"] = "󰘖",
	["git-plugins"] = "󰊢",
	["lsp-plugins"] = "󰒕",
	["lualine"] = "󰇜",
	["mason"] = "",
	["motions-and-textobjects"] = "󱡔",
	["notification"] = "󰎟",
	["refactoring"] = "󱗘",
	["task-and-file-utilities"] = "󰈔",
	["telescope"] = "󰭎",
	["treesitter"] = "",
	["which-key"] = "⌨️",
}

-- GOTO PLUGIN SPEC
-- For nicer selection via `vim.ui.select`: telescope-ui-select OR dressing.nvim
keymap("n", "g,", function()
	vim.api.nvim_create_autocmd("FileType", {
		desc = "User(once): Colorize icons in `TelescopeResults`",
		once = true,
		pattern = "TelescopeResults",
		callback = function() vim.fn.matchadd("Title", [[^..\zs.]]) end,
	})
	-- all specfiles
	local specRoot = require("lazy.core.config").options.spec.import
	local specPath = vim.fn.stdpath("config") .. "/lua/" .. specRoot
	local specFiles = {}
	for name, type in vim.fs.dir(specPath) do
		if type == "file" and vim.endswith(name, ".lua") then table.insert(specFiles, name) end
	end

	-- sort by last modified
	table.sort(specFiles, function(a, b)
		local amtime = vim.uv.fs_stat(specPath .. "/" .. a).mtime.sec
		local bmtime = vim.uv.fs_stat(specPath .. "/" .. b).mtime.sec
		return amtime > bmtime
	end)

	-- get all plugins from the spec files
	local allPlugins = vim.iter(specFiles)
		:map(function(name)
			local moduleName = name:gsub("%.lua$", "")
			local module = require(specRoot .. "." .. moduleName)
			if type(module[1]) ~= "table" then module = { module } end
			local plugins = vim.iter(module)
				:map(function(plugin) return { repo = plugin[1], module = moduleName } end)
				:totable()
			return plugins
		end)
		:flatten()
		:totable()

	-- select plugin
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
		vim.cmd.normal { "zv", bang = true } -- open fold at cursor
	end)
end, { desc = "󰒲 Goto Plugin Config" })

-- GOTO LOCAL PLUGIN CODE
-- REQUIRED telescope.nvim AND (telescope-ui-select OR dressing.nvim)
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
-- TEST FOR DUPLICATE KEYS on every startup

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
							vim.notify_once(
								("Duplicate %smap: [%s]"):format(mode, lhs),
								vim.log.levels.WARN,
								{ title = "Lazy", ft = "text", timeout = false }
							)
						else
							table.insert(allKeys[mode], lhs)
						end
					end
				end
			end)
	end)
end

vim.defer_fn(checkForDuplicateKeys, 5000)
