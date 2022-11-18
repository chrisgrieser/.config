require("utils")
-- INFO: required order of setup() calls is mason, mason-config, nvim-dev, lspconfig
-- https://github.com/williamboman/mason-lspconfig.nvim#setup
--------------------------------------------------------------------------------

-- INFO: Server names are LSP names, not Mason names
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
local lsp_servers = {
	"sumneko_lua",
	"yamlls",
	"jsonls",
	"cssls",
	"pyright",
	"marksman", -- markdown
	"tsserver", -- ts/js
}

--------------------------------------------------------------------------------
-- DIAGNOTICS (also applies to null-ls)
keymap("n", "ge", function() vim.diagnostic.goto_next {wrap = true, float = false} end, {silent = true})
keymap("n", "gE", function() vim.diagnostic.goto_prev {wrap = true, float = false} end, {silent = true})
keymap("n", "<leader>d", function() vim.diagnostic.open_float {focusable = false} end)

-- toggle diagnostics
local diagnosticToggled = true;
keymap("n", "<leader>D", function()
	if diagnosticToggled then
		vim.diagnostic.disable(0)
	else
		vim.diagnostic.enable(0)
	end
	diagnosticToggled = not (diagnosticToggled)
end)

function diagnosticFormat(diagnostic, mode)
	local msg = trim(diagnostic.message)
	local source = diagnostic.source:gsub("%.$", "")
	local code = tostring(diagnostic.code)
	local out

	if source == "stylelint" or code == "nil" then -- stylelint already includes the code in the message, write-good has no codes
		out = msg
	else
		out = msg .. " (" .. code .. ")"
	end
	if diagnostic.source and mode == "float" then
		out = out .. " [" .. source .. "]"
	end
	return out
end

vim.diagnostic.config {
	virtual_text = {
		format = function(diagnostic) return diagnosticFormat(diagnostic, "virtual_text") end,
		severity = {min = vim.diagnostic.severity.WARN},
	},
	float = {
		border = borderStyle,
		max_width = 50,
		format = function(diagnostic) return diagnosticFormat(diagnostic, "float") end,
	}
}


--------------------------------------------------------------------------------
-- Mason Config
require("mason").setup {
	ui = {
		border = borderStyle,
		icons = {package_installed = "✓", package_pending = "羽", package_uninstalled = "✗"}
	}
}
require("mason-update-all").setup()

require("mason-lspconfig").setup {
	-- mason-lspconfig uses the lspconfig servernames, not mason servernames
	-- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
	ensure_installed = lsp_servers,
}

--------------------------------------------------------------------------------
-- LSP PLUGINS
require("lsp_signature").setup {
	floating_window = false,
	hint_prefix = "﬍ ",
	hint_scheme = "GhostText", -- highlight group
}

require("lsp-inlayhints").setup {
	inlay_hints = {
		parameter_hints = {
			show = true,
			prefix = "<- ",
			remove_colon_start = true,
			remove_colon_end = true,
		},
		type_hints = {
			show = true,
			prefix = " ", -- 
			remove_colon_start = true,
			remove_colon_end = true,
		},
		only_current_line = true,
		highlight = "GhostText", -- highlight group
	},
}

-- INFO: this block must come before lua LSP setup
require("neodev").setup {
	library = {plugins = false}
}

--------------------------------------------------------------------------------
-- LSP KEYBINDINGS

-- fallback for languages without an action LSP
keymap("n", "gs", telescope.treesitter)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local function on_attach(client, bufnr)
	require("lsp-inlayhints").on_attach(client, bufnr) ---@diagnostic disable-line: missing-parameter

	local bufopts = {silent = true, buffer = true}
	keymap("n", "gd", telescope.lsp_definitions, bufopts)
	keymap("n", "gD", telescope.lsp_references, bufopts)
	keymap("n", "gy", telescope.lsp_type_definitions, bufopts)
	keymap("n", "<leader>R", vim.lsp.buf.rename, bufopts)
	keymap({"n", "i", "x"}, "<C-s>", vim.lsp.buf.signature_help)
	keymap("n", "<leader>h", vim.lsp.buf.hover, bufopts) -- docs popup

	-- actions defined globally so null-ls can use them without LSP being present
	keymap("n", "<leader>a", vim.lsp.buf.code_action)

	-- format on manual save
	keymap("n", "<D-s>", function()
		vim.lsp.buf.format {async = true}
		cmd [[write!]]
	end, bufopts)

	if client.name ~= "cssls" then -- don't override navigation marker search for css files
		keymap("n", "gs", telescope.lsp_document_symbols, bufopts) -- overrides treesitter symbols browsing
		keymap("n", "gS", telescope.lsp_workspace_symbols, bufopts)
	end
