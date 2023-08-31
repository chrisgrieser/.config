-- Builtin Configs: https://github.com/creativenull/efmls-configs-nvim/blob/main/doc/SUPPORTED_LIST.md
--------------------------------------------------------------------------------

local lintersAndFormatters = {
	"codespell",
	"yamllint",
	"actionlint",
	"shellcheck",
	"shfmt",
	"mdformat",
	"markdownlint",
	"black",
	"selene",
	"stylua",
	"prettier", -- only yaml formatter preserving blank lines https://github.com/mikefarah/yq/issues/515
	-- stylelint included in mason, but not its plugins, which then cannot be found https://github.com/williamboman/mason.nvim/issues/695

	-- TODO installing via MasonTools instead of mason-lspconfig, pending https://github.com/neovim/nvim-lspconfig/pull/2790
	"biome",
}

--------------------------------------------------------------------------------

local setupEfmConfig = function()
	local black = require("efmls-configs.formatters.black")
	local prettier = require("efmls-configs.formatters.prettier")
	local shfmt = require("efmls-configs.formatters.shfmt")
	local stylua = require("efmls-configs.formatters.stylua")
	local selene = require("efmls-configs.linters.selene")
	local biome = require("efmls-configs.formatters.biome")
	local shellharden = require("efmls-configs.formatters.shellharden")
	local actionlint = require("efmls-configs.linters.actionlint")
	local mdformat = require("efmls-configs.formatters.mdformat")

	-- using my own, due to custom configs
	local markdownlint = require("tool-configs.linters.markdownlint")
	local shellcheck = require("tool-configs.linters.shellcheck")
	local yamllint = require("tool-configs.linters.yamllint")
	local codespell_L = require("tool-configs.linters.codespell")
	local stylelint_L = require("tool-configs.linters.stylelint")
	local stylelint_F = require("tool-configs.formatters.stylelint")

	-- BUG pending: https://github.com/mattn/efm-langserver/issues/258
	-- local shellcheckApply = require("tool-configs.formatters.shellcheck")
	-- local codespell_F = require("tool-configs.formatters.codespell")
	-- markdownlint as well

	local languages = {
		javascript = { biome },
		typescript = { biome },
		json = { biome },
		jsonc = { biome },
		lua = { stylua, selene },
		python = { black },
		css = { prettier, stylelint_L, stylelint_F },
		html = { prettier },
		sh = { shfmt, shellcheck, shellharden },
		yaml = { yamllint, prettier, actionlint },
		markdown = { markdownlint, mdformat },
		gitcommit = {},
		toml = {},
	}

	-- use for codespell for all except bib and css
	for ft, _ in pairs(languages) do
		if ft ~= "bib" and ft ~= "css" then
			table.insert(languages[ft], codespell_L)
			-- table.insert(languages[ft], codespell_F)
		end
	end

	-- INFO efm has to be installed via `brew`, since mason only installs it via go.
	-- https://github.com/williamboman/mason.nvim/issues/1481
	require("lspconfig").efm.setup {
		filetypes = vim.tbl_keys(languages),
		init_options = { documentFormatting = true },
		settings = { rootMarkers = { ".git/" }, languages = languages },
	}
end
--------------------------------------------------------------------------------

return {
	{ -- auto-install missing linters & formatters
		-- (auto-install of lsp servers done via `mason-lspconfig.nvim`)
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = "williamboman/mason.nvim",
		config = function()
			-- triggered myself, since `run_on_start`, does not work w/ lazy-loading
			require("mason-tool-installer").setup {
				ensure_installed = lintersAndFormatters,
				run_on_start = false,
			}
			vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
		end,
	},
	{
		"creativenull/efmls-configs-nvim",
		event = "BufReadPre", -- later does not attach first opened buffer
		keys = {
			{
				"<D-s>",
				function()
					vim.lsp.buf.format() -- unwanted LSP-formatting already disabled in lsp-config.lua
					vim.cmd.update()
				end,
				desc = "󰒕 Format & Save",
			},
		},
		dependencies = "chrisgrieser/nvim-lspconfig",
		config = setupEfmConfig,
	},
}
