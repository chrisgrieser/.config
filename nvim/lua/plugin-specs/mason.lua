--------------------------------------------------------------------------------
-- INFO – TO PIN VERSIONS
-- 1. uncomment personal registry in mason's `opts`
-- 2. copy mason registry spec with desired version to `personal-mason-registry`
--------------------------------------------------------------------------------

local ensureInstalled = {
	lsps = {
		"bash-language-server", -- also used for zsh
		"efm", -- integration of external linters
		"gh-actions-language-server", -- github actions
		"html-lsp",
		"json-lsp",
		"just-lsp",
		"tombi", -- toml lsp (more modern than taplo)
		"ts_query_ls", -- treesitter query files
		"yaml-language-server",

		"harper-ls", -- natural language linter
		"typos-lsp", -- spellchecker for code
		"ltex-ls-plus", -- natural language linter (LanguageTool, ltex fork)
		"marksman", -- markdown lsp (markdown-oxide is buggy with links to headings)

		"basedpyright", -- python lsp (pyright fork)
		"ruff", -- python linter & formatter
		-- "pyrefly", -- python type checker, still alpha
		-- "ty", -- python type checker, still alpha

		"biome", -- ts/js/json/css linter/formatter
		"eslint-lsp", -- ts/js linter (only Obsidian plugins, otherwise using `biome`)
		"typescript-language-server", -- used via `typescript-tools.nvim`
		-- "tsgo", -- experimental typescript lsp

		"css-lsp",
		"css-variables-language-server", -- support css variables across multiple files
		"emmet-language-server", -- css/html snippets

		"stylua", -- lua formatter
		vim.g.useEmmyluaLsp and "emmylua_ls" or "lua-language-server", -- lua LSP
	},
	linters = {
		"markdownlint", -- via efm
		"shellcheck", -- shell linter via efm PENDING https://github.com/bash-lsp/bash-language-server/issues/663
	},
	formatters = {
		"markdown-toc", -- automatic table-of-contents
		"shfmt", -- shell formatter (via bashls)
	},
	debuggers = {
		"debugpy", -- python
		"js-debug-adapter", -- js/ts
	},
}

local nonMasonLsps = {
	-- Not installed via `mason`, but included in Xcode Command Line Tools
	-- (which are usually installed as pre-requisite for `homebrew` on macOS)
	jit.os == "OSX" and "sourcekit" or nil,
}

--------------------------------------------------------------------------------

---@param msg string
---@param level "info"|"warn"|"error"|"debug"|"trace"
---@param opts? table
local function notify(msg, level, opts)
	if not opts then opts = {} end
	opts.title = "Mason"
	opts.icon = ""
	vim.notify(msg, vim.log.levels[level:upper()], opts)
end

local function enableLsps()
	local installedPacks = require("mason-registry").get_installed_packages()
	local lspConfigNames = vim.iter(installedPacks):fold({}, function(acc, pack)
		table.insert(acc, pack.spec.neovim and pack.spec.neovim.lspconfig)
		return acc
	end)
	vim.lsp.enable(lspConfigNames)
	vim.lsp.enable(nonMasonLsps)
end

---@param pack { name: string, install: function }
---@param version? string if provided, updates to that version
local function installOrUpdate(pack, version)
	local mode = version and ("updating to %s"):format(version) or "installing"
	local msg = ("[%s] %s…"):format(pack.name, mode)
	notify(msg, "info", { id = "mason.install" })

	pack:install({ version = version }, function(success, error)
		if success then
			mode = version and ("updated to %s"):format(version) or "installed"
			msg = ("[%s] %s "):format(pack.name, mode)
			notify(msg, "info", { id = "mason.install" })
		else
			mode = version and "update" or "install"
			msg = ("[%s] failed to %s: %s"):format(pack.name, mode, error)
			notify(msg, "error", { id = "mason.install" })
		end
	end)
end

-- 1. install missing packages
-- 2. update installed ones
-- 3. uninstall unused packages
local function syncPackages()
	local ensurePacks = vim.iter(vim.tbl_values(ensureInstalled)):flatten():totable()
	local masonReg = require("mason-registry")

	masonReg.refresh(function(ok, _)
		if not ok then
			notify("Could not update mason registry.", "error")
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
		assert(#ensurePacks > 10, "< 10 mason packages, aborting uninstalls.")
		local installedPackages = masonReg.get_installed_package_names()
		vim.iter(installedPackages):each(function(packName)
			if vim.tbl_contains(ensurePacks, packName) then return end
			masonReg.get_package(packName):uninstall({}, function(success, error)
				local lvl = success and "info" or "error"
				local msg = success and ("[%s] uninstalled."):format(packName)
					or ("[%s] failed to uninstall: %s"):format(packName, error)
				notify(msg, lvl)
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
		vim.env.npm_config_cache = vim.env.HOME .. "/.cache/npm" -- don't crowd $HOME with `.npm` folder
		require("mason").setup(opts)
		enableLsps()
		vim.defer_fn(syncPackages, 4000)
	end,
	opts = {
		registries = {
			-- personal registry must come first to have priority
			-- "file:" .. vim.fn.stdpath("config") .. "/personal-mason-registry",
			"github:mason-org/mason-registry",
		},
		ui = {
			height = 0.85,
			width = 0.8,
			backdrop = 60,
			icons = {
				package_installed = "✓",
				package_pending = "󰔟",
			},
			keymaps = { -- consistent with keymaps for lazy.nvim
				uninstall_package = "x",
				toggle_help = "?",
				toggle_package_expand = "<Tab>",
			},
		},
	},
}
