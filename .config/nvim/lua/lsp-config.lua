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
	ensure_installed = { -- this plugin uses the lspconfig servernames, not mason servernames https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
		"sumneko_lua",
		"yamlls",
		"tsserver", -- ts/js
		"marksman", -- markdown
		"jsonls",
		"cssls",
		"bashls",
	},
})

-- Mappings.
local opts = { noremap=true, silent=true }
keymap('n', 'ge', vim.diagnostic.goto_next, opts)
keymap('n', 'gE', vim.diagnostic.goto_prev, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr) ---@diagnostic disable-line: unused-local

	-- Enable completion triggered by <c-x><c-o>
	api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings (See `:help vim.lsp.*` for documentation on any of the below functions)
	local bufopts = { silent=true, buffer=true }
	keymap('n', 'gd', function() telescope.lsp_definitions() end,  bufopts)
	keymap('n', 'gD', function() telescope.lsp_references() end,  bufopts)
	keymap('n', 'gs', function() telescope.lsp_document_symbols() end,  bufopts)
	keymap('n', 'gy', vim.lsp.buf.type_definition, bufopts)
	keymap('n', '<leader>h', vim.lsp.buf.hover, bufopts)
	keymap('n', '<leader>R', vim.lsp.buf.rename, bufopts)
	keymap('n', '<leader>a', vim.lsp.buf.code_action, bufopts)
end

--------------------------------------------------------------------------------
-- LANGUAGE-SPECIFIC SETUP
local lspConfig = require('lspconfig')
local home = fn.expand("~")

lspConfig['sumneko_lua'].setup{
	on_attach = on_attach,
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT', -- Li
			},
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
