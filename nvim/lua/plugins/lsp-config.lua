local u = require("config.utils")
local lspSettings = {}
local lspOnAttach = {}
local lspFiletypes = {}

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
	"bashls", -- also used for zsh
	"taplo", -- toml
	"lemminx", -- xml/plist
	"html",
	"ltex", -- latex/languagetool (requires `openjdk`)
	"rome", -- js/ts/json – formatting capability needs to be provided via null-ls
}

--------------------------------------------------------------------------------
-- LUA
-- https://github.com/LuaLS/lua-language-server/wiki/Annotations#annotations
-- https://github.com/LuaLS/lua-language-server/wiki/Settings

lspSettings.lua_ls = {
	Lua = {
		completion = {
			callSnippet = "Replace",
			keywordSnippet = "Replace",
			postfix = ".", -- useful for `table.insert` and the like
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
		},
		workspace = { checkThirdParty = false }, -- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
		format = { enable = false }, -- using stylua instead. Also, sumneko-lsp-formatting has this weird bug where all folds are opened
		telemetry = { enable = false },
	},
}

--------------------------------------------------------------------------------
-- EMMET
-- don't pollute completions for js and ts with stuff I don't need
lspFiletypes.emmet_ls = { "css", "html" }

--------------------------------------------------------------------------------
-- CSS
-- https://github.com/microsoft/vscode-css-languageservice/blob/main/src/services/lintRules.ts
lspSettings.cssls = {
	css = {
		lint = {
			compatibleVendorPrefixes = "ignore", 
			vendorPrefix = "ignore",
			unknownVendorSpecificProperties = "ignore",

			duplicateProperties = "warning",
			emptyRules = "warning",
			importStatement = "warning",
			universalSelector = "ignore",
			zeroUnits = "warning",
			fontFaceProperties = "warning",
			hexColorLength = "warning",
			argumentsInColorFunction = "warning",
			unknownProperties = "warning",
			unknownAtRules = "warning",
			ieHack = "error",
			propertyIgnoredDueToDisplay = "error",
			important = "ignore",
			float = "ignore",
			idSelector = "warning",
		},
		colorDecorators = { enable = true }, -- not supported yet
	},
}

--------------------------------------------------------------------------------
-- TSSERVER
-- https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration

lspSettings.tsserver = {
	completions = { completeFunctionCalls = true },
	diagnostics = {
		-- "cannot redeclare block-scoped variable" -> useless when applied to JXA
		ignoredCodes = { 2451 },
	},
	typescript = {
		inlayHints = {
			includeInlayEnumMemberValueHints = true,
			includeInlayFunctionLikeReturnTypeHints = true,
			includeInlayFunctionParameterTypeHints = true,
			includeInlayParameterNameHints = "all",
			includeInlayParameterNameHintsWhenArgumentMatchesName = true,
			includeInlayPropertyDeclarationTypeHints = true,
			includeInlayVariableTypeHints = true,
			includeInlayVariableTypeHintsWhenTypeMatchesName = true,
		},
	},
	javascript = {
		inlayHints = {
			includeInlayEnumMemberValueHints = true,
			includeInlayFunctionLikeReturnTypeHints = true,
			includeInlayFunctionParameterTypeHints = true,
			includeInlayParameterNameHints = "all",
			includeInlayParameterNameHintsWhenArgumentMatchesName = true,
			includeInlayPropertyDeclarationTypeHints = true,
			includeInlayVariableTypeHints = true,
			includeInlayVariableTypeHintsWhenTypeMatchesName = true,
		},
	},
}

-- disable formatting, since taken care of by rome https://github.com/jose-elias-alvarez/null-ls.nvim/wiki/Avoiding-LSP-formatting-conflicts#neovim-08
lspOnAttach.tsserver = function(client, _)
	client.server_capabilities.documentFormattingProvider = false
	client.server_capabilities.documentRangeFormattingProvider = false
end

--------------------------------------------------------------------------------
-- JSON
-- https://github.com/sublimelsp/LSP-json/blob/master/LSP-json.sublime-settings
lspSettings.jsonls = {
	json = { format = { enable = false } }, -- taken care of by rome
}

--------------------------------------------------------------------------------
-- XML/PLIST
-- https://github.com/eclipse/lemminx/blob/main/docs/Configuration.md#all-formatting-options
lspSettings.lemminx = {
	xml = {
		-- disabled, since it messes up some formatting of Alfred .plist files
		format = { enabled = false },
	},
}

--------------------------------------------------------------------------------
-- BASH / ZSH

-- HACK make zsh files recognized as sh for bash-ls & treesitter
vim.filetype.add {
	extension = {
		zsh = "sh",
		sh = "sh", -- so .sh files with zsh-shebang still get sh filetype
	},
	filename = {
		[".zshrc"] = "sh",
		[".zshenv"] = "sh",
	},
}

