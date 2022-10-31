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
-- DIAGNOTICS (in general, also applies to nvim-lint etc.)
local opts = { noremap = true, silent = true }
keymap('n', 'ge', function() vim.diagnostic.goto_next({ wrap = true, float = false }) end, opts)
keymap('n', 'gE', function() vim.diagnostic.goto_prev({ wrap = true, float = false }) end, opts)

-- toggle diagnostics
local diagnosticToggled = true;
keymap('n', '<leader>D', function()
	if diagnosticToggled then
		vim.diagnostic.disable(0)
	else
		vim.diagnostic.enable(0)
	end
	diagnosticToggled = not (diagnosticToggled)
end)

function diagnosticFormat(diagnostic, mode)
	local out
	if diagnostic.source:match("%.$") then -- remove trailing dot for some sources
		diagnostic.source = diagnostic.source:sub(1, -2)
	end
	if diagnostic.source == "stylelint" then
		out = diagnostic.message -- stylelint already includes the code in the message
	else
		out = diagnostic.message .. " (" .. tostring(diagnostic.code) .. ")"
	end
	if diagnostic.source and mode == "float" then
		out = out .. " [" .. diagnostic.source .. "]"
	end
	return out
end

vim.diagnostic.config {
	virtual_text = {
		format = function(diagnostic) return diagnosticFormat(diagnostic, "virtual_text") end,
		severity = { min = vim.diagnostic.severity.WARN }
	},
	float = {
		border = borderStyle,
		max_width = 50,
		format = function(diagnostic) return diagnosticFormat(diagnostic, "float") end,
	}
}

keymap("n", "<leader>d", function() vim.diagnostic.open_float { focusable = false } end)

--------------------------------------------------------------------------------
-- Mason Config
require("mason").setup({
	ui = {
		border = borderStyle,
		icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" }
	}
})
require('mason-update-all').setup()

require("mason-lspconfig").setup({
	-- mason-lspconfig uses the lspconfig servernames, not mason servernames
	-- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
	ensure_installed = lsp_servers,
})

--------------------------------------------------------------------------------
-- LSP KEYBINDINGS

require "lsp_signature".setup {
	floating_window = false,
	hint_prefix = "﬍ ",
	hint_scheme = "Comment", -- highlight group that is applied to the hint
}

keymap({ "n", "i", "x" }, '<C-s>', vim.lsp.buf.signature_help)

-- fallback for languages without an action LSP
keymap('n', 'gs', telescope.treesitter, { silent = true })

-- actions defined globally for null-ls
keymap('n', '<leader>a', vim.lsp.buf.code_action, { silent = true })
keymap('x', '<leader>a', ":'<,'>lua vim.lsp.buf.range_code_action()", { silent = true })

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr) ---@diagnostic disable-line: unused-local
	local bufopts = { silent = true, buffer = true }
	keymap('n', 'gd', telescope.lsp_definitions, bufopts)
	keymap('n', 'gD', telescope.lsp_references, bufopts)
	keymap('n', 'gy', telescope.lsp_type_definitions, bufopts)
	keymap('n', '<leader>R', vim.lsp.buf.rename, bufopts)

	-- format on manual saving
	keymap('n', '<D-s>', function()
		vim.lsp.buf.format { async = true }
		cmd [[write!]]
	end, bufopts)

	if client.name ~= "bashls" then -- don't override man page popup
		keymap('n', '<leader>h', vim.lsp.buf.hover, bufopts) -- docs popup
	end

	if client.name ~= "cssls" then -- don't override navigation marker search for css files
		keymap('n', 'gs', telescope.lsp_document_symbols, bufopts) -- overrides treesitter symbols browsing
	end
end

--------------------------------------------------------------------------------
-- Add borders to various lsp windows
require('lspconfig.ui.windows').default_options.border = borderStyle

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
	vim.lsp.handlers.hover, { border = borderStyle }
)

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
	vim.lsp.handlers.signature_help, { border = borderStyle }
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

-- https://github.com/sumneko/lua-language-server/wiki/Annotations#annotations
-- https://github.com/sumneko/lua-language-server/wiki/Settings
lspConfig['sumneko_lua'].setup {
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = { version = 'LuaJIT' }, -- used by neovim
			format = {
				enable = true,
				defaultConfig = {
					-- https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md
					-- https://github.com/sumneko/lua-language-server/wiki/Formatter
					quote_style = "double",
					call_arg_parentheses = "remove_table_only",
					keep_one_space_between_table_and_bracket = "false", -- yes, these must be strings
					keep_one_space_between_namedef_and_attribute = "false",
					continuous_assign_table_field_align_to_equal_sign = "false",
				},
			},
			completion = {
				callSnippet = "Replace",
				keywordSnippet = "Replace",
				displayContext = 3,
				postfix = "@",
				showWord = "Enable",
			},
			diagnostics = {
				globals = { "vim", "use", "martax" },
				disable = {
					"trailing-space",
					"lowercase-global",
				},
			},
			workspace = {
				library = {
					home .. "/.hammerspoon/Spoons/EmmyLua.spoon/annotations",
				}
			},
			hint = { -- do not seem to be supported?
				enable = true,
				setType = true,
				arrayIndex = "Enable",
			},
			telemetry = { enable = false },
		}
	}
}

lspConfig['cssls'].setup {
	on_attach = on_attach,
	capabilities = capabilities,
	settings = {
		css = {
			lint = {
				vendorPrefix = "ignore",
				duplicateProperties = "error", -- duplication with styleling
				emptyRules = "ignore",
			},
			colorDecorators = { enable = true }, -- does not seem to work?
		}
	}
}

lspConfig['tsserver'].setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
lspConfig['marksman'].setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
lspConfig['yamlls'].setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
lspConfig['jsonls'].setup {
	on_attach = on_attach,
	capabilities = capabilities,
}
