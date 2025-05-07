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
		"markdown-toc", -- auto-table-of-contents, used by efm
		"shfmt", -- shell formatter, used by bashls
		"stylua", -- lua formatter, used by efm
	},

	debuggers = {
		"debugpy", -- python debugger, used by nvim-dap-python
	},
}

local enableNonMasonLsp = {}

-- Not installed via `mason`, but included in Xcode Command Line Tools (which
-- are usually installed on macOS-dev devices as they are needed for `homebrew`)
if jit.os == "OSX" then table.insert(enableNonMasonLsp, "sourcekit") end

--------------------------------------------------------------------------------

local function enableLsps()
	local installedPacks = require("mason-registry").get_installed_packages()
	local lspConfigNames = vim.iter(installedPacks)
		:filter(function(pack) return vim.list_contains(pack.spec.categories, "LSP") end)
		:map(function(pack)
			local lspConfigName = pack.spec.neovim and pack.spec.neovim.lspconfig ---@diagnostic disable-line: undefined-field
			if not lspConfigName then
				local msg = pack.name .. " has no `neovim` entry"
				vim.notify(msg, vim.log.levels.WARN, { title = "Mason" })
				return
			end
			return lspConfigName
		end)
		:totable()
	vim.lsp.enable(lspConfigNames)
	vim.lsp.enable(enableNonMasonLsp)
end

-- these helper functions are a simplified version of `mason-tool-installer.nvim`
---@param pack Package
---@param version? string
local function install(pack, version)
	local notifyOpts = { title = "Mason", icon = "", id = "mason.install" }

	local msg = version and ("[%s] updating to %s…"):format(pack.name, version)
		or ("[%s] installing…"):format(pack.name)
	vim.notify(msg, nil, notifyOpts)

	pack:once("install:success", function()
		local msg2 = ("[%s] %s"):format(pack.name, version and "updated." or "installed.")
		notifyOpts.icon = ""
		vim.notify(msg2, nil, notifyOpts)
	end)
	pack:once("install:failed", function()
		local error = "Failed to install [" .. pack.name .. "]"
		vim.notify(error, vim.log.levels.ERROR, notifyOpts)
	end)

	pack:install { version = version }
end

-- 1. install missing packages
-- 2. update installed ones
-- 3. uninstall unused packages
local function syncPackages()
	local ensurePacks = vim.iter(vim.tbl_values(ensureInstalled)):flatten():totable()
	assert(#ensurePacks > 10, "Less than 10 mason packages, aborting uninstalls.")

	local masonReg = require("mason-registry")

	local function refreshCallback()
		-- auto-install missing packages & auto-update installed ones
		vim.iter(ensurePacks):each(function(packName)
			if not masonReg.has_package(packName) then return end
			local pack = masonReg.get_package(packName)
			if pack:is_installed() then
				pack:check_new_version(function(hasNewVersion, version)
					if not hasNewVersion then return end
					install(pack, version.latest_version)
				end)
			else
				install(pack)
			end
		end)

		-- auto-clean unused packages
		local installedPackages = masonReg.get_installed_package_names()
		vim.iter(installedPackages):each(function(packName)
			if not vim.tbl_contains(ensurePacks, packName) then
				masonReg.get_package(packName):uninstall()
				local msg = ("[%s] uninstalled."):format(packName)
				vim.notify(msg, nil, { title = "Mason", icon = "󰅗" })
			end
		end)
	end

	-- ensure registry is up-to-date (relevant when using extra personal registry)
	masonReg.refresh(refreshCallback) -- refresh is async when callback is passed
end

--------------------------------------------------------------------------------

return {
	"williamboman/mason.nvim",
	event = "BufReadPre",
	keys = {
		{ "<leader>pm", vim.cmd.Mason, desc = " Mason home" },
	},
	config = function(_, opts)
		vim.env.npm_config_cache = vim.env.HOME .. "/.cache/npm" -- don't crowd $HOME with `.npm` folder

		require("mason").setup(opts)

		enableLsps()
		vim.defer_fn(syncPackages, 3000)

		-- FIX Backdrop
		-- PENDING https://github.com/williamboman/mason.nvim/pull/1900
		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: fix backdrop for mason window",
			pattern = "mason_backdrop",
			callback = function(ctx)
				local win = vim.fn.win_findbuf(ctx.buf)[1]
				vim.api.nvim_win_set_config(win, { border = "none" })
			end,
		})
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
			border = vim.o.winborder,
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
