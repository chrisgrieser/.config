local ensureInstalled = {
	lsps = {
		"basedpyright", -- python lsp (pyright fork)
		"bash-language-server", -- also used for zsh
		"biome", -- ts/js/json/css linter/formatter
		"css-variables-language-server", -- support css variables across multiple files
		"css-lsp",
		"efm", -- integration of external linter/formatter
		"emmet-language-server", -- css/html snippets
		-- "emmylua_ls", -- improved lua LSP, BUG disabled since LSP still has bugs
		"harper-ls", -- natural language linter
		"html-lsp",
		"json-lsp",
		"just-lsp",
		"ltex-ls-plus", -- LanguageTool: natural language linter (ltex fork)
		"lua-language-server",
		"marksman", -- Markdown lsp
		"ruff", -- python linter & formatter
		"taplo", -- toml lsp
		"typescript-language-server",
		"ts_query_ls", -- Treesitter query files
		"typos-lsp", -- spellchecker for code
		"yaml-language-server",
	},

	linters = {
		"markdownlint", -- efm
		"shellcheck", -- used by bashls/efm for diagnostics, PENDING https://github.com/bash-lsp/bash-language-server/issues/663
	},

	formatters = {
		"markdown-toc", -- automatic table-of-contents (via efm)
		"shfmt", -- shell formatter (via bashls)
		"stylua", -- lua formatter (via efm)
	},

	debuggers = {
		"debugpy", -- python debugger (via nvim-dap-python)
	},
}

local nonMasonLsps = {
	-- Not installed via `mason`, but included in Xcode Command Line Tools (which
	-- are installed on macOS-dev devices as they are needed for `homebrew`)
	jit.os == "OSX" and "sourcekit" or nil,
}

--------------------------------------------------------------------------------

local function notify(msg, level, opts)
	i
	vim.notf
end

local function enableLsps()
	local installedPacks = require("mason-registry").get_installed_packages()
	local lspConfigNames = vim.iter(installedPacks)
		:filter(function(pack) return vim.list_contains(pack.spec.categories, "LSP") end)
		:map(function(pack)
			local lspConfigName = pack.spec.neovim and pack.spec.neovim.lspconfig
			if lspConfigName then return lspConfigName end
			local msg = pack.name .. " has no `neovim` entry"
			vim.notify(msg, vim.log.levels.WARN, { title = "Mason" })
		end)
		:totable()
	vim.lsp.enable(lspConfigNames)
	vim.lsp.enable(nonMasonLsps)
end

---@param pack Package
---@param version? string
local function installOrUpdate(pack, version)
	local notifyOpts = { title = "Mason", icon = "", id = "mason.install" }

	local preMsg = version and ("[%s] updating to %s…"):format(pack.name, version)
		or ("[%s] installing…"):format(pack.name)
	vim.notify(preMsg, nil, notifyOpts)

	pack:install({ version = version }, function(success, result)
		if success then
			notifyOpts.icon = ""
			local mode = version and "updated" or "installed"
			local postMsg = ("[%s] %s."):format(pack.name, mode)
			vim.notify(postMsg, nil, notifyOpts)
		else
			local mode = version and "update" or "install"
			local postMsg = ("[%s] failed to %s: %s"):format(pack.name, mode, result)
			vim.notify(postMsg, vim.log.levels.ERROR, notifyOpts)
		end
	end)
end

-- 1. install missing packages
-- 2. update installed ones
-- 3. uninstall unused packages
local function syncPackages()
	local ensurePacks = vim.iter(vim.tbl_values(ensureInstalled)):flatten():totable()
	assert(#ensurePacks > 10, "< 10 mason packages, aborting uninstalls.") -- safety net

	local masonReg = require("mason-registry")
	masonReg.refresh(function(ok, _)
		if not ok then
			vim.notify("Could not update mason registry.", vim.log.levels.ERROR, { title = "Mason" })
			return
		end
		-- auto-install missing packages & auto-update installed ones
		vim.iter(ensurePacks):each(function(packName)
			if not masonReg.has_package(packName) then return end
			local pack = masonReg.get_package(packName)
			if pack:is_installed() then
				local latestVersion = pack:get_latest_version()
				local version = pack:get_installed_version()
				if latestVersion ~= version then installOrUpdate(pack, latestVersion) end
			else
				installOrUpdate(pack)
			end
		end)

		-- auto-clean unused packages
		local installedPackages = masonReg.get_installed_package_names()
		vim.iter(installedPackages):each(function(packName)
			if vim.tbl_contains(ensurePacks, packName) then return end
			masonReg.get_package(packName):uninstall({}, function(success, result)
				local lvl = success and vim.log.levels.INFO or vim.log.levels.ERROR
				local msg = success and ("[%s] uninstalled."):format(packName)
					or ("[%s] failed to uninstall: %s"):format(packName, result)
				vim.notify(msg, lvl, { title = "Mason", icon = "󰅗" })
			end)
		end)
	end)
end

--------------------------------------------------------------------------------

return {
	"mason-org/mason.nvim",
	event = "BufReadPre",
	keys = {
		{ "<leader>pm", vim.cmd.Mason, desc = " Mason home" },
	},
	config = function(_, opts)
		vim.env.npm_config_cache = vim.env.HOME .. "/.cache/npm" -- don't crowd $HOME with `/.npm`
		require("mason").setup(opts)
		enableLsps()
		vim.defer_fn(syncPackages, 3000)
	end,
	opts = {
		registries = {
			-- local one must come first to take priority
			-- add my own local registry: https://github.com/mason-org/mason-registry/pull/3671#issuecomment-1851976705
			-- also requires `yq` being available in the system
			-- ("file:%s/personal-mason-registry"):format(vim.fn.stdpath("config")),
			"github:mason-org/mason-registry",
		},
		ui = {
			height = 0.85,
			width = 0.8,
			backdrop = 60,
			icons = { package_installed = "✓", package_pending = "󰔟" },
			keymaps = { -- consistent with keymaps for lazy.nvim
				uninstall_package = "x",
				toggle_help = "?",
				toggle_package_expand = "<Tab>",
			},
		},
	},
}