-- CAVEAT: various attempts of setting shellcheck args for bashls does not work,
-- apparently because bash-ls blocks them due to the zsh-shebang, regardless of
-- filetype defined by nvim.
-- Therefore using shellcheck via null-ls, since there enforcing the shell via
-- `--shell=bash` does work.

--------------------------------------------------------------------------------
-- LTEX
-- https://valentjn.github.io/ltex/settings.html

-- disable for bibtex and text files
lspFiletypes.ltex = { "gitcommit", "markdown", "octo" }

-- HACK since reading external file with the method described in the ltex docs
-- does not work
local dictfile = u.linterConfigFolder .. "/dictionary-for-vale-and-languagetool.txt"
local words = {}
for word in io.open(dictfile, "r"):lines() do
	table.insert(words, word)
end

-- INFO path to java runtime engine (the builtin from ltex does not seem to work)
-- here: using `openjdk`, w/ default M1 mac installation path (`brew install openjdk`)
-- HACK set need to set $JAVA_HOME, since `ltex.java.path` does not seem to work
local brewPrefix = vim.fn.system("brew --prefix"):gsub("\n$", "")
vim.env.JAVA_HOME = brewPrefix .. "/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

lspSettings.ltex = {
	ltex = {
		completionEnabled = false,
		language = "en-US", -- default language, can be set per-file via markdown yaml header
		dictionary = { ["en-US"] = words, ["de-DE"] = words },
		disabledRules = {
			["en-US"] = {
				"EN_QUOTES", -- don't expect smart quotes
				"WHITESPACE_RULE", -- too many false positives
				"PUNCTUATION_PARAGRAPH_END", -- too many false positives
				"CURRENCY",
			},
		},
		diagnosticSeverity = {
			default = "hint",
			MORFOLOGIK_RULE_EN_US = "warning", -- spelling
		},
		additionalRules = { enablePickyRules = true },
		markdown = {
			-- ignore links https://valentjn.github.io/ltex/settings.html#ltexmarkdownnodes
			nodes = { Link = "dummy" },
		},
	},
}

--------------------------------------------------------------------------------
-- SETUP ALL LSP
-- enable capabilities for plugins
local lspCapabilities = vim.lsp.protocol.make_client_capabilities()

-- Enable snippets-completion (for nvim_cmp)
lspCapabilities.textDocument.completion.completionItem.snippetSupport = true

-- Enable folding (for nvim-ufo)
lspCapabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

local function setupAllLsps()
	-- INFO must be before the lsp-config setup of lua-ls
	-- plugins are helpful e.g. for plenary, but slow down lsp loading
	require("neodev").setup { library = { plugins = false } }

	for _, lsp in pairs(lsp_servers) do
		local config = {
			capabilities = lspCapabilities,
			-- INFO if no settings, will assign nil and therefore do nothing
			settings = lspSettings[lsp],
			on_attach = lspOnAttach[lsp],
			filetypes = lspFiletypes[lsp],
		}

		require("lspconfig")[lsp].setup(config)
	end
end

--------------------------------------------------------------------------------
-- DIAGNOSTICS
local function diagnosticConfig()
	-- Sign Icons
	local diagnosticTypes = { Error = "", Warn = "▲", Info = "", Hint = "" }
	for type, icon in pairs(diagnosticTypes) do
		local hl = "DiagnosticSign" .. type
		vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
	end

	-- Floats & Virtual Text
	require("lspconfig.ui.windows").default_options.border = u.borderStyle
	vim.lsp.handlers["textDocument/hover"] =
		vim.lsp.with(vim.lsp.handlers.hover, { border = u.borderStyle })

	-- WARN this needs to be disabled due to noice.nvim
	-- vim.lsp.handlers["textDocument/signatureHelp"] =
	-- 	vim.lsp.with(vim.lsp.handlers.signature_help, { border = u.borderStyle })

	vim.diagnostic.config {
		virtual_text = {
			severity = { min = vim.diagnostic.severity.WARN }, -- no text for hints
			source = false, -- already handled by format function
			format = function(diag) return u.diagnosticFmt(diag) end,
			spacing = 1,
		},
		float = {
			format = function(diag) return u.diagnosticFmt(diag) end,
			focusable = true,
			border = u.borderStyle,
			max_width = 70,
			header = "", -- remove "Diagnostics:" heading
		},
	}
end
--------------------------------------------------------------------------------

return {
	{ -- package manager
		"williamboman/mason.nvim",
		opts = {
			ui = {
				border = u.borderStyle,
				height = 0.8, -- so it won't cover the statusline
				icons = { package_installed = "✓", package_pending = "󰔟", package_uninstalled = "✗" },
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
		config = diagnosticConfig,
	},
}
