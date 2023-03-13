require("config.utils")
-- INFO: required order of setup() calls is mason, mason-config, nvim-dev, lspconfig
-- https://github.com/williamboman/mason-lspconfig.nvim#setup
--------------------------------------------------------------------------------

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

-- BORDERS
require("lspconfig.ui.windows").default_options.border = BorderStyle
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = BorderStyle })
-- stylua: ignore
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = BorderStyle })

--------------------------------------------------------------------------------
-- DIAGNOSTICS 

local function diagnosticFormat(diagnostic, mode)
	local msg = diagnostic.message:gsub("^%s*", ""):gsub("%s*$", "")
local source = diagnostic.source and diagnostic.source:gsub("%.$", "") or ""
	local code = tostring(diagnostic.code)

	-- stylelint and already includes the code in the message, codespell has no code
	local out
if source == "stylelint" or source == "codespell" then
		out = msg
	else
		out = msg .. " (" .. code .. ")"
	end

-- append source to float
if diagnostic.source and mode == "float" then out = out .. " [" .. source .. "]" end

	return out
end

vim.diagnostic.config {
	virtual_text = {
		format = function(diagnostic) return diagnosticFormat(diagnostic, "virtual_text") end,
		severity = { min = vim.diagnostic.severity.WARN },
	},
	float = {
		focusable = true,
		border = BorderStyle,
		max_width = 50,
		header = "", -- remove "Diagnostics:" heading
		format = function(diagnostic) return diagnosticFormat(diagnostic, "float") end,
	},
}

--------------------------------------------------------------------------------
-- Mason Config
require("mason").setup {
	ui = {
		border = BorderStyle,
		icons = { package_installed = "✓", package_pending = "羽", package_uninstalled = "✗" },
	},
}
require("mason-lspconfig").setup {
	ensure_installed = lsp_servers,
}

--------------------------------------------------------------------------------
-- LSP PLUGINS
require("lsp_signature").setup {
	floating_window = false,
	hint_prefix = "﬍ ",
	hint_scheme = "NonText", -- highlight group
}

require("lsp-inlayhints").setup {
	inlay_hints = {
		parameter_hints = {
			show = true,
			prefix = " ",
			remove_colon_start = true,
			remove_colon_end = true,
		},
		type_hints = {
			show = true,
			prefix = "   ",
			remove_colon_start = true,
			remove_colon_end = true,
		},
		only_current_line = true,
		highlight = "NonText", -- highlight group
	},
}

-- INFO: this block must come before lua LSP setup
require("neodev").setup {
	library = { plugins = false },
}

augroup("LSP", {})
autocmd("LspAttach", {
	group = "LSP",
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local capabilities = client.server_capabilities

		require("lsp-inlayhints").on_attach(client, bufnr)

		if capabilities.documentSymbolProvider and client.name ~= "cssls" then
			require("nvim-navic").attach(client, bufnr)
		end
	end,
})

--------------------------------------------------------------------------------
-- LSP-SERVER-SPECIFIC SETUP

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

-- configure all lsp servers
for _, lsp in pairs(lsp_servers) do
	local config = {
		capabilities = lspCapabilities,
		settings = lspSettings[lsp], -- if no settings, will assign nil and therefore to nothing
		filetypes = lspFileTypes[lsp],
	}

	require("lspconfig")[lsp].setup(config)
end
