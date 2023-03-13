require("config.utils")
--------------------------------------------------------------------------------

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
