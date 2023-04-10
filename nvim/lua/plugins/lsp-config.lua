local u = require("config.utils")
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
	"html",
}

--------------------------------------------------------------------------------

local lspSettings = {}
local lspFileTypes = {}
local lspOnAttach = {}

--------------------------------------------------------------------------------
-- LUA

-- https://github.com/LuaLS/lua-language-server/wiki/Annotations#annotations
-- https://github.com/LuaLS/lua-language-server/wiki/Settings
lspSettings.lua_ls = {
	Lua = {
		completion = {
			callSnippet = "Replace",
			keywordSnippet = "Replace",
			displayContext = 5,
			postfix = ".",
		},
		diagnostics = {
			disable = { "trailing-space" }, -- formatter already does that
			severity = { -- https://github.com/LuaLS/lua-language-server/wiki/Settings#diagnosticsseverity
				["return-type-mismatch"] = "Error",
			},
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

--------------------------------------------------------------------------------
-- CSS

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
		colorDecorators = { enable = false }, -- not supported yet
	},
}

--------------------------------------------------------------------------------
-- JAVASCRIPT & TYPESCRIPT

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

-- https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts#neovim-08
lspOnAttach.tsserver = function(client, _)
	-- disable formatting, since taken care of by prettier
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint
-- INFO when no eslintrc can be found in a parent dir, `.root_dir` will return
-- nil and the eslint-LSP will not be started
lspSettings.eslint = {
	quiet = false, -- = include warnings
	codeAction = {
		disableRuleComment = { location = "sameLine" }, -- add ignore-comments on the same line
	},
}

--------------------------------------------------------------------------------
-- OTHERS
-- https://github.com/sublimelsp/LSP-json/blob/master/LSP-json.sublime-settings
lspSettings.jsonls = {
	json = { format = { enable = false } }, -- taken care of by prettier
}

-- https://github.com/redhat-developer/yaml-language-server#language-server-settings
lspSettings.yamlls = {
	yaml = { keyOrdering = false }, -- FIX mapKeyOrder
}

-- Force lsp to work with zsh
-- lspFileTypes.bashls = { "sh", "zsh", "bash" }

--------------------------------------------------------------------------------
-- ENABLE CAPATIBILITES FOR PLUGINS

-- Enable snippets-completion (for nvim_cmp)
local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
lspCapabilities.textDocument.completion.completionItem.snippetSupport = true

-- Enable folding (for nvim-ufo)
lspCapabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

--------------------------------------------------------------------------------

local function setupAllLsps()
	-- INFO must be before the lsp-config setup of lua-ls
	require("neodev").setup {
		library = {
			plugins = { "lazy.nvim", "telescope.nvim" }, -- not enabling all, since too slow for LSP
		},
	}

	for _, lsp in pairs(lsp_servers) do
		local config = {
			capabilities = lspCapabilities,
			settings = lspSettings[lsp], -- if no settings, will assign nil and therefore do nothing
			filetypes = lspFileTypes[lsp],
			on_attach = lspOnAttach[lsp],
		}

		require("lspconfig")[lsp].setup(config)
	end
end
--------------------------------------------------------------------------------


return {
	{ -- package manager
		"williamboman/mason.nvim",
		lazy = true,
		opts = {
			ui = {
				border = u.borderStyle,
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
		opts = { ensure_installed = lsp_servers },
	},
	{ -- configure LSPs
		"neovim/nvim-lspconfig",
		dependencies = "folke/neodev.nvim", -- lsp for nvim-lua config
		init = setupAllLsps,
		config = function()
			-- FIX for multi-space workspace https://github.com/neovim/nvim-lspconfig/issues/2366#issuecomment-1367098168
			vim.lsp.handlers["workspace/diagnostic/refresh"] = function(_, _, ctx)
				local ns = vim.lsp.diagnostic.get_namespace(ctx.client_id)
				local bufnr = vim.api.nvim_get_current_buf()
				vim.diagnostic.reset(ns, bufnr)
				return true
			end

			-- Border Styling
			require("lspconfig.ui.windows").default_options.border = u.borderStyle
			vim.lsp.handlers["textDocument/hover"] =
				vim.lsp.with(vim.lsp.handlers.hover, { border = u.borderStyle })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = u.borderStyle })

			-- Diagnostics
			local function fmt(diag)
				local source = diag.source and " (" .. diag.source:gsub("%.$", "") .. ")" or ""
				local msg = diag.message
				return msg .. source
			end

			vim.diagnostic.config {
				virtual_text = {
					severity = { min = vim.log.levels.WARN },
				},
				float = {
					format = function(diag) return fmt(diag) end,
					focusable = true,
					border = u.borderStyle,
					max_width = 70,
					header = "", -- remove "Diagnostics:" heading
				},
			}
		end,
	},
}
