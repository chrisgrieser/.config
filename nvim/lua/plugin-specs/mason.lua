local check_install = function()
  local sync or false
  local installed = false -- reset for triggered events
  installed_packages = {} -- reset
  local completed = 0
  local total = vim.tbl_count(SETTINGS.ensure_installed)
  local all_completed = false
  local on_close = function()
    completed = completed + 1
    if completed >= total then
      local event = {
        pattern = 'MasonToolsUpdateCompleted',
      }
      if vim.fn.has 'nvim-0.8' == 1 then
        event.data = installed_packages
      end
      vim.api.nvim_exec_autocmds('User', event)
      all_completed = true
    end
  end
  local ensure_installed = function()
    for _, item in ipairs(SETTINGS.ensure_installed or {}) do
      local name, version, auto_update
      if type(item) == 'table' then
        name = item[1]
        version = item.version
        auto_update = item.auto_update
      else
        name = item
      end
      if mlsp then
        name = mlsp.get_mappings().lspconfig_to_mason[name] or name
      end
      if mnls then
        name = mnls.getPackageFromNullLs(name) or name
      end
      if mdap then
        name = mdap.nvim_dap_to_package[name] or name
      end
      local p = mr.get_package(name)
      if p:is_installed() then
        if version ~= nil then
          p:get_installed_version(function(ok, installed_version)
            if ok and installed_version ~= version then
              do_install(p, version, on_close)
            else
              vim.schedule(on_close)
            end
          end)
        elseif
          force_update or (force_update == nil and (auto_update or (auto_update == nil and SETTINGS.auto_update)))
        then
          p:check_new_version(function(ok, version)
            if ok then
              do_install(p, version.latest_version, on_close)
            else
              vim.schedule(on_close)
            end
          end)
        else
          vim.schedule(on_close)
        end
      else
        do_install(p, version, on_close)
      end
    end
  end
  if mr.refresh then
    mr.refresh(ensure_installed)
  else
    ensure_installed()
  end
  if sync then
    while true do
      vim.wait(10000, function()
        return all_completed
      end)
      if all_completed then
        break
      end
    end
  end
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

			local ensurePackages = require("config.lsp-servers").masonDependencies
			local debuggers = { "debugpy" }
			vim.list_extend(ensurePackages, debuggers)
			assert(#ensurePackages > 10, "Warning: in mason config, many packages would be uninstalled.")

			local mr = require("mason-registry")
			local installedPackages = mr.get_installed_package_names()

			mr:on("package:install:success", function(tool)
				local msg = ("Installed [%s]"):format(tool.name)
				vim.notify(msg, nil, { title = "Mason", icon = "" })
			end)
			for _, tool in ipairs(ensurePackages) do
				local hasPackage, p = pcall(mr.get_package, tool)
				if hasPackage and not p:is_installed() then p:install() end
			end
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
