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
		completion = {
			callSnippet = "Both", -- functions expand to name and snippet
			keywordSnippet = "Replace",
			displayContext = 4,
		},
		diagnostics = {
			disable = { "trailing-space" }, -- formatter already does that
			-- severity = {}, -- change severity for specific rules https://github.com/LuaLS/lua-language-server/wiki/Settings#diagnosticsseverity
		},
		hint = { -- LSP inlayhints
			enable = true,
			setType = true,
			arrayIndex = "Disable",
			semicolon = "Disable",
		},
		workspace = { checkThirdParty = false }, -- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
		format = { enable = false }, -- using stylua instead. Also, sumneko-lsp-formatting has this weird bug where all folds are opened
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

-- https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
local jsAndTsSettings = {
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
	typescript = jsAndTsSettings,
	javascript = jsAndTsSettings,
	-- https://github.com/microsoft/TypeScript/blob/master/src/compiler/diagnosticMessages.json
	diagnostics = { ignoredCode = {} },
}

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint
-- INFO when no eslintrc can be found in a parent dir, `.root_dir` will return
-- nil and the eslint-LSP will not be started
lspSettings.eslint = {
	quiet = false, -- = include warnings
	codeAction = {
		disableRuleComment = { location = "sameLine" }, -- add ignore-comments on the same line
	},
}

-- https://github.com/sublimelsp/LSP-json/blob/master/LSP-json.sublime-settings
lspSettings.jsonls = {
	json = { format = { enable = false } }, -- taken care of by prettier
}

-- https://github.com/redhat-developer/yaml-language-server#language-server-settings
lspSettings.yamlls = {
	yaml = { keyOrdering = false }, -- FIX mapKeyOrder
}

--------------------------------------------------------------------------------

-- Force lsp to work with zsh
lspFileTypes.bashls = { "sh", "zsh", "bash" }

-- Enable snippet capability for completion (for nvim_cmp)
local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
lspCapabilities.textDocument.completion.completionItem.snippetSupport = true

-- Enable folding (for nvim-ufo)
lspCapabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

--------------------------------------------------------------------------------

return {
	{ -- package manager
		"williamboman/mason.nvim",
		lazy = true,
		opts = {
			ui = {
				border = BorderStyle,
				icons = {
					package_installed = "✓",
					package_pending = "󰔟",
					package_uninstalled = "✗",
				},
			},
		},
	},
	{ -- auto-install lsp servers
		"williamboman/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = "williamboman/mason.nvim",
		opts = {
			ensure_installed = lsp_servers,
		},
	},

	{ -- configure LSPs
		"neovim/nvim-lspconfig",
		dependencies = "folke/neodev.nvim", -- lsp for nvim-lua config
		init = function()
			-- INFO must be setup before lua lsp-config setup
			require("neodev").setup { library = { plugins = true } }

			-- LSP Server setup
			for _, lsp in pairs(lsp_servers) do
				local config = {
					capabilities = lspCapabilities,
					settings = lspSettings[lsp], -- if no settings, will assign nil and therefore to nothing
					filetypes = lspFileTypes[lsp],
				}

				require("lspconfig")[lsp].setup(config)
			end

			-- Border Styling
			require("lspconfig.ui.windows").default_options.border = BorderStyle
			vim.lsp.handlers["textDocument/hover"] =
				vim.lsp.with(vim.lsp.handlers.hover, { border = BorderStyle })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = BorderStyle })
		end,
	},
}
