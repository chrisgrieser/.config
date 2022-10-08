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

--------------------------------------------------------------------------------
require("mason-lspconfig").setup({
	-- this plugin uses the lspconfig servernames, not mason servernames
	-- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
	ensure_installed = {
		"sumneko_lua",
		"yamlls",
		"tsserver", -- ts/js
		"marksman", -- markdown
		"jsonls",
		"cssls",
		"bashls",
	},
})

-- Diagnotics
local opts = { noremap=true, silent=true }
keymap('n', 'ge', vim.diagnostic.goto_next, opts)
keymap('n', 'gE', vim.diagnostic.goto_prev, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr) ---@diagnostic disable-line: unused-local

	-- Mappings (See `:help vim.lsp.*` for documentation on any of the below functions)
	local bufopts = { silent=true, buffer=true }
	keymap('n', 'gd', function() telescope.lsp_definitions() end,  bufopts)
	keymap('n', 'gD', function() telescope.lsp_references() end,  bufopts)
	keymap('n', 'gs', function() telescope.lsp_document_symbols() end,  bufopts)
	keymap('n', 'gy', vim.lsp.buf.type_definition, bufopts)
	keymap('n', '<leader>R', vim.lsp.buf.rename, bufopts)
	keymap('n', '<leader>a', vim.lsp.buf.code_action, bufopts)
	keymap('n', '<leader>f', vim.diagnostic.open_float, bufopts) -- diagnostic popup
	keymap('n', '<leader>h', vim.lsp.buf.hover, bufopts) -- docs popup
end


--------------------------------------------------------------------------------
-- AUTOCOMPLETION

--Enable snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
local cmp = require('cmp')

cmp.setup({
	snippet = {
		-- REQUIRED a snippet engine must be specified and installed
		expand = function(args) require('luasnip').lsp_expand(args.body) end,
	},
	experimental = { ghost_text = true },
	window = {
		completion = cmp.config.window.bordered(),
		documentation = {
			max_height = 20,
			max_width = 40,
		}
	},
	mapping = cmp.mapping.preset.insert({
		['<Esc>'] = cmp.mapping.abort(),
		['<Tab>'] = cmp.mapping.select_next_item(),
		['<S-Tab>'] = cmp.mapping.select_prev_item(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		['<S-Up>'] = cmp.mapping.scroll_docs(-4),
		['<S-Down>'] = cmp.mapping.scroll_docs(4),
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
	}, {
		{ name = 'emoji' },
		{ name = 'buffer' },
	}),
	-- disable completion in comments https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disabling-completion-in-certain-contexts-such-as-comments
	enabled = function()
		local context = require 'cmp.config.context'
		-- keep command mode completion enabled when cursor is in a comment
		if vim.api.nvim_get_mode().mode == 'c' then
			return true
		else
			return not context.in_treesitter_capture("comment")
			and not context.in_syntax_group("Comment")
		end
	end
})

-- don't use buffer in css completions
cmp.setup.filetype ("css", {
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'cmp-nvim-lsp-signature-help' },
		{ name = 'luasnip' },
	}, {
		{ name = 'emoji' },
	}
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer', max_item_count = 20 }
	}
})

-- Use cmdline & path source for
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline', max_item_count = 15 },
		{ name = 'cmdline_history', max_item_count = 5 },
	})
})

--------------------------------------------------------------------------------

-- LSP-SERVER-SPECIFIC SETUP
local lspConfig = require('lspconfig')
local home = fn.expand("~") ---@diagnostic disable-line: missing-parameter

require("lua-dev").setup({ -- INFO: this block must come before LSP setup
library = {
	enabled = true,
	-- you can also specify the list of plugins to make available as a workspace library
	-- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
	plugins = false,
},
})

lspConfig['sumneko_lua'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
	settings = { -- https://github.com/sumneko/lua-language-server/wiki/Settings
		Lua = {
			runtime = {
				version = 'LuaJIT', -- LuaJIT is used by neovim
			},
			completion = {
				callSnippet = "both",
				keywordSnippet = "both",
			},
			diagnostics = {
				globals = {"vim", "use", "martax"},
				disable = {"trailing-space", "lowercase-global"},
			},
			workspace = {
				library =  {
					home.."/.hammerspoon/Spoons/EmmyLua.spoon/annotations",
					home.."/.hammerspoon/lua",
				}
			},
			telemetry = { enable = false },
			hint = { settype = true },
		}
	}
}

lspConfig['cssls'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		css = {
			lint = {
				vendorPrefix = "ignore",
				duplicateProperties = "error",
			},
			colorDecorators = { enable = true }, -- does not seem to work?
		}
	}
}

lspConfig['tsserver'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
}

lspConfig['marksman'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
}

lspConfig['bashls'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
}

lspConfig['jsonls'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
}

--------------------------------------------------------------------------------

require("lsp_lines").setup()
vim.diagnostic.config{ virtual_text = false } -- disable visual text since redundant



-- :
