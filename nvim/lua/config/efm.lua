--------------------------------------------------------------------------------

-- Register linters and formatters per language
local prettier = require("efmls-configs.formatters.prettier")
local stylua = require("efmls-configs.formatters.stylua")
local black = require("efmls-configs.formatters.black")
local stylelint = require("efmls-configs.linters.stylelint")
local shfmt = require("efmls-configs.formatters.shfmt")
local vale = require("efmls-configs.linters.vale")

-- NOT PRE-CONFIGURED (= TODO)
-- markdownlint
-- ruff
-- codespell
-- rome

local languages = {
	lua = { stylua },
	python = { black },
	css = { prettier, stylelint },
	sh = { shfmt },
	markdown = { vale },
	gitcommit = { vale },
	octo = { vale },
}

--------------------------------------------------------------------------------

-- DOCS https://github.com/mattn/efm-langserver#configuration-for-neovim-builtin-lsp-with-nvim-lspconfig
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

--------------------------------------------------------------------------------
