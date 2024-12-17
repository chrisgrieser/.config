---@param pack Package
---@param version? string
local function install(pack, version)
	local opts = { title = "Mason", icon = "" }

	local msg = version and ("Updating [%s] to %s"):format(pack.name, version)
		or ("Installing [%s]"):format(pack.name)
	vim.notify(msg, nil, opts)

	
	-- stylua: ignore
	pack:once("install:success", function() vim.notify("Successfully installed [" .. pack.name .. "]", nil, opts) end)
	-- stylua: ignore
	pack:once("install:failed", function() vim.notify("Failed to install [" .. pack.name .. "]", vim.log.levels.ERROR, opts) end)

	pack:install { version = version }
end

---@param ensurePackages string[]
local function ensureInstall(ensurePackages)
	local mr = require("mason-registry")

	-- auto-install missing packages
	vim.iter(ensurePackages):each(function(packageName)
		if not mr.has_package(packageName) then return end
		local pack = mr.get_package(packageName)
		if pack:is_installed() then
			pack:check_new_version(function(hasNewVersion, version)
				if hasNewVersion then install(pack, version.latest_version) end
			end)
		else
			install(pack)
		end
	end)

	vim.iter(ensurePackages)

	-- local installedPackages = mr.get_installed_package_names()
end
local function ensureUpdate()
	local mr = require("mason-registry")
	local pack = mr.get_package("biome")
	pack:check_new_version(function(hasNewVersion, version)
		if not hasNewVersion then return end
		pack:install { version = version.latest_version }
	end)
end

return {
	{
		"williamboman/mason.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason home" },
		},
		-- Make mason packages available before loading mason itself. This allows
		-- us to lazy-load of mason.
		init = function() vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH end,
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
					package_uninstalled = "✗",
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
			local debuggers = { "debugpy" }
			vim.list_extend(ensurePackages, debuggers)

			vim.defer_fn(function() ensureInstall(ensurePackages) end, 1000)
		end,
	},
	-- { -- auto-install lsps & formatters
	-- 	"WhoIsSethDaniel/mason-tool-installer.nvim",
	-- 	event = "VeryLazy",
	-- 	dependencies = "williamboman/mason.nvim",
	-- 	config = function()
	-- 		local packages = require("config.lsp-servers").masonDependencies
	-- 		local debuggers = { "debugpy" }
	-- 		vim.list_extend(packages, debuggers)
	-- 		assert(#packages > 10, "Warning: in mason config, many packages would be uninstalled.")
	--
	-- 		-- Manually run `MasonToolsUpdate`, since `run_on_start` doesn't work with lazy-loading
	-- 		require("mason-tool-installer").setup { ensure_installed = packages }
	-- 		vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
	-- 		vim.defer_fn(vim.cmd.MasonToolsUpdate, 4000)
	-- 		vim.defer_fn(vim.cmd.MasonToolsClean, 8000)
	-- 	end,
	-- },
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		config = function()
			-- Enable completion-related capabilities (blink.cmp)
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- enabled folding (nvim-ufo)
			capabilities.textDocument.foldingRange =
				{ dynamicRegistration = false, lineFoldingOnly = true }

			local myServerConfigs = require("config.lsp-servers").serverConfigs
			for lsp, config in pairs(myServerConfigs) do
				config.capabilities = capabilities
				require("lspconfig")[lsp].setup(config)
			end
		end,
	},
}
