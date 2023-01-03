require("config.utils")
-- INFO: required order of setup() calls is mason, mason-config, nvim-dev, lspconfig
-- https://github.com/williamboman/mason-lspconfig.nvim#setup
--------------------------------------------------------------------------------

-- INFO: Server names are LSP names, not Mason names
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
local lsp_servers = {
	"sumneko_lua",
	"yamlls",
	"jsonls",
	"bashls", -- also used for zsh; requires shellcheck-cli
	"cssls",
	"emmet_ls", -- css & html completion
	"pyright", -- python
	"marksman", -- markdown
	"tsserver", -- ts/js
	"eslint", -- ts/js, requires eslint-cli https://github.com/williamboman/mason.nvim/issues/697
}

--------------------------------------------------------------------------------

local signIcons = {
	Error = "",
	Warn = "▲",
	Info = "",
	Hint = "",
}

-- SIGN-COLUMN ICONS
for type, icon in pairs(signIcons) do
	local hl = "DiagnosticSign" .. type
	fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

--------------------------------------------------------------------------------
-- DIAGNOSTICS (also applies to null-ls)
-- stylua: ignore
keymap("n", "ge", function() vim.diagnostic.goto_next { wrap = true, float = true } end, { silent = true })
-- stylua: ignore
keymap("n", "gE", function() vim.diagnostic.goto_prev { wrap = true, float = true } end, { silent = true })
keymap("n", "<leader>d", function() vim.diagnostic.open_float { focusable = false } end)

local function diagnosticFormat(diagnostic, mode)
	local msg = diagnostic.message:gsub("^%s*", ""):gsub("%s*$", "")
	local source = diagnostic.source and diagnostic.source:gsub("%.$", "") or ""
	local code = tostring(diagnostic.code)
	local out = msg .. " (" .. code .. ")"

	if source == "stylelint" or source == "shellcheck" or code == "nil" then
		out = msg -- stylelint and shellcheck already includes the code in the message, some linters without code
	end
	if diagnostic.source and mode == "float" then out = out .. " [" .. source .. "]" end
	return out
end

vim.diagnostic.config {
	virtual_text = {
		format = function(diagnostic) return diagnosticFormat(diagnostic, "virtual_text") end,
		severity = { min = vim.diagnostic.severity.WARN },
	},
	float = {
		border = borderStyle,
		max_width = 50,
		format = function(diagnostic) return diagnosticFormat(diagnostic, "float") end,
	},
}

--------------------------------------------------------------------------------
-- Mason Config
require("mason").setup {
	ui = {
		border = borderStyle,
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

--------------------------------------------------------------------------------
-- LSP KEYBINDINGS

-- fallback for languages without an action LSP
keymap("n", "gs", telescope.treesitter)

-- actions defined globally so null-ls can use them without LSP, e.g., for bash
-- or gitsigns
keymap({ "n", "x" }, "<leader>a", vim.lsp.buf.code_action)

augroup("LSP", {})
autocmd("LspAttach", {
	group = "LSP",
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local bufopts = { buffer = true }

		require("lsp-inlayhints").on_attach(client, bufnr)

		if client.server_capabilities.documentSymbolProvider then
			require("nvim-navic").attach(client, bufnr)
		end

		if client.name == "tsserver" then -- eslint & prettier already take care of formatting
			client.server_capabilities.documentFormattingProvider = false
		end

		if client.server_capabilities.renameProvider then
			-- overrides treesitter-refactor's rename
			keymap("n", "<leader>R", vim.lsp.buf.rename, bufopts)
		end

		keymap("n", "gd", telescope.lsp_definitions, { desc = "LSP: Goto Definition", buffer = true })
		keymap("n", "gf", telescope.lsp_references, { desc = "LSP: Goto Re[f]erence", buffer = true })
		keymap({ "n", "i", "x" }, "<C-s>", vim.lsp.buf.signature_help, bufopts)
		keymap("n", "<leader>h", vim.lsp.buf.hover, bufopts) -- docs popup

		keymap({ "n", "x", "i" }, "<D-s>", function()
			local ft = bo.filetype
			local lspformat = vim.lsp.buf.format
			if ft == "javascript" or ft == "typescript" then
				lspformat { async = false } -- prettier & tsserver
				cmd.update { bang = true }
				cmd.EslintFixAll() -- eslint-lsp
			elseif ft == "applescript" then
				cmd.mkview { bang = true }
				cmd.normal { "gg=G", bang = true } -- poor man's formatting
				lspformat { async = false } -- still used for null-ls-codespell
				cmd.loadview()
			else
				lspformat { async = true }
			end
			cmd.write()
		end, bufopts)

		if bo.filetype ~= "css" then -- don't override navigation marker search for css files
			keymap("n", "gs", telescope.lsp_document_symbols, bufopts) -- overrides treesitter symbols browsing
			keymap("n", "gS", telescope.lsp_workspace_symbols, bufopts)
		end
	end,
})

-- copy breadcrumbs (nvim navic)
keymap("n", "<D-b>", function()
	if require("nvim-navic").is_available() then
		local rawdata = require("nvim-navic").get_data()
		local breadcrumbs = ""
		for _, v in pairs(rawdata) do
			breadcrumbs = breadcrumbs .. v.name .. "."
		end
		breadcrumbs = breadcrumbs:sub(1, -2)
		fn.setreg("+", breadcrumbs)
		vim.notify("COPIED\n" .. breadcrumbs)
	else
		vim.notify("No Breadcrumbs available.", logWarn)
	end
end)

--------------------------------------------------------------------------------
-- Add borders to various lsp windows
require("lspconfig.ui.windows").default_options.border = borderStyle
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = borderStyle })
vim.lsp.handlers["textDocument/signatureHelp"] =
	vim.lsp.with(vim.lsp.handlers.signature_help, { border = borderStyle })

