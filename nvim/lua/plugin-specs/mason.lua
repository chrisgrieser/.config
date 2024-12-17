-- these helper functions are a simplified version of `mason-tool-installer.nvim`

local notifyOpts = { title = "Mason", icon = "", style = "minimal" }

---@param pack Package
---@param version? string
local function install(pack, version)
	local msg = version and ("Updating [%s] to %s"):format(pack.name, version)
		or ("Installing [%s]"):format(pack.name)
	vim.notify(msg, nil, notifyOpts)

	pack:once("install:success", function()
		local type = version and "update" or "install"
		vim.notify(("Successfully %s [%s]"):format(type, pack.name), nil, notifyOpts)
	end)
	pack:once("install:failed", function()
		local error = "Failed to install [" .. pack.name .. "]"
		vim.notify(error, vim.log.levels.ERROR, notifyOpts)
	end)

	pack:install { version = version }
end

-- 1. install missing packages
-- 2. updates installed ones
-- 3. uninstall unused packages
---@param ensurePack string[]
local function syncPackages(ensurePack)
	local masonReg = require("mason-registry")

	-- ensure registry, relevant when using personal registry
	masonReg.refresh()

	-- auto-install missing packages & auto-update installed ones
	vim.iter(ensurePack):each(function(packName)
		if not masonReg.has_package(packName) then return end
		local pack = masonReg.get_package(packName)
		if pack:is_installed() then
			pack:check_new_version(function(hasNewVersion, version)
				if hasNewVersion then install(pack, version.latest_version) end
			end)
		else
			install(pack)
		end
	end)

	vim.iter(ensurePack)

	-- auto-clean unused packages
	local installedPackages = masonReg.get_installed_package_names()
	vim.iter(installedPackages):each(function(packName)
		if not vim.tbl_contains(ensurePack, packName) then
			masonReg.get_package(packName):uninstall()
			vim.notify(("Uninstalled [%s]"):format(packName), nil, notifyOpts)
		end
	end)
end

--------------------------------------------------------------------------------

return {
	"williamboman/mason.nvim",
	event = "VeryLazy",
	keys = {
		{ "<leader>pm", vim.cmd.Mason, desc = " Mason home" },
	},
	init = function()
		-- Make mason packages available before loading mason itself. 
		-- This allows us to lazy-load of mason.
		vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
	end,
	opts = {
		-- PENDING https://github.com/mason-org/mason-registry/pull/7957
		-- add my own local registry: https://github.com/mason-org/mason-registry/pull/3671#issuecomment-1851976705
		-- also requires `yq` being available in the system
		registries = {
			-- local one must come first to take priority
			("file:%s/personal-mason-registry"):format(vim.fn.stdpath("config")),
			"github:mason-org/mason-registry",
		},

		ui = {
			border = vim.g.borderStyle,
			height = 0.85,
			width = 0.8,
			icons = {
				package_installed = "✓",
				package_pending = "󰔟",
				package_uninstalled = "󰅗",
			},
			keymaps = { -- consistent with keymaps for lazy.nvim
				uninstall_package = "x",
				toggle_help = "?",
				toggle_package_expand = "<Tab>",
			},
		},
	},
	config = function(_, opts)
		require("mason").setup(opts)

		-- get packages from my lsp server config
		local ensurePackages = require("config.lsp-servers").masonDependencies or {}
		table.insert(ensurePackages, "debugpy")

		vim.defer_fn(function() syncPackages(ensurePackages) end, 5000)
	end,
}
