-- DOCS https://github.com/neovim/nvim-lspconfig/tree/master/lsp
--------------------------------------------------------------------------------

---@type string[]
local lspsAsMasonNames = {
	"basedpyright", -- python lsp (pyright fork)
	"bash-language-server", -- also used for zsh
	"biome", -- ts/js/json/css linter/formatter
	"css-variables-language-server", -- support css variables across multiple files
	"css-lsp",
	"efm", -- integration of external linter/formatter
	"emmet-language-server", -- css/html snippets
	"emmylua_ls", -- improved lua LSP, TEMP still bit buggy
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
}

local extraMasonPackages = {
	"shfmt", -- used by bashls for formatting
	"shellcheck", -- used by bashls/efm for diagnostics, PENDING https://github.com/bash-lsp/bash-language-server/issues/663
	"stylua", -- efm
	"markdown-toc", -- efm
	"markdownlint", -- efm
	"debugpy", -- nvim-dap-python
}

--------------------------------------------------------------------------------
-- LSP

-- Not installed via `mason`, but included in Xcode Command Line Tools (which
-- are usually installed on macOS-dev devices as they are needed for `homebrew`)
if jit.os == "OSX" then vim.lsp.enable("sourcekit") end

-- when loaded from `init.lua`, enable LSPs
local masonPath = require("lazy.core.config").options.root .. "/mason.nvim"
vim.opt.runtimepath:prepend(masonPath)
local lspConfigNames = vim.iter(lspsAsMasonNames)
	:map(function(masonName)
		local pack = require("mason-registry").get_package(masonName)
		return pack.neovim.lspconfig ---@diagnostic disable-line: undefined-field
	end)
	:totable()
vim.lsp.enable(lspConfigNames)

--------------------------------------------------------------------------------
-- MASON
-- when loaded from `mason` config, return list of mason packages
local masonPackages = vim.tbl_values(lspsAsMasonNames)
vim.list_extend(masonPackages, extraMasonPackages)
return masonPackages
