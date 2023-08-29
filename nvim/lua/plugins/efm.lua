local linterConfig = require("config.utils").linterConfigFolder
local lintersAndFormatters = {
	"codespell",
	"yamllint",
	"shellcheck",
	"shfmt", -- shell
	"markdownlint",
	"ruff", -- python linter/formatter, the lsp does diagnostics, the CLI does formatting
	"black", -- python formatter
	"vale", -- natural language
	"selene", -- lua
	"stylua", -- lua
	"prettier", -- only used for yaml and html https://github.com/mikefarah/yq/issues/515
	"rome", -- also an LSP; the lsp does diagnostics, the CLI does formatting
	-- stylelint included in mason, but not its plugins, which then cannot be found https://github.com/williamboman/mason.nvim/issues/695
}

--------------------------------------------------------------------------------

local setupEfmConfig = function()
	local black = require("efmls-configs.formatters.black")
	local prettier = require("efmls-configs.formatters.prettier")
	local shfmt = require("efmls-configs.formatters.shfmt")
	local stylelint = require("efmls-configs.linters.stylelint")
	local stylua = require("efmls-configs.formatters.stylua")
	local vale = require("efmls-configs.linters.vale")
	local selene = require("efmls-configs.linters.selene")
	local shellcheck = require("efmls-configs.linters.shellcheck")
	local ruff = require("my-efm.formatters.ruff")

	-- TODO
	-- markdownlint
	-- codespell
	-- rome

	local languages = {
		lua = { stylua, selene },
		python = { black, ruff },
		css = { prettier, stylelint },
		sh = { shfmt, shellcheck },
		markdown = { vale },
		gitcommit = { vale },
		octo = { vale },
	}

	-- INFO efm has to be installed via brew, since mason only installs it via go.
	require("lspconfig").efm.setup {
		filetypes = vim.tbl_keys(languages),
		settings = {
			rootMarkers = { ".git/" },
			languages = languages,
		},
		init_options = {
			documentFormatting = true,
			documentRangeFormatting = true,
		},
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
		lazy = false, -- must be loaded at once
		keys = {
			{
				"<D-s>",
				function()
					vim.lsp.buf.format()
					vim.cmd.update()
				end,
				desc = "󰒕 Format & Save",
			},
		},
		dependencies = "neovim/nvim-lspconfig",
		config = setupEfmConfig,
	},
}
