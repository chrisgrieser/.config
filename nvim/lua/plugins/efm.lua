local lintersAndFormatters = {
	"codespell",
	"yamllint",
	"shellcheck",
	"shfmt", -- shell
	"markdownlint",
	"ruff", -- python linter/formatter, the lsp does diagnostics, the CLI does formatting
	"black", -- python formatter
	"selene", -- lua
	"stylua", -- lua
	"prettier", -- only yaml formatter preserving blank lines https://github.com/mikefarah/yq/issues/515
	"rome", -- also an LSP; the lsp does diagnostics, the CLI does formatting
	-- stylelint included in mason, but not its plugins, which then cannot be found https://github.com/williamboman/mason.nvim/issues/695
}

--------------------------------------------------------------------------------

local setupEfmConfig = function()
	local black = require("efmls-configs.formatters.black")
	local prettier = require("efmls-configs.formatters.prettier")
	local shfmt = require("efmls-configs.formatters.shfmt")
	local stylua = require("efmls-configs.formatters.stylua")
	local selene = require("efmls-configs.linters.selene")

	local shellcheck = require("my-efm.linters.shellcheck")
	local shellharden = require("my-efm.formatters.shellharden")
	local ruff = require("my-efm.formatters.ruff")
	local rome = require("my-efm.formatters.rome")
	local markdownlint = require("my-efm.linters.markdownlint")
	local yamllint = require("my-efm.linters.yamllint")
	local codespell_L = require("my-efm.linters.codespell")
	local stylelint_L = require("my-efm.linters.stylelint")
	local stylelint_F = require("my-efm.formatters.stylelint")
	-- local shellcheckApply = require("my-efm.formatters.shellcheck")
	-- local misspell_F = require("my-efm.formatters.misspell")
	local misspell_L = require("my-efm.linters.misspell")
	-- local codespellFormat = require("my-efm.formatters.codespell")

	local languages = {
		javascript = { rome },
		typescript = { rome },
		json = { rome },
		lua = { stylua, selene },
		python = { black, ruff },
		css = { prettier, stylelint_L, stylelint_F },
		html = { prettier },
		sh = { shfmt, shellcheck, shellharden },
		yaml = { yamllint, prettier },
		markdown = { markdownlint },
		gitcommit = {},
		toml = {},
	}

	-- use for codespell for all except bib and css
	for ft, _ in pairs(languages) do
		if ft ~= "bib" and ft ~= "css" then
			table.insert(languages[ft], codespell_L)
			table.insert(languages[ft], misspell_L)
			-- table.insert(languages[ft], misspell_F)
		end
	end

	-- INFO efm has to be installed via brew, since mason only installs it via go.
	-- https://github.com/williamboman/mason.nvim/issues/1481
	require("lspconfig").efm.setup {
		filetypes = vim.tbl_keys(languages),
		init_options = { documentFormatting = true },
		settings = {
			rootMarkers = { ".git/" },
			languages = languages,
		},
	}

	vim.api.nvim_create_user_command("EfmStatus", "checkhealth efmls-configs", {})
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
		event = "BufReadPre", -- later would not become active on first buffer
		keys = {
			{
				"<D-s>",
				function()
					vim.lsp.buf.format { name = "efm" }
					vim.cmd.update()
				end,
				desc = "󰒕 Format & Save",
			},
		},
		dependencies = "neovim/nvim-lspconfig",
		config = setupEfmConfig,
	},
}
