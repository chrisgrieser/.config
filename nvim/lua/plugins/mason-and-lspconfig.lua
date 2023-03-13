-- INFO: Server names are LSP names, not Mason names
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
local lsp_servers = {
	"lua_ls",
	"yamlls",
	"jsonls",
	"cssls",
	"emmet_ls", -- css & html completion
	"pyright", -- python
	"marksman", -- markdown
	"tsserver", -- ts/js
	"eslint", -- ts/js
	"bashls", -- also used for zsh
	"taplo", -- toml
}

--------------------------------------------------------------------------------

local lspSettings = {}
local lspFileTypes = {}

-- https://github.com/LuaLS/lua-language-server/wiki/Annotations#annotations
-- https://github.com/LuaLS/lua-language-server/wiki/Settings
lspSettings.lua_ls = {
	Lua = {
		format = { enable = false }, -- using stylua instead. Also, sumneko-lsp-formatting has this weird bug where all folds are opened
		completion = {
			callSnippet = "Replace",
			keywordSnippet = "Replace",
			displayContext = 2,
		},
		-- libraries defined per-project via luarc.json location: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
		diagnostics = {
			disable = { "trailing-space" },
		},
		workspace = { checkThirdParty = false }, -- HACK https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
		hint = {
			enable = true,
			setType = true,
			paramName = "All",
			paramType = true,
			arrayIndex = "Disable",
		},
		telemetry = { enable = false },
	},
}

-- https://github.com/sublimelsp/LSP-css/blob/master/LSP-css.sublime-settings
lspSettings.cssls = {
	css = {
		lint = {
			vendorPrefix = "ignore",
			propertyIgnoredDueToDisplay = "error",
			universalSelector = "ignore",
			float = "ignore",
			boxModel = "ignore",
			-- since these would be duplication with stylelint
			duplicateProperties = "ignore",
			emptyRules = "warning",
		},
		colorDecorators = { enable = true }, -- not supported yet
	},
}

local jsAndTsSettings = {
	-- https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
	format = {}, -- not used, since taken care of by prettier
	inlayHints = {
		includeInlayEnumMemberValueHints = true,
		includeInlayFunctionLikeReturnTypeHints = true,
		includeInlayFunctionParameterTypeHints = true,
		includeInlayParameterNameHints = "all", -- none | literals | all
		includeInlayParameterNameHintsWhenArgumentMatchesName = true,
		includeInlayPropertyDeclarationTypeHints = true,
		includeInlayVariableTypeHints = true,
		includeInlayVariableTypeHintsWhenTypeMatchesName = true,
	},
}

lspSettings.tsserver = {
	completions = { completeFunctionCalls = true },
	diagnostics = {
		-- https://github.com/microsoft/TypeScript/blob/master/src/compiler/diagnosticMessages.json
		ignoredCode = {},
	},
	typescript = jsAndTsSettings,
	javascript = jsAndTsSettings,
}

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint
lspSettings.eslint = {
	quiet = false, -- = include warnings
	codeAction = {
		disableRuleComment = { location = "sameLine" }, -- add ignore-comments on the same line
	},
}

-- https://github.com/sublimelsp/LSP-json/blob/master/LSP-json.sublime-settings
lspSettings.jsonls = {
	json = {
		validate = { enable = true },
		format = { enable = true },
		schemas = require("schemastore").json.schemas(),
	},
}

-- https://github.com/redhat-developer/yaml-language-server#language-server-settings
lspSettings.yamlls = {
	yaml = { keyOrdering = false }, -- FIX mapKeyOrder
}

--------------------------------------------------------------------------------

lspFileTypes.bashls = { "sh", "zsh", "bash" } -- force lsp to work with zsh
lspFileTypes.emmet_ls = { "css", "scss", "html" }

--------------------------------------------------------------------------------

-- Enable snippet capability for completion (nvim_cmp)
local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
lspCapabilities.textDocument.completion.completionItem.snippetSupport = true

-- Enable folding (nvim-ufo)
lspCapabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

--------------------------------------------------------------------------------

return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup {
				ui = {
					border = BorderStyle,
					icons = {
						package_installed = "✓",
						package_pending = "羽",
						package_uninstalled = "✗",
					},
				},
			}
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = "williamboman/mason.nvim",
		config = function()
			require("mason-lspconfig").setup {
				ensure_installed = lsp_servers,
			}
		end,
	},
	{ -- lsp for nvim-lua config
		"folke/neodev.nvim",
		-- INFO this must come before lua lsp-config setup
		lazy = false,
		init = function()
			require("neodev").setup {
				library = { plugins = false },
			}
		end,
	},
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		init = function()
		end,
		config = function()


			-- Border Styling
			require("lspconfig.ui.windows").default_options.border = BorderStyle
			vim.lsp.handlers["textDocument/hover"] =
				vim.lsp.with(vim.lsp.handlers.hover, { border = BorderStyle })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = BorderStyle })
		end,
	},
}
