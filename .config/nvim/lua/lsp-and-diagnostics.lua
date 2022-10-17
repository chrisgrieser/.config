require("utils")
-- INFO: required order of setup() calls is
-- mason, mason-config, nvim-dev, lspconfig
-- https://github.com/williamboman/mason-lspconfig.nvim#setup
--------------------------------------------------------------------------------

local lsp_servers = {
	"sumneko_lua",
	"yamlls",
	"tsserver", -- ts/js
	"marksman", -- markdown
	"jsonls",
	"cssls",
	-- REQUIRED: new servers also need to be set up further below
}

--------------------------------------------------------------------------------
-- LSP Signature
require"lsp_signature".setup{
	floating_window = false,
	hint_prefix = "﬍ ",
	hint_scheme = "Comment", -- highlight group that is applied to the hint
}

keymap({"n", "i", "v"}, '<C-s>', function () vim.lsp.buf.signature_help() end)

--------------------------------------------------------------------------------
-- DIAGNOTICS (in general, also applies to nvim-lint etc.)
local opts = { noremap=true, silent=true }
keymap('n', 'ge', function () vim.diagnostic.goto_next({wrap=true, float=false}) end, opts)
keymap('n', 'gE', function () vim.diagnostic.goto_prev({wrap=true, float=false}) end, opts)

-- toggle diagnostics nemonic: [q]uiet
local diagnosticToggled = true;
keymap('n', '<leader>q', function ()
	if diagnosticToggled then
		vim.diagnostic.disable(0)
	else
		vim.diagnostic.enable(0)
	end
	diagnosticToggled = not(diagnosticToggled)
end)

function diagnosticFormat(diagnostic, mode)
	local out
	if diagnostic.source == "stylelint" then
		out = diagnostic.message -- stylelint already includes the code in the message
	else
		out = diagnostic.message.." ("..tostring(diagnostic.code)..")"
	end
	if diagnostic.source and mode == "float" then
		out = out.." ["..diagnostic.source.."]"
	end
	return out
end

vim.diagnostic.config{
	virtual_text = {
		format = function (diagnostic) return diagnosticFormat(diagnostic, "virtual_text") end,
	},
	float = {
		border = borderStyle,
		max_width = 50,
		format = function (diagnostic) return diagnosticFormat(diagnostic, "float") end,
	}
}

-- show diagnostic under cursor as float
opt.updatetime = 1000 -- ms until float is shown
augroup("diagnostic-float", {})
autocmd("CursorHold", {
	group = "diagnostic-float",
	callback = function () vim.diagnostic.open_float{focusable=false} end, -- allow focussable for other diagnostic floats like hover info
})

-- textobj diagnostic plugin
require("textobj-diagnostic").setup{create_default_keymaps = false}
keymap({"x", "o"}, "id", function() require("textobj-diagnostic").next_diag_inclusive() end, opts)

--------------------------------------------------------------------------------

require("mason").setup({
	ui = {
		border = borderStyle,
		icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" }
	}
})
require('mason-update-all').setup()
--------------------------------------------------------------------------------

require("mason-lspconfig").setup({
	-- mason-lspconfig uses the lspconfig servernames, not mason servernames
	-- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
	ensure_installed = lsp_servers,
})

-- fallback for languages without an action LSP
keymap('n', 'gs', function() telescope.treesitter() end, {silent = true})

-- actions defined globally for null-ls
keymap('n', '<leader>a', vim.lsp.buf.code_action, {silent=true})
keymap('v', '<leader>a', ":'<,'>lua vim.lsp.buf.range_code_action()", {silent=true})

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr) ---@diagnostic disable-line: unused-local
	local bufopts = { silent=true, buffer=true }
	keymap('n', 'gd', function() telescope.lsp_definitions() end, bufopts)
	keymap('n', 'gD', function() telescope.lsp_references() end, bufopts)

	keymap('n', 'gS', ":SymbolsOutline<CR>", bufopts)
	keymap('n', 'gy', function() telescope.lsp_type_definitions() end, bufopts)
	keymap('n', '<leader>R', vim.lsp.buf.rename, bufopts)
	keymap('n', '<leader>h', vim.lsp.buf.hover, bufopts) -- docs popup

	if client.name ~= "cssls" then -- to not override the navigation marker search for css files
		keymap('n', 'gs', function() telescope.lsp_document_symbols() end, bufopts) -- overrides treesitter symbols browsing
	end
end

--------------------------------------------------------------------------------
-- Add borders to various lsp windows
require('lspconfig.ui.windows').default_options.border = borderStyle

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
	vim.lsp.handlers.hover,
	{border = borderStyle}
)

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
	vim.lsp.handlers.signature_help,
	{border = borderStyle}
)
--------------------------------------------------------------------------------
-- LSP-SERVER-SPECIFIC SETUP
local lspConfig = require('lspconfig')

-- Enable snippet capability for completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- INFO: this block must come before lua LSP setup
require("neodev").setup {
	library = {
		enabled = true,
		plugins = false,
	}
}

lspConfig['sumneko_lua'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
	settings = { -- https://github.com/sumneko/lua-language-server/wiki/Settings
	Lua = {
		runtime = { version = 'LuaJIT', },  -- used by neovim
		completion = {
			callSnippet = "both",
			keywordSnippet = "both",
		},
		diagnostics = {
			globals = {"vim", "use", "martax"},
			disable = {
				"trailing-space",
				"lowercase-global",
			},
		},
		workspace = {
			library =  {
				home.."/.hammerspoon/Spoons/EmmyLua.spoon/annotations",
			}
		},
		telemetry = { enable = false },
		hint = {
			enable = true,
			settype = true
		},
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

lspConfig['jsonls'].setup{
	on_attach = on_attach,
	capabilities = capabilities,
}

