require("utils")
--------------------------------------------------------------------------------
require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗"
		}
	}
})
require("mason-lspconfig").setup({
	-- this plugin uses the lspconfig servernames, not mason servernames https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
	ensure_installed = {
		"sumneko_lua",
		"yamlls",
		"tsserver",
		"marksman",
		"jsonls",
		"cssls",
		"bashls",
	},
})

-- Mappings.
local opts = { noremap=true, silent=true }
vim.keymap.set('n', 'ge', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', 'gE', vim.diagnostic.goto_prev, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr) ---@diagnostic disable-line: unused-local
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap=true, silent=true, buffer=bufnr }
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set('n', 'gD', vim.lsp.buf.references, bufopts)
	vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', '<leader>R', vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, bufopts)
end

local lspConfig = require('lspconfig')
local home = fn.expand("~")
--------------------------------------------------------------------------------
-- LANGUAGE-SPECIFIC SETUP

lspConfig['sumneko_lua'].setup{
	on_attach = on_attach,
	settings = {
		Lua = {
			diagnostics = {
				globals = {"vim", "use", "martax"},
				disable = {"trailing-space", "lowercase-global"},
			},
			workspace = {
				library =  {
					home.."/.hammerspoon/Spoons/EmmyLua.spoon/annotations",
					home.."/.hammerspoon/lua",
					home.."/.config/nvim/lua"
				}
			},
			telemetry = { enable = false },
			hint = { settype = true },
		}
	}
}

lspConfig['cssls'].setup{
	on_attach = on_attach,
	settings = {
		css = {
			lint = {
				vendorPrefix = "ignore",
				duplicateProperties = "error",
			},
			colorDecorators = { enable = true },
		}
	}
}

lspConfig['tsserver'].setup{
	on_attach = on_attach,
}

lspConfig['marksman'].setup{
	on_attach = on_attach,
}

lspConfig['bashls'].setup{
	on_attach = on_attach,
}

lspConfig['jsonls'].setup{
	on_attach = on_attach,
}