end

--------------------------------------------------------------------------------
-- Add borders to various lsp windows
require("lspconfig.ui.windows").default_options.border = borderStyle

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
	vim.lsp.handlers.hover, {border = borderStyle}
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
	vim.lsp.handlers.signature_help, {border = borderStyle}
)
--------------------------------------------------------------------------------
-- LSP-SERVER-SPECIFIC SETUP

-- https://github.com/sumneko/lua-language-server/wiki/Annotations#annotations
-- https://github.com/sumneko/lua-language-server/wiki/Settings
local luaSettings = {
	Lua = {
		runtime = {version = "LuaJIT"}, -- used by neovim
		format = {
			enable = true,
			defaultConfig = {
				-- https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md
				-- https://github.com/sumneko/lua-language-server/wiki/Formatter
				quote_style = "double",
				call_arg_parentheses = "remove_table_only",
				-- yes, all these must be strings
				keep_one_space_between_table_and_bracket = "false",
				keep_one_space_between_namedef_and_attribute = "false",
				continuous_assign_table_field_align_to_equal_sign = "false",
				continuation_indent_size = tostring(opt.tabstop:get()),
			},
		},
		completion = {
			callSnippet = "Replace",
			keywordSnippet = "Replace",
			displayContext = 1,
			showWord = "Fallback",
		},
		diagnostics = {
			globals = {"martax"},
			disable = {
				"trailing-space",
				"lowercase-global",
			},
		},
		workspace = {
			library = {home .. ".hammerspoon/Spoons/EmmyLua.spoon/annotations"},
			checkThirdParty = false, -- https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
		},
		hint = {
			enable = true,
			setType = true,
			paramName = "All",
			paramType = true,
			arrayIndex = "Disable",
		},
		telemetry = {enable = false},
	}
}

-- https://github.com/sublimelsp/LSP-css/blob/master/LSP-css.sublime-settings
local cssSettings = {
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
		colorDecorators = {enable = true}, -- not supported yet
	}
}
-- https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
local jsAndTsSettings = {
	format = {
		insertSpaceAfterCommaDelimiter = true,
		insertSpaceAfterConstructor = false,
		insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
		insertSpaceAfterKeywordsInControlFlowStatements = true,
		insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = false,
		insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
		insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
		insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
		insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
		insertSpaceAfterSemicolonInForStatements = true,
		insertSpaceBeforeAndAfterBinaryOperators = true,
		insertSpaceBeforeFunctionParenthesis = false,
		insertSpaceBeforeTypeAnnotation = true,
		placeOpenBraceOnNewLineForFunctions = false,
		semicolons = "insert", -- ignore | insert | remove
		trimTrailingWhitespace = true,
	},
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

local tsjsSettings = {
	diagnostics = {
		ignoredCode = {},
	},
	typescript = jsAndTsSettings,
	javascript = jsAndTsSettings,
}

-- https://github.com/redhat-developer/yaml-language-server#language-server-settings
local yamlSettings = {
	yaml = {
		format = {
			singleQuote = false,
			bracketSpacing = true,
			proseWrap = "preserve", -- preserve|always|never
			printWidth = 120, -- relevant for proseWrap
		},
		hover = true,
		completion = true,
		validate = true,
		schemaStore = true, -- Automatically pull available YAML schemas from JSON Schema Store
	},
}
--------------------------------------------------------------------------------

-- Enable snippet capability for completion (nvim_cmp)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- configure all lsp servers
for _, lsp in pairs(lsp_servers) do
	local config = {
		on_attach = on_attach,
		capabilities = capabilities,
	}
	if lsp == "sumneko_lua" then
		config.settings = luaSettings
	elseif lsp == "tsserver" then
		config.settings = tsjsSettings
	elseif lsp == "cssls" then
		config.settings = cssSettings
	elseif lsp == "yamlls" then
		config.settings = yamlSettings
	end
	require("lspconfig")[lsp].setup(config)
end
