-- DOCS https://github.com/neovim/nvim-lspconfig/tree/master/lsp
--------------------------------------------------------------------------------

---since nvim-lspconfig and mason.nvim use different package names
---@type table<string, string>
local lspToMasonMap = {
	basedpyright = "basedpyright", -- python lsp (pyright fork)
	bashls = "bash-language-server", -- also used for zsh
	biome = "biome", -- ts/js/json/css linter/formatter
	css_variables = "css-variables-language-server", -- support css variables across multiple files
	cssls = "css-lsp",
	efm = "efm", -- integration of external linter/formatter
	emmet_language_server = "emmet-language-server", -- css/html snippets
	-- emmylua_ls = "emmylua_ls", -- improved lua LSP, TEMP still bit buggy
	harper_ls = "harper-ls", -- natural language linter
	html = "html-lsp",
	jsonls = "json-lsp",
	just = "just-lsp",
	ltex_plus = "ltex-ls-plus", -- languagetool: natural language linter (ltex fork)
	lua_ls = "lua-language-server",
	marksman = "marksman", -- markdown lsp
	ruff = "ruff", -- python linter & formatter
	stylelint_lsp = "stylelint-lsp", -- css linter
	taplo = "taplo", -- toml lsp
	ts_ls = "typescript-language-server",
	ts_query_ls = "ts_query_ls", -- Treesitter query files
	typos_lsp = "typos-lsp", -- spellchecker for code
	yamlls = "yaml-language-server",
}

local extraDependencies = {
	"shfmt", -- used by bashls for formatting
	"shellcheck", -- used by bashls/efm for diagnostics, PENDING https://github.com/bash-lsp/bash-language-server/issues/663
	"stylua", -- efm
	"markdown-toc", -- efm
	"markdownlint", -- efm
	"debugpy", -- nvim-dap-python
}

--------------------------------------------------------------------------------

local masonPackages = vim.tbl_values(lspToMasonMap)
vim.list_extend(masonPackages, extraDependencies)

local lsps = vim.tbl_keys(lspToMasonMap)

-- Not installed via `mason`, but included in Xcode Command Line Tools (which
-- are usually installed on macOS-dev devices as they are needed for `homebrew`)
if jit.os == "OSX" then table.insert(lsps, "sourcekit") end

--------------------------------------------------------------------------------

-- for when loaded from `init.lua`, enable LSPs
vim.lsp.enable(lsps)

-- for when loaded from `mason` config, return list of mason packages
return masonPackages