--------------------------------------------------------------------------------
-- LSP-SERVER-SPECIFIC SETUP

local lspSettings = {}
local lspFilestypes = {}

-- https://github.com/sumneko/lua-language-server/wiki/Annotations#annotations
-- https://github.com/sumneko/lua-language-server/wiki/Settings
lspSettings.sumneko_lua = {
	Lua = {
		format = { enable = false }, -- using stylua instead. Also, sumneko-lsp-formatting has this weird bug where all folds are opened
		completion = {
			callSnippet = "Replace",
			keywordSnippet = "Replace",
			displayContext = 2,
		},
		diagnostics = {
			disable = { "trailing-space", "lowercase-global" },
		},
		-- libraries defined per-project via luarc.json location: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
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

-- https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
local jsAndTsSettings = {
	format = {
		insertSpaceAfterCommaDelimiter = true,
		insertSpaceAfterConstructor = false,
		insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
		insertSpaceAfterOpeningAndBeforeClosingEmptyBraces = false,
		insertSpaceAfterOpeningAndBeforeClosingNonemptyBraces = true,
		insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
		insertSpaceAfterOpeningAndBeforeClosingNonemptyParenthesis = false,
		insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
		insertSpaceAfterSemicolonInForStatements = true,
		insertSpaceBeforeAndAfterBinaryOperators = true,
		insertSpaceBeforeFunctionParenthesis = false,
		placeOpenBraceOnNewLineForFunctions = false,
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

lspSettings.tsserver = {
	completions = { completeFunctionCalls = true },
	diagnostics = {
		-- https://github.com/microsoft/TypeScript/blob/master/src/compiler/diagnosticMessages.json
		ignoredCode = {},
	},
	typescript = jsAndTsSettings,
	javascript = jsAndTsSettings,
}

-- https://github.com/redhat-developer/yaml-language-server#language-server-settings
-- lspSettings.yamlls = {
-- 	yaml = {
-- 		format = {
-- 			enable = true, -- does not seem to be supported yet
-- 			singleQuote = false,
-- 			bracketSpacing = true,
-- 			proseWrap = "preserve", -- preserve|always|never
-- 			printWidth = 120, -- relevant for proseWrap
-- 		},
-- 		hover = true,
-- 		completion = true,
-- 		validate = true,
-- 		-- schemaStore = { enable = true }, -- Automatically pull available YAML schemas from JSON Schema Store
-- 		schemas = {
-- 			["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
-- 			["https://json.schemastore.org/github-issue-config.json"] = "/.github/ISSUE_TEMPLATE/*",
-- 		},
-- 	},
-- }

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint
lspSettings.eslint = {
	quiet = false, -- = include warnings
	codeAction = {
		disableRuleComment = { location = "sameLine" }, -- add ignore-comments on the same line
	},
	-- needed to use mason's eslint with the eslint-lsp https://github.com/williamboman/mason.nvim/issues/697#issuecomment-1330855352
	-- nodePath = os.getenv("HOME") .. "/.local/share/nvim/mason/packages/eslint/node_modules",
}

-- https://github.com/sublimelsp/LSP-json/blob/master/LSP-json.sublime-settings
lspSettings.jsonls = {
	json = {
		validate = { enable = true },
		format = { enable = true },
		schemas = require("schemastore").json.schemas(),
	},
}

lspFilestypes.bashls = { "sh", "zsh", "bash" } -- force lsp to work with zsh
lspFilestypes.emmet_ls = { "css", "scss", "html" }

--------------------------------------------------------------------------------

-- Enable snippet capability for completion (nvim_cmp)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- configure all lsp servers
for _, lsp in pairs(lsp_servers) do
	local config = { capabilities = capabilities }
	if lspSettings[lsp] then config.settings = lspSettings[lsp] end
	if lspFilestypes[lsp] then config.filetypes = lspFilestypes[lsp] end
	require("lspconfig")[lsp].setup(config)
end
