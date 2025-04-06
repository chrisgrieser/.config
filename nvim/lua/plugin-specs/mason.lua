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
		notifyOpts.icon = " "
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
---@param ensurePacks string[]
local function syncPackages(ensurePacks)
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
	event = "VeryLazy",
	keys = {
		{ "<leader>pm", vim.cmd.Mason, desc = " Mason home" },
	},
	init = function()
		-- Make mason packages available before loading it; allows to lazy-load mason.
		vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

		-- do not crowd home directory with npm cache folder
		vim.env.npm_config_cache = vim.env.HOME .. "/.cache/npm"
	end,
	opts = {
		registries = {
			-- local one must come first to take priority
			-- add my own local registry: https://github.com/mason-org/mason-registry/pull/3671#issuecomment-1851976705
			-- also requires `yq` being available in the system
			("file:%s/personal-mason-registry"):format(vim.fn.stdpath("config")),
			"github:mason-org/mason-registry",
		},

		ui = {
			border = vim.o.winborder,
			height = 0.85,
			width = 0.8,
			backdrop = 100, -- disable PENDING https://github.com/williamboman/mason.nvim/pull/1900
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
	config = function(_, opts)
		require("mason").setup(opts)

		-- get packages from my lsp-server-config
		local ensurePackages = require("config.lsp-servers").masonDependencies or {}
		local extraPackages = { "debugpy" }
		vim.list_extend(ensurePackages, extraPackages)

		vim.defer_fn(function() syncPackages(ensurePackages) end, 3000)
	end,
}
